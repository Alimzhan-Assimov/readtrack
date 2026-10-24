import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../sources/fetcher.dart';

/// The AI services ReadTrack can talk to. The user brings the key (or runs
/// Ollama locally); nothing is sent without being asked.
enum AiProvider {
  ollama('Ollama', 'http://localhost:11434', 'llama3.1', needsKey: false),

  /// OpenAI and everything with the same API: Groq, OpenRouter, LM Studio …
  openAiCompatible('OpenAI-compatible', 'https://api.openai.com/v1', ''),
  gemini(
    'Gemini',
    'https://generativelanguage.googleapis.com/v1beta',
    'gemini-2.5-flash',
  ),
  claude('Claude', 'https://api.anthropic.com/v1', 'claude-opus-5-5');

  const AiProvider(
    this.label,
    this.defaultUrl,
    this.defaultModel, {
    this.needsKey = true,
  });

  final String label;
  final String defaultUrl;
  final String defaultModel;
  final bool needsKey;
}

/// Which provider to use, where, and with which model.
class AiConfig {
  const AiConfig(this.provider, {String? url, String? model})
    : url = url ?? '',
      model = model ?? '';

  final AiProvider provider;
  final String url;
  final String model;

  String get baseUrl => (url.trim().isEmpty ? provider.defaultUrl : url.trim())
      .replaceAll(RegExp(r'/+$'), '');
  String get modelName =>
      model.trim().isEmpty ? provider.defaultModel : model.trim();
}

/// Where API keys live: the system keyring, never the database (so they
/// don't end up in backups or a sync).
abstract class KeyStore {
  Future<String?> read(AiProvider provider);
  Future<void> write(AiProvider provider, String? key);
}

class SecureKeyStore implements KeyStore {
  const SecureKeyStore();

  static const _storage = FlutterSecureStorage();
  static String _name(AiProvider p) => 'readtrack.ai.${p.name}';

  @override
  Future<String?> read(AiProvider provider) =>
      _storage.read(key: _name(provider));

  @override
  Future<void> write(AiProvider provider, String? key) =>
      key == null || key.isEmpty
      ? _storage.delete(key: _name(provider))
      : _storage.write(key: _name(provider), value: key);
}

/// Sends one prompt and returns the model's text answer.
class AiClient {
  AiClient(this.config, {this.apiKey, http.Client? client})
    : _client = client ?? http.Client();

  final AiConfig config;
  final String? apiKey;
  final http.Client _client;

  void close() => _client.close();

  /// Asks for a JSON answer to [prompt] following [system].
  Future<String> complete({
    required String system,
    required String prompt,
  }) async {
    if (config.provider.needsKey && (apiKey ?? '').isEmpty) {
      throw SourceException(
        'No API key for ${config.provider.label}. Add it in the settings.',
      );
    }
    final base = config.baseUrl;
    final model = config.modelName;
    if (model.isEmpty) {
      throw SourceException('Choose a model for ${config.provider.label}.');
    }
    final (
      Uri url,
      Map<String, String> headers,
      Object body,
    ) = switch (config.provider) {
      AiProvider.ollama => (
        Uri.parse('$base/api/chat'),
        const <String, String>{},
        {
          'model': model,
          'stream': false,
          'format': 'json',
          'messages': [
            {'role': 'system', 'content': system},
            {'role': 'user', 'content': prompt},
          ],
        },
      ),
      AiProvider.openAiCompatible => (
        Uri.parse('$base/chat/completions'),
        {'Authorization': 'Bearer $apiKey'},
        {
          'model': model,
          'response_format': {'type': 'json_object'},
          'messages': [
            {'role': 'system', 'content': system},
            {'role': 'user', 'content': prompt},
          ],
        },
      ),
      AiProvider.gemini => (
        Uri.parse('$base/models/$model:generateContent'),
        {'x-goog-api-key': apiKey!},
        {
          'systemInstruction': {
            'parts': [
              {'text': system},
            ],
          },
          'contents': [
            {
              'role': 'user',
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {'responseMimeType': 'application/json'},
        },
      ),
      AiProvider.claude => (
        Uri.parse('$base/messages'),
        {
          'x-api-key': apiKey!,
          'anthropic-version': '2023-06-01',
          // A declined request is retried on a fitting model.
          'anthropic-beta': 'server-side-fallback-2026-07-01',
        },
        {
          'model': model,
          'max_tokens': 16000,
          'system': system,
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
          // Choosing tags from a list needs little deliberation.
          'output_config': {'effort': 'low'},
          'fallbacks': 'default',
        },
      ),
    };
    final http.Response response;
    try {
      response = await _client
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'User-Agent': HttpFetcher.userAgent,
              ...headers,
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(minutes: 5));
    } on Exception catch (e) {
      throw SourceException(
        '${config.provider.label} could not be reached: $e',
      );
    }
    final Object? json;
    try {
      json = jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw SourceException(
        '${config.provider.label} answered HTTP ${response.statusCode}.',
      );
    }
    if (response.statusCode != 200) {
      final message = switch (json) {
        {'error': {'message': final String m}} => m,
        {'error': final String m} => m,
        _ => 'HTTP ${response.statusCode}',
      };
      throw SourceException('${config.provider.label}: $message');
    }
    return switch ((config.provider, json)) {
      (AiProvider.ollama, {'message': {'content': final String text}}) => text,
      (
        AiProvider.openAiCompatible,
        {'choices': [{'message': {'content': final String text}}, ...]},
      ) =>
        text,
      (
        AiProvider.gemini,
        {
          'candidates': [
            {'content': {'parts': [{'text': final String text}, ...]}},
            ...,
          ],
        },
      ) =>
        text,
      (AiProvider.claude, {'stop_reason': 'refusal'}) => throw SourceException(
        'Claude declined this request.',
      ),
      (AiProvider.claude, {'content': final List blocks}) => [
        for (final b in blocks)
          if (b case {'type': 'text', 'text': final String t}) t,
      ].join(),
      _ => throw SourceException(
        '${config.provider.label} gave an answer ReadTrack doesn\'t understand.',
      ),
    };
  }
}

/// The first JSON object in [text] (models sometimes wrap it in prose or a
/// code block).
Map<String, Object?> parseJsonObject(String text) {
  final start = text.indexOf('{');
  final end = text.lastIndexOf('}');
  if (start < 0 || end <= start) {
    throw const FormatException('No JSON object in the answer.');
  }
  return (jsonDecode(text.substring(start, end + 1)) as Map)
      .cast<String, Object?>();
}
