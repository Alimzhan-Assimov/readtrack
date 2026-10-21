import 'package:flutter/material.dart';

import '../data/enums.dart';

extension WorkTypeUi on WorkType {
  IconData get icon => switch (this) {
    WorkType.book => Icons.menu_book,
    WorkType.fanfiction => Icons.auto_stories,
    WorkType.webnovel => Icons.language,
    WorkType.manga => Icons.collections_bookmark,
    WorkType.comic => Icons.photo_album,
  };
}

extension WorkFormatUi on WorkFormat {
  IconData get icon => switch (this) {
    WorkFormat.physical => Icons.shelves,
    WorkFormat.digital => Icons.tablet_android,
    WorkFormat.online => Icons.public,
  };
}

extension ReadingStatusUi on ReadingStatus {
  IconData get icon => switch (this) {
    ReadingStatus.planned => Icons.bookmark_border,
    ReadingStatus.reading => Icons.chrome_reader_mode_outlined,
    ReadingStatus.finished => Icons.check_circle_outline,
    ReadingStatus.paused => Icons.pause_circle_outline,
    ReadingStatus.dropped => Icons.cancel_outlined,
  };
}
