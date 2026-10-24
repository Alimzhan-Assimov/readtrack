import 'dart:convert';

import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:readtrack/ai/ai_client.dart';
import 'package:readtrack/ai/ai_tags.dart';
import 'package:readtrack/data/database.dart';
import 'package:readtrack/data/database_scope.dart';
import 'package:readtrack/l10n/l10n.dart';
import 'package:readtrack/screens/ai_tag_sheet.dart';
import 'package:readtrack/sources/fetcher.dart';

class _Keys implements KeyStore {
  final keys = <AiProvider, String>{};
  @override
  Future<String?> read(AiProvider p) async => keys[p];
  @override
  Future<void> write(AiProvider p, String? key) async => keys[p] = key ?? '';
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  const answer =
      '{"tags": [{"name": "Romance", "reason": "They fall in love."}]}';

  /// A client whose server checks the request and answers like [provider].
  AiClient client(
    AiProvider provider,
    void Function(http.Request r, Map body) check,
    Object reply, {
    int status = 200,
  }) => AiClient(
    AiConfig(provider),
    apiKey: 'secret',
    client: MockClient((r) async {
      check(r, jsonDecode(r.body) as Map);
      return http.Response.bytes(utf8.encode(jsonEncode(reply)), status);
    }),
  );

  test('each provider gets its own request and answer format', () async {
    final ollama = client(
      AiProvider.ollama,
      (r, b) {
        expect('${r.url}', 'http://localhost:11434/api/chat');
        expect(
          (b['model'], b['format'], b['stream']),
          ('llama3.1', 'json', false),
        );
      },
      {
        'message': {'content': answer},
      },
    );
    expect(await ollama.complete(system: 's', prompt: 'p'), answer);

    final openAi = client(
      AiProvider.openAiCompatible,
      (r, b) {
        expect('${r.url}', 'https://api.openai.com/v1/chat/completions');
        expect(r.headers['Authorization'], 'Bearer secret');
      },
      {
        'choices': [
          {
            'message': {'content': answer},
          },
        ],
      },
    );
    expect(
      () => openAi.complete(system: 's', prompt: 'p'),
      throwsA(predicate((e) => '$e'.contains('Choose a model'))),
    );

    final gemini = client(
      AiProvider.gemini,
      (r, b) {
        expect(r.url.path, '/v1beta/models/gemini-2.5-flash:generateContent');
        expect(r.headers['x-goog-api-key'], 'secret');
        expect(b['systemInstruction'], {
          'parts': [
            {'text': 's'},
          ],
        });
      },
      {
        'candidates': [
          {
            'content': {
              'parts': [
                {'text': answer},
              ],
            },
          },
        ],
      },
    );
    expect(await gemini.complete(system: 's', prompt: 'p'), answer);

    final claude = client(
      AiProvider.claude,
      (r, b) {
        expect('${r.url}', 'https://api.anthropic.com/v1/messages');
        expect(r.headers['x-api-key'], 'secret');
        expect(r.headers['anthropic-version'], '2023-06-01');
        expect(r.headers['anthropic-beta'], 'server-side-fallback-2026-07-01');
        expect(
          (b['model'], b['system'], b['fallbacks']),
          ('claude-opus-5-5', 's', 'default'),
        );
        expect(b['output_config'], {'effort': 'low'});
      },
      {
        'stop_reason': 'end_turn',
        'content': [
          {'type': 'thinking', 'thinking': ''},
          {'type': 'text', 'text': answer},
        ],
      },
    );
    expect(await claude.complete(system: 's', prompt: 'p'), answer);
  });

  test('refusals, errors and missing keys are explained', () async {
    expect(
      () => client(AiProvider.claude, (_, _) {}, {
        'stop_reason': 'refusal',
        'content': [],
      }).complete(system: 's', prompt: 'p'),
      throwsA(predicate((e) => '$e'.contains('declined'))),
    );
    expect(
      () => client(AiProvider.claude, (_, _) {}, {
        'type': 'error',
        'error': {
          'type': 'authentication_error',
          'message': 'invalid x-api-key',
        },
      }, status: 401).complete(system: 's', prompt: 'p'),
      throwsA(predicate((e) => '$e' == 'Claude: invalid x-api-key')),
    );
    expect(
      () =>
          AiClient(const AiConfig(AiProvider.gemini))
              .complete(system: 's', prompt: 'p'),
      throwsA(isA<SourceException>()),
    );
    expect(parseJsonObject('Sure! ```json\n{"a": 1}\n```'), {'a': 1});
  });

  Chapter chapter(int n) => Chapter(
    id: n,
    workId: 1,
    number: n,
    title: 'Chapter $n',
    content: n == 4 ? null : '<p>${List.filled(10, 'word').join(' ')} $n</p>',
    isLocked: false,
  );

  test('excerpts follow the mode and stay small', () {
    final chapters = [for (var n = 1; n <= 7; n++) chapter(n)];
    String numbers(AiExcerpt e) =>
        RegExp(r'--- Chapter (\d+)')
            .allMatches(e.text)
            .map((m) => m[1])
            .join(',');
    expect(numbers(pickExcerpt(chapters, AiTagMode.quick)), '1,2,3');
    // Chapter 4 has no text.
    expect(numbers(pickExcerpt(chapters, AiTagMode.thorough)), '1,5,7');
    final fresh = pickExcerpt(chapters, AiTagMode.newChapters, analyzedUpTo: 5);
    expect((numbers(fresh), fresh.lastChapter), ('6,7', 7));
    final cut = pickExcerpt(chapters, AiTagMode.quick, wordsPerChapter: 5);
    expect(cut.words, 15);
  });

  test('only listed tags the work lacks are taken', () async {
    final c = AiClient(
      const AiConfig(AiProvider.ollama),
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({
            'message': {
              'content': '{"tags": [{"name": "romance", "reason": "Love."}, {"name": "Made Up"}, {"name": "Action"}]}',
            },
          }),
          200,
        ),
      ),
    );
    final found = await suggestTagsWithAi(
      c,
      work: Work(
        id: 1,
        type: WorkType.book,
        format: WorkFormat.digital,
        title: 'T',
        status: ReadingStatus.planned,
        isComplete: true,
        addedAt: DateTime(2026),
        updatedAt: DateTime(2026),
        newChapters: 0,
        wordsEstimated: false,
        pagesEstimated: false,
        ownsPhysicalCopy: false,
      ),
      currentTags: ['Action'],
      allowed: ['Action', 'Romance'],
      excerpt: (text: '', words: 0, lastChapter: 0),
    );
    expect(found, {'Romance': 'Love.'});
  });

  testWidgets('the sheet says how much is sent and stores the suggestions', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final id = (await tester.runAsync(() async {
      final id = await db.saveWork(
        WorksCompanion.insert(
          type: WorkType.fanfiction,
          format: WorkFormat.online,
          title: 'Story',
          summary: const Value('Two rivals.'),
        ),
      );
      await db.saveChapterList(id, [
        (number: 1, title: 'One', url: 'https://a.test/1', locked: false),
      ]);
      await db.saveChapterText(
        id,
        1,
        html: '<p>${List.filled(100, 'word').join(' ')}</p>',
        wordCount: 100,
      );
      return id;
    }))!;
    final item = (await tester.runAsync(() => db.watchWork(id).first))!;
    final keys = _Keys()..keys[AiProvider.claude] = 'secret';
    late http.Request sent;
    await tester.pumpWidget(
      DatabaseScope(
        db: db,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => suggestTagsWithAiSheet(
                context,
                item,
                const AiConfig(AiProvider.claude),
                keys: keys,
                openClient: (c, k) => AiClient(
                  c,
                  apiKey: k,
                  client: MockClient((r) async {
                    sent = r;
                    return http.Response(
                      jsonEncode({
                        'stop_reason': 'end_turn',
                        'content': [
                          {'type': 'text', 'text': answer},
                        ],
                      }),
                      200,
                    );
                  }),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    Future<void> settle() async {
      for (var i = 0; i < 10; i++) {
        await tester.runAsync(() => Future<void>.delayed(Durations.short1));
        await tester.pump(Durations.short4);
      }
    }

    await tester.tap(find.text('open'));
    await settle();
    // 100 words of chapter 1 plus 2 of the summary.
    expect(
      find.text('About 102 words will be sent to Claude.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Send'));
    await settle();
    expect(sent.headers['x-api-key'], 'secret');
    final open = (await tester.runAsync(
      () => db.watchTagSuggestions(id).first,
    ))!;
    expect(open.single.tag.name, 'Romance');
    expect(
      (open.single.suggestion.source, open.single.suggestion.reason),
      ('Claude', 'They fall in love.'),
    );
    expect(
      (await tester.runAsync(() => db.workById(id)))!.aiAnalyzedChapter,
      1,
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
  });
}
