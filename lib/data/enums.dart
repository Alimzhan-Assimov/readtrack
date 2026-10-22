// Display names live in lib/ui/labels.dart so they can be localized.

/// The form a work is available in.
enum WorkFormat { physical, digital, online }

/// What kind of work it is. Determines the preselected format.
enum WorkType {
  book(WorkFormat.physical),
  fanfiction(WorkFormat.online),
  webnovel(WorkFormat.online),
  manga(WorkFormat.physical),
  comic(WorkFormat.physical);

  const WorkType(this.defaultFormat);
  final WorkFormat defaultFormat;
}

enum ReadingStatus { planned, reading, finished, paused, dropped }

enum WorkSort { updated, added, title, rating }
