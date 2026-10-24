import 'package:flutter/material.dart';

import '../data/enums.dart';
import '../l10n/l10n.dart';

extension WorkTypeUi on WorkType {
  IconData get icon => switch (this) {
    WorkType.book => Icons.menu_book,
    WorkType.fanfiction => Icons.auto_stories,
    WorkType.webnovel => Icons.language,
    WorkType.manga => Icons.collections_bookmark,
    WorkType.comic => Icons.photo_album,
  };

  String label(AppLocalizations l10n) => switch (this) {
    WorkType.book => l10n.typeBook,
    WorkType.fanfiction => l10n.typeFanfiction,
    WorkType.webnovel => l10n.typeWebnovel,
    WorkType.manga => l10n.typeManga,
    WorkType.comic => l10n.typeComic,
  };
}

extension WorkFormatUi on WorkFormat {
  IconData get icon => switch (this) {
    WorkFormat.physical => Icons.shelves,
    WorkFormat.digital => Icons.tablet_android,
    WorkFormat.online => Icons.public,
  };

  String label(AppLocalizations l10n) => switch (this) {
    WorkFormat.physical => l10n.formatPhysical,
    WorkFormat.digital => l10n.formatDigital,
    WorkFormat.online => l10n.formatOnline,
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

  String label(AppLocalizations l10n) => switch (this) {
    ReadingStatus.planned => l10n.statusPlanned,
    ReadingStatus.reading => l10n.statusReading,
    ReadingStatus.finished => l10n.statusFinished,
    ReadingStatus.paused => l10n.statusPaused,
    ReadingStatus.dropped => l10n.statusDropped,
  };
}

extension WorkSortUi on WorkSort {
  String label(AppLocalizations l10n) => switch (this) {
    WorkSort.updated => l10n.sortUpdated,
    WorkSort.added => l10n.sortAdded,
    WorkSort.title => l10n.sortTitle,
    WorkSort.rating => l10n.sortRating,
    WorkSort.status => l10n.sortStatus,
  };
}
