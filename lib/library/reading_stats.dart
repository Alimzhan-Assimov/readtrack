import '../data/database.dart';

/// Words, time and chapters over some span.
class ReadingTotals {
  const ReadingTotals({this.words = 0, this.seconds = 0, this.chapters = 0});

  final int words;
  final int seconds;
  final int chapters;

  bool get isEmpty => words == 0 && seconds == 0 && chapters == 0;

  ReadingTotals operator +(ReadingTotals o) => ReadingTotals(
    words: words + o.words,
    seconds: seconds + o.seconds,
    chapters: chapters + o.chapters,
  );
}

/// One work's share of a year.
typedef WorkTotals = ({Work work, ReadingTotals totals});

/// Statistics worked out from the reading log.
class ReadingStats {
  ReadingStats(List<(ReadingDay, Work)> log, {required DateTime today})
    : today = DateTime(today.year, today.month, today.day) {
    for (final (day, work) in log) {
      final t = ReadingTotals(
        words: day.words,
        seconds: day.seconds,
        chapters: day.chapters,
      );
      _byDay[day.day] = (_byDay[day.day] ?? const ReadingTotals()) + t;
      final year = int.parse(day.day.substring(0, 4));
      final works = _byYearAndWork.putIfAbsent(year, () => {});
      final known = works[work.id];
      works[work.id] = (
        work: work,
        totals: (known?.totals ?? const ReadingTotals()) + t,
      );
    }
  }

  final DateTime today;
  final _byDay = <String, ReadingTotals>{};
  final _byYearAndWork = <int, Map<int, WorkTotals>>{};

  ReadingTotals on(DateTime day) =>
      _byDay[AppDatabase.dayKey(day)] ?? const ReadingTotals();

  /// The last [count] days, oldest first, ending today.
  List<(DateTime, ReadingTotals)> lastDays(int count) => [
    for (var i = count - 1; i >= 0; i--)
      (_shift(today, -i), on(_shift(today, -i))),
  ];

  ReadingTotals between(DateTime from, DateTime to) {
    var sum = const ReadingTotals();
    for (var d = from; !d.isAfter(to); d = _shift(d, 1)) {
      sum = sum + on(d);
    }
    return sum;
  }

  /// Since Monday.
  ReadingTotals get thisWeek =>
      between(_shift(today, 1 - today.weekday), today);

  ReadingTotals get thisMonth =>
      between(DateTime(today.year, today.month), today);

  ReadingTotals get thisYear => year(today.year);

  ReadingTotals year(int year) =>
      [for (final w in (_byYearAndWork[year] ?? const {}).values) w.totals]
          .fold(const ReadingTotals(), (a, b) => a + b);

  /// Days in a row with reading, up to today (or yesterday, so the streak
  /// isn't lost before today's reading).
  int get currentStreak {
    var day = on(today).isEmpty ? _shift(today, -1) : today;
    var n = 0;
    while (!on(day).isEmpty) {
      n++;
      day = _shift(day, -1);
    }
    return n;
  }

  int get longestStreak {
    final days =
        _byDay.entries
            .where((e) => !e.value.isEmpty)
            .map((e) => DateTime.parse(e.key))
            .toList()
          ..sort();
    var best = 0, run = 0;
    DateTime? previous;
    for (final d in days) {
      run = previous != null && _shift(previous, 1) == d ? run + 1 : 1;
      if (run > best) best = run;
      previous = d;
    }
    return best;
  }

  /// Years with reading, newest first.
  List<int> get years => _byYearAndWork.keys.toList()..sort((a, b) => b - a);

  int daysReadIn(int year) => _byDay.entries
      .where((e) => e.key.startsWith('$year-') && !e.value.isEmpty)
      .length;

  /// The works read most in [year], by words, then time.
  List<WorkTotals> topWorks(int year, {int count = 5}) {
    final works = (_byYearAndWork[year] ?? const {}).values.toList()
      ..sort((a, b) {
        final byWords = b.totals.words.compareTo(a.totals.words);
        return byWords != 0
            ? byWords
            : b.totals.seconds.compareTo(a.totals.seconds);
      });
    return works.take(count).toList();
  }

  // Calendar days, so a change to or from daylight saving time doesn't
  // skip or repeat one.
  static DateTime _shift(DateTime d, int days) =>
      DateTime(d.year, d.month, d.day + days);
}
