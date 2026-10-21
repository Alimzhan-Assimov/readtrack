import '../data/database.dart';

/// 45300 -> „45.300“
String formatNumber(int n) {
  final digits = n.abs().toString();
  final buffer = StringBuffer(n < 0 ? '-' : '');
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

String formatDate(DateTime d) {
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(d.day)}.${two(d.month)}.${d.year}';
}

/// Kurze Angaben zum Umfang, z. B. „12 Kapitel“, „45.300 Wörter“.
List<String> workStats(Work w) => [
  if (w.chapterCount != null) '${formatNumber(w.chapterCount!)} Kapitel',
  if (w.wordCount != null) '${formatNumber(w.wordCount!)} Wörter',
  if (w.pageCount != null) '${formatNumber(w.pageCount!)} Seiten',
];

/// „https://www.fanfiction.net/s/123“ -> „fanfiction.net“
String? siteName(String? url) {
  if (url == null) return null;
  final host = Uri.tryParse(url)?.host ?? '';
  if (host.isEmpty) return null;
  return host.startsWith('www.') ? host.substring(4) : host;
}
