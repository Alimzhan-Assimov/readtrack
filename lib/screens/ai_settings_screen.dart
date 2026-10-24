import 'package:flutter/material.dart';

import '../ai/ai_client.dart';
import '../l10n/l10n.dart';
import '../sources/fetcher.dart';
import '../ui/app_settings.dart';
import '../ui/layout.dart';

/// Chooses the optional AI service for tag suggestions and keeps its key in
/// the system keyring.
class AiSettingsScreen extends StatefulWidget {
  const AiSettingsScreen({super.key, this.keys = const SecureKeyStore()});

  final KeyStore keys;

  @override
  State<AiSettingsScreen> createState() => _AiSettingsScreenState();
}

class _AiSettingsScreenState extends State<AiSettingsScreen> {
  AiProvider? _provider;
  final _url = TextEditingController();
  final _model = TextEditingController();
  final _key = TextEditingController();
  bool _loaded = false;
  bool _testing = false;
  String? _result;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    final ai = SettingsScope.maybeOf(context)?.ai;
    _provider = ai?.provider;
    _url.text = ai?.url ?? '';
    _model.text = ai?.model ?? '';
    _loadKey();
  }

  Future<void> _loadKey() async {
    final provider = _provider;
    final key = provider == null ? null : await widget.keys.read(provider);
    if (mounted) setState(() => _key.text = key ?? '');
  }

  @override
  void dispose() {
    _url.dispose();
    _model.dispose();
    _key.dispose();
    super.dispose();
  }

  AiConfig? get _config => _provider == null
      ? null
      : AiConfig(_provider!, url: _url.text, model: _model.text);

  Future<void> _save() async {
    final settings = SettingsScope.maybeOf(context);
    final provider = _provider;
    if (provider != null && provider.needsKey) {
      await widget.keys.write(provider, _key.text.trim());
    }
    await settings?.setAi(_config);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _test() async {
    final config = _config;
    if (config == null) return;
    final l10n = context.l10n;
    setState(() {
      _testing = true;
      _result = null;
    });
    final client = AiClient(config, apiKey: _key.text.trim());
    try {
      final answer = parseJsonObject(
        await client.complete(
          system: 'Answer only with JSON.',
          prompt: 'Reply with {"ok": true}.',
        ),
      );
      _result = answer['ok'] == true ? l10n.aiTestOk : l10n.aiTestOdd;
    } on SourceException catch (e) {
      _result = e.message;
    } on FormatException {
      _result = l10n.aiTestOdd;
    } finally {
      client.close();
      if (mounted) setState(() => _testing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final provider = _provider;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.aiSettingsTitle),
        actions: [TextButton(onPressed: _save, child: Text(l10n.save))],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => ListView(
          padding: readablePadding(constraints.maxWidth, top: 8, bottom: 32),
          children: [
            Text(l10n.aiSettingsIntro, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            DropdownButtonFormField<AiProvider?>(
              initialValue: provider,
              decoration: InputDecoration(
                labelText: l10n.aiProvider,
                border: const OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: null, child: Text(l10n.aiOff)),
                for (final p in AiProvider.values)
                  DropdownMenuItem(value: p, child: Text(p.label)),
              ],
              onChanged: (p) {
                setState(() {
                  _provider = p;
                  _result = null;
                });
                _loadKey();
              },
            ),
            if (provider != null) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _url,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  labelText: l10n.aiUrl,
                  hintText: provider.defaultUrl,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _model,
                decoration: InputDecoration(
                  labelText: l10n.aiModel,
                  hintText: provider.defaultModel.isEmpty
                      ? l10n.aiModelRequired
                      : provider.defaultModel,
                  border: const OutlineInputBorder(),
                ),
              ),
              if (provider.needsKey) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _key,
                  obscureText: true,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    labelText: l10n.aiKey,
                    helperText: l10n.aiKeyHint,
                    helperMaxLines: 3,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  OutlinedButton.icon(
                    icon: _testing
                        ? const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.network_check),
                    label: Text(l10n.aiTest),
                    onPressed: _testing ? null : _test,
                  ),
                  const SizedBox(width: 12),
                  if (_result case final r?) Expanded(child: Text(r)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
