import '../data/database.dart';
import '../sources/html_clean.dart';

/// Builds a plain-text book from downloaded chapters.
String buildTxt({
  required Work work,
  required List<Chapter> chapters,
  required int from,
  required int to,
  DateTime? now,
}) {
  final out = StringBuffer()..writeln(work.title);
  if (work.author != null) out.writeln('by ${work.author}');
  if (work.sourceUrl != null) out.writeln(work.sourceUrl);
  final date = (now ?? DateTime.now()).toIso8601String().substring(0, 10);
  out
    ..writeln(from == to ? 'Chapter $from' : 'Chapters $from–$to')
    ..writeln('Downloaded with ReadTrack on $date')
    ..writeln();
  if (work.summary != null) {
    out
      ..writeln(work.summary)
      ..writeln();
  }
  for (final chapter in chapters) {
    if (chapter.number < from || chapter.number > to) continue;
    final title = chapter.title ?? 'Chapter ${chapter.number}';
    out
      ..writeln()
      ..writeln('=' * 60)
      ..writeln(title)
      ..writeln('=' * 60)
      ..writeln();
    final content = chapter.content;
    out.writeln(
      content == null
          ? (chapter.isLocked
                ? '[This chapter is locked on the site.]'
                : '[This chapter could not be downloaded.]')
          : htmlToPlainText(content),
    );
  }
  return out.toString();
}
