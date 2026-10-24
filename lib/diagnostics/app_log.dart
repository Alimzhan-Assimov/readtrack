import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../version.dart';

enum LogLevel { info, warning, error }

/// A diagnostic log on disk, kept small: when the file passes [maxBytes] it
/// becomes `readtrack.1.log` and a new one starts, so at most two exist.
///
/// Logs only what helps find a fault: never passwords, keys, cookies or
/// chapter text. Values under sensitive keys are replaced, see [redact].
class AppLog {
  AppLog._(this.dir, {this.maxBytes = 512 * 1024});

  /// The app's log; does nothing until [open] is called (e.g. in tests).
  static AppLog? instance;

  static Future<AppLog> open(Directory dir, {int maxBytes = 512 * 1024}) async {
    await dir.create(recursive: true);
    return instance = AppLog._(dir, maxBytes: maxBytes);
  }

  final Directory dir;
  final int maxBytes;
  Future<void> _queue = Future.value();

  File get file => File(p.join(dir.path, 'readtrack.log'));
  File get _older => File(p.join(dir.path, 'readtrack.1.log'));
  File get _session => File(p.join(dir.path, 'session.json'));

  /// Writes one line. Calls are queued so lines never interleave.
  Future<void> write(
    LogLevel level,
    String category,
    String message, {
    Map<String, Object?> context = const {},
    Object? error,
    StackTrace? stack,
  }) {
    final line = StringBuffer()
      ..write(DateTime.now().toIso8601String())
      ..write(' ${level.name.toUpperCase().padRight(7)} [$category] $message');
    final fields = redact(context);
    if (fields.isNotEmpty) line.write(' ${jsonEncode(fields)}');
    if (error != null) line.write('\n  error: ${_oneLine('$error')}');
    if (stack != null) {
      line.write('\n  ${'$stack'.trimRight().replaceAll('\n', '\n  ')}');
    }
    line.write('\n');
    return _queue = _queue.then((_) => _append('$line')).catchError((_) {});
  }

  Future<void> _append(String text) async {
    if (await file.exists() && await file.length() > maxBytes) {
      await file.rename(_older.path);
    }
    await file.writeAsString(text, mode: FileMode.append, flush: true);
  }

  /// Both files, oldest first.
  Future<String> read() async {
    await _queue;
    final buffer = StringBuffer();
    for (final f in [_older, file]) {
      if (await f.exists()) buffer.write(await f.readAsString());
    }
    return '$buffer';
  }

  /// Copies the log to [target], with a header naming the app version.
  Future<File> export(File target) async {
    await target.parent.create(recursive: true);
    return target.writeAsString(
      'ReadTrack $kAppVersion · ${Platform.operatingSystem} '
      '${Platform.operatingSystemVersion}\n\n${await read()}',
    );
  }

  Future<void> clear() async {
    await _queue;
    for (final f in [_older, file]) {
      if (await f.exists()) await f.delete();
    }
  }

  /// Starts a session and returns what the previous one left behind if it
  /// didn't end normally (it is then logged too), otherwise null.
  Future<Map<String, Object?>?> startSession() async {
    Map<String, Object?>? unfinished;
    if (await _session.exists()) {
      try {
        unfinished = (jsonDecode(await _session.readAsString()) as Map)
            .cast<String, Object?>();
      } on FormatException {
        unfinished = const {};
      }
      await write(
        LogLevel.error,
        'session',
        unfinished['download'] == null
            ? 'The previous session ended unexpectedly'
            : 'The previous session ended unexpectedly during a download',
        context: unfinished,
      );
    }
    _state = {'started': DateTime.now().toIso8601String()};
    await _saveSession();
    await write(
      LogLevel.info,
      'session',
      'ReadTrack $kAppVersion started',
      context: {'os': Platform.operatingSystem},
    );
    return unfinished;
  }

  Map<String, Object?> _state = {};

  /// Records what is running, so a crash can be traced on the next start.
  /// Pass null to clear it.
  Future<void> setSessionState(String key, Map<String, Object?>? value) {
    if (value == null) {
      _state.remove(key);
    } else {
      _state[key] = redact(value);
    }
    return _saveSession();
  }

  Future<void> _saveSession() => _queue = _queue
      .then((_) => _session.writeAsString(jsonEncode(_state), flush: true))
      .catchError((_) => _session);

  /// Marks the session as ended normally.
  Future<void> endSession() async {
    await write(LogLevel.info, 'session', 'ReadTrack closed');
    await _queue;
    if (await _session.exists()) await _session.delete();
  }

  static final _sensitive = RegExp(
    r'pass|secret|token|cookie|auth|key|session',
    caseSensitive: false,
  );

  /// Drops values whose key looks sensitive, and query strings from URLs
  /// (they can carry tokens).
  static Map<String, Object?> redact(Map<String, Object?> fields) => {
    for (final MapEntry(:key, :value) in fields.entries)
      key: _sensitive.hasMatch(key)
          ? '[hidden]'
          : value is String && value.startsWith('http')
          ? value.split('?').first
          : value,
  };

  static String _oneLine(String text) =>
      text.length > 2000 ? '${text.substring(0, 2000)}…' : text;
}

/// Shorthands that write to [AppLog.instance] if there is one.
void logInfo(String category, String message, [Map<String, Object?>? ctx]) =>
    AppLog.instance?.write(
      LogLevel.info,
      category,
      message,
      context: ctx ?? const {},
    );

void logWarning(
  String category,
  String message, {
  Map<String, Object?> context = const {},
  Object? error,
}) => AppLog.instance?.write(
  LogLevel.warning,
  category,
  message,
  context: context,
  error: error,
);

void logError(
  String category,
  String message, {
  Map<String, Object?> context = const {},
  Object? error,
  StackTrace? stack,
}) => AppLog.instance?.write(
  LogLevel.error,
  category,
  message,
  context: context,
  error: error,
  stack: stack,
);
