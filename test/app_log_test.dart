import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:readtrack/diagnostics/app_log.dart';
import 'package:readtrack/version.dart';

void main() {
  late Directory dir;

  setUp(() => dir = Directory.systemTemp.createTempSync('readtrack_log'));
  tearDown(() {
    AppLog.instance = null;
    dir.deleteSync(recursive: true);
  });

  test('lines carry level, category, context and stack', () async {
    final log = await AppLog.open(dir);
    logWarning(
      'download',
      'Chapter failed',
      context: {'chapter': 110, 'url': 'https://a.test/c?token=abc'},
      error: 'HTTP 503',
    );
    logError('app', 'Boom', error: StateError('x'), stack: StackTrace.current);
    final text = await log.read();
    expect(text, contains('WARNING [download] Chapter failed'));
    expect(text, contains('"chapter":110'));
    expect(text, contains('"url":"https://a.test/c"'));
    expect(text, isNot(contains('token=abc')));
    expect(text, contains('error: HTTP 503'));
    expect(text, contains('ERROR   [app] Boom'));
    expect(text, contains('app_log_test.dart'));
  });

  test('sensitive values are hidden', () {
    expect(
      AppLog.redact({'password': 'p', 'apiKey': 'k', 'Cookie': 'c', 'n': 1}),
      {
        'password': '[hidden]',
        'apiKey': '[hidden]',
        'Cookie': '[hidden]',
        'n': 1,
      },
    );
  });

  test('the log rotates and keeps at most two files', () async {
    final log = await AppLog.open(dir, maxBytes: 200);
    for (var i = 0; i < 30; i++) {
      logInfo('test', 'line $i ${'x' * 40}');
    }
    final text = await log.read();
    expect(text, contains('line 29'));
    expect(text, isNot(contains('line 0 ')));
    expect(
      dir.listSync().whereType<File>().map((f) => f.path).toList()
        ..retainWhere((p) => p.endsWith('.log')),
      hasLength(2),
    );
  });

  test('a session that did not end is reported on the next start', () async {
    final log = await AppLog.open(dir);
    expect(await log.startSession(), isNull);
    await log.setSessionState('download', {
      'workId': 5,
      'title': 'Book',
      'done': 108,
      'total': 138,
    });
    // No endSession: the app was killed.
    final next = await AppLog.open(dir);
    final unfinished = await next.startSession();
    expect((unfinished!['download'] as Map)['done'], 108);
    expect(await next.read(), contains('ended unexpectedly during a download'));

    await next.endSession();
    expect(await (await AppLog.open(dir)).startSession(), isNull);
  });

  test('export names the app version', () async {
    final log = await AppLog.open(dir);
    logInfo('test', 'hello');
    final file = await log.export(File('${dir.path}/out/x.log'));
    final text = await file.readAsString();
    expect(text, startsWith('ReadTrack $kAppVersion'));
    expect(text, contains('hello'));
    await log.clear();
    expect(await log.read(), isEmpty);
  });

  test('kAppVersion matches pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(
      RegExp(r'^version: (\S+)$', multiLine: true).firstMatch(pubspec)![1],
      kAppVersion,
    );
  });
}
