import '../data/database.dart';

/// Counts reading in the app for the statistics: active time (the gaps
/// between scrolls and page turns, each at most [maxGap], so a reader left
/// open doesn't count), and each chapter read to the end once per session.
/// Writes as it goes, so a crash loses at most a minute.
class ReadingTracker {
  ReadingTracker(
    this._db,
    this.workId, {
    DateTime Function()? clock,
    this.maxGap = const Duration(minutes: 2),
  }) : _now = clock ?? DateTime.now;

  final AppDatabase _db;
  final int workId;
  final Duration maxGap;
  final DateTime Function() _now;

  DateTime? _last;
  var _pending = Duration.zero;
  final _credited = <int>{};

  /// The reader did something (scrolled, turned a page).
  Future<void> activity() async {
    final now = _now();
    final last = _last;
    _last = now;
    if (last == null) return;
    final gap = now.difference(last);
    if (gap > Duration.zero && gap <= maxGap) _pending += gap;
    if (_pending >= const Duration(minutes: 1)) await flush();
  }

  /// Chapter [number] with [words] words was read to the end.
  Future<void> chapterRead(int number, int words) async {
    if (!_credited.add(number)) return;
    await _db.addReading(workId, _now(), words: words, chapters: 1);
  }

  /// Writes the time counted so far.
  Future<void> flush() async {
    final seconds = _pending.inSeconds;
    if (seconds <= 0) return;
    _pending -= Duration(seconds: seconds);
    await _db.addReading(workId, _now(), seconds: seconds);
  }

  /// The app went to the background: stop the clock until the next activity.
  Future<void> pause() async {
    _last = null;
    await flush();
  }
}
