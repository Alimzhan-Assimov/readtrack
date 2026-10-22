import '../data/database.dart';
import '../l10n/l10n.dart';

/// Short size info, e.g. "12 chapters", "45,300 words".
List<String> workStats(Work w, AppLocalizations l10n) => [
  if (w.chapterCount case final n?) l10n.chapterCount(n),
  if (w.wordCount case final n?) l10n.wordCount(n),
  if (w.pageCount case final n?) l10n.pageCount(n),
];

/// "https://www.fanfiction.net/s/123" -> "fanfiction.net"
String? siteName(String? url) {
  if (url == null) return null;
  final host = Uri.tryParse(url)?.host ?? '';
  if (host.isEmpty) return null;
  return host.startsWith('www.') ? host.substring(4) : host;
}
