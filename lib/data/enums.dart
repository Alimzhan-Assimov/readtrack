/// In welcher Form ein Werk vorliegt.
enum WorkFormat {
  physical('Physisch'),
  digital('Digital'),
  online('Online');

  const WorkFormat(this.label);
  final String label;
}

/// Art des Werks. Bestimmt, welches Format beim Anlegen vorausgewählt ist.
enum WorkType {
  book('Buch', WorkFormat.physical),
  fanfiction('Fanfiction', WorkFormat.online),
  webnovel('Webnovel', WorkFormat.online),
  manga('Manga', WorkFormat.physical),
  comic('Comic', WorkFormat.physical);

  const WorkType(this.label, this.defaultFormat);
  final String label;
  final WorkFormat defaultFormat;
}

enum ReadingStatus {
  planned('Will ich lesen'),
  reading('Lese ich gerade'),
  finished('Gelesen'),
  paused('Pausiert'),
  dropped('Abgebrochen');

  const ReadingStatus(this.label);
  final String label;
}

enum WorkSort {
  updated('Zuletzt geändert'),
  added('Zuletzt hinzugefügt'),
  title('Titel A–Z'),
  rating('Beste Bewertung');

  const WorkSort(this.label);
  final String label;
}
