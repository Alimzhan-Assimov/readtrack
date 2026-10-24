// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ReadTrack';

  @override
  String get typeBook => 'Book';

  @override
  String get typeFanfiction => 'Fanfiction';

  @override
  String get typeWebnovel => 'Web novel';

  @override
  String get typeManga => 'Manga';

  @override
  String get typeComic => 'Comic';

  @override
  String get formatPhysical => 'Physical';

  @override
  String get formatDigital => 'Digital';

  @override
  String get formatOnline => 'Online';

  @override
  String get statusPlanned => 'Want to read';

  @override
  String get statusReading => 'Reading';

  @override
  String get statusFinished => 'Finished';

  @override
  String get statusPaused => 'On hold';

  @override
  String get statusDropped => 'Dropped';

  @override
  String get sortUpdated => 'Recently updated';

  @override
  String get sortAdded => 'Recently added';

  @override
  String get sortTitle => 'Title A–Z';

  @override
  String get sortRating => 'Highest rated';

  @override
  String chapterCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString chapters',
      one: '1 chapter',
    );
    return '$_temp0';
  }

  @override
  String wordCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString words',
      one: '1 word',
    );
    return '$_temp0';
  }

  @override
  String pageCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString pages',
      one: '1 page',
    );
    return '$_temp0';
  }

  @override
  String get libraryTitle => 'My Library';

  @override
  String get searchHint => 'Search title, author or category';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get sortTooltip => 'Sort';

  @override
  String get filterCategory => 'Category';

  @override
  String get filterTag => 'Tag';

  @override
  String get filterType => 'Type';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get filterAll => 'All';

  @override
  String get pickerEmpty => 'Nothing here yet';

  @override
  String entryCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString entries',
      one: '1 entry',
    );
    return '$_temp0';
  }

  @override
  String get addButton => 'Add';

  @override
  String get addTooltip => 'New entry (Ctrl+N)';

  @override
  String get emptyLibraryTitle => 'Your library is empty';

  @override
  String get emptyLibraryBody => 'Add your first book or fanfic with “Add”.';

  @override
  String get noResultsTitle => 'Nothing found';

  @override
  String get noResultsBody => 'Try different filters or search terms.';

  @override
  String get noSelection => 'Select an entry on the left';

  @override
  String errorMessage(Object error) {
    return 'Error: $error';
  }

  @override
  String get editTooltip => 'Edit';

  @override
  String get deleteTooltip => 'Delete';

  @override
  String get notFound => 'Entry not found';

  @override
  String get linkOpenFailed => 'Couldn\'t open the link';

  @override
  String get undo => 'Undo';

  @override
  String byAuthor(String author) {
    return 'by $author';
  }

  @override
  String get changeStatus => 'Change reading status';

  @override
  String get chaptersComplete => 'Chapters · complete';

  @override
  String get chaptersOngoing => 'Chapters · ongoing';

  @override
  String get sectionProgress => 'Reading progress';

  @override
  String chapterProgress(int current, int total) {
    return 'Chapter $current of $total';
  }

  @override
  String chapterCurrent(int current) {
    return 'Chapter $current';
  }

  @override
  String get previousChapter => 'Previous chapter';

  @override
  String get nextChapter => 'Next chapter';

  @override
  String get sectionLink => 'Link';

  @override
  String readOn(String site) {
    return 'Read on $site';
  }

  @override
  String get readOnline => 'Read online';

  @override
  String get sectionTags => 'Tags';

  @override
  String get sectionIsbn => 'ISBN';

  @override
  String get sectionSummary => 'Summary';

  @override
  String get sectionNotes => 'Notes';

  @override
  String addedUpdated(DateTime added, DateTime updated) {
    final intl.DateFormat addedDateFormat = intl.DateFormat.yMMMd(localeName);
    final String addedString = addedDateFormat.format(added);
    final intl.DateFormat updatedDateFormat = intl.DateFormat.yMMMd(localeName);
    final String updatedString = updatedDateFormat.format(updated);

    return 'Added $addedString · updated $updatedString';
  }

  @override
  String get newEntry => 'New entry';

  @override
  String get editEntry => 'Edit entry';

  @override
  String get save => 'Save';

  @override
  String get discardTitle => 'Discard changes?';

  @override
  String get discardBody => 'Your changes haven\'t been saved.';

  @override
  String get keepEditing => 'Keep editing';

  @override
  String get discard => 'Discard';

  @override
  String get numbersOnly => 'Numbers only';

  @override
  String get fieldType => 'Type';

  @override
  String get fieldTitle => 'Title *';

  @override
  String get titleRequired => 'Please enter a title';

  @override
  String get fieldAuthor => 'Author';

  @override
  String get fieldCategory => 'Category / fandom';

  @override
  String get fieldCategoryHint => 'e.g. Naruto, Harry Potter';

  @override
  String get fieldLink => 'Link';

  @override
  String get fieldLinkHint => 'https://www.fanfiction.net/s/…';

  @override
  String get invalidLink => 'Invalid link';

  @override
  String get fieldStatus => 'Reading status';

  @override
  String get sectionLength => 'Length';

  @override
  String get fieldChapters => 'Chapters';

  @override
  String get fieldCurrentChapter => 'Read up to chapter';

  @override
  String get fieldWords => 'Words';

  @override
  String get fieldPages => 'Pages';

  @override
  String get completeTitle => 'Completed by the author';

  @override
  String get completeSubtitle => 'Off = the story is still being updated';

  @override
  String get fieldIsbn => 'ISBN';

  @override
  String get addTag => 'Add tag';

  @override
  String get addTagHint => 'e.g. Action, Harem, Kingdom Building';

  @override
  String get sectionRating => 'Rating';

  @override
  String starTooltip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stars',
      one: '1 star',
    );
    return '$_temp0';
  }

  @override
  String get sectionDescription => 'Description';

  @override
  String get fieldSummary => 'Summary';

  @override
  String get fieldNotes => 'Personal notes';

  @override
  String get cancel => 'Cancel';

  @override
  String get moreOptions => 'More options';

  @override
  String get addFromLink => 'From a link';

  @override
  String get addFromLinkHint =>
      'Fanfic, web novel or book page – details are filled in for you';

  @override
  String get addManually => 'Enter manually';

  @override
  String get addManuallyHint => 'For example a book on your shelf';

  @override
  String get importTitle => 'Add from link';

  @override
  String get importIntro =>
      'Paste the link to a story. ReadTrack loads its title, author, chapters and more, and you can check everything before saving.';

  @override
  String get importLinkLabel => 'Link to the story';

  @override
  String get importPaste => 'Paste';

  @override
  String importDetected(String site) {
    return 'Recognized: $site';
  }

  @override
  String get importFetch => 'Load details';

  @override
  String get importLoading => 'Loading…';

  @override
  String get importInvalidLink => 'That doesn\'t look like a link.';

  @override
  String get importUnsupported =>
      'This site isn\'t supported yet. You can still add the entry manually.';

  @override
  String get importAlreadyInLibrary => 'This story is already in your library.';

  @override
  String get importSupported => 'Supported sites';

  @override
  String get importBrowserNote =>
      'FanFiction.Net, Scribble Hub, WebNovel and sometimes AO3 and Royal Road are protected against bots. For them a small browser window opens while ReadTrack loads pages. If it shows a verification, solve it once.';

  @override
  String importedFrom(String site) {
    return 'Imported from $site';
  }

  @override
  String importedSummary(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString chapters found',
      one: '1 chapter found',
    );
    return '$_temp0 – check the details and save.';
  }

  @override
  String get sectionRead => 'Read';

  @override
  String get readOnlineInApp => 'Read online';

  @override
  String continueOnline(int chapter) {
    return 'Continue online · chapter $chapter';
  }

  @override
  String get loadChapterList => 'Load chapter list';

  @override
  String get checkForNewChapters => 'Check for new chapters';

  @override
  String newChaptersFound(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString new chapters',
      one: '1 new chapter',
    );
    return '$_temp0';
  }

  @override
  String get noNewChapters => 'No new chapters';

  @override
  String get downloadsHeading => 'Downloads';

  @override
  String get noDownloadsYet =>
      'Nothing downloaded yet. Downloads can be read offline.';

  @override
  String downloadRange(int from, int to) {
    return 'Chapters $from–$to';
  }

  @override
  String downloadSubtitle(String format, DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$format · updated $dateString';
  }

  @override
  String get readDownload => 'Read';

  @override
  String get openFile => 'Open file';

  @override
  String get logTitle => 'Diagnostic log';

  @override
  String get logHint =>
      'Errors and download problems, for bug reports. No passwords or book text.';

  @override
  String get logEmpty => 'Nothing logged yet.';

  @override
  String get copyLog => 'Copy log';

  @override
  String get exportLog => 'Save log as file';

  @override
  String get clearLog => 'Clear log';

  @override
  String get clearLogTitle => 'Clear the diagnostic log?';

  @override
  String logExported(String path) {
    return 'Log saved: $path';
  }

  @override
  String get showLog => 'Show log';

  @override
  String get crashNotice =>
      'ReadTrack didn\'t close normally last time. The log may show why.';

  @override
  String crashDuringDownload(String title, String done, String total) {
    return 'ReadTrack stopped unexpectedly while downloading “$title” ($done of $total chapters). Downloaded chapters are kept; start the download again to continue.';
  }

  @override
  String openFileFormat(String format) {
    return 'Open $format file';
  }

  @override
  String get deleteDownload => 'Delete download';

  @override
  String get downloadWithImages => 'Include images';

  @override
  String get downloadWithImagesHint =>
      'Off: only the text is downloaded and saved, which uses less data and space.';

  @override
  String get downloadKeepsImages => 'Images are included, as in this download.';

  @override
  String get downloadKeepsNoImages => 'Without images, as in this download.';

  @override
  String downloadIncomplete(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count chapters missing',
      one: '1 chapter missing',
    );
    return '$_temp0';
  }

  @override
  String get loadMissingChapters => 'Load missing chapters';

  @override
  String get downloadButton => 'Download…';

  @override
  String get downloadPreparing => 'Preparing download…';

  @override
  String downloadProgress(int current, int total) {
    final intl.NumberFormat currentNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String currentString = currentNumberFormat.format(current);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'Downloading chapter $currentString of $totalString…';
  }

  @override
  String downloadDone(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Downloaded $countString chapters',
      one: 'Downloaded 1 chapter',
      zero: 'Download updated',
    );
    return '$_temp0';
  }

  @override
  String downloadDoneWithErrors(int done, int failed) {
    final intl.NumberFormat doneNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String doneString = doneNumberFormat.format(done);
    final intl.NumberFormat failedNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String failedString = failedNumberFormat.format(failed);

    return 'Downloaded $doneString, $failedString failed';
  }

  @override
  String downloadCancelled(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Download cancelled after $countString chapters';
  }

  @override
  String get downloadTitle => 'Download chapters';

  @override
  String downloadChecking(String site) {
    return 'Checking $site for new chapters…';
  }

  @override
  String downloadCheckFailed(String error) {
    return 'Couldn\'t check for new chapters: $error';
  }

  @override
  String downloadAvailable(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString chapters available',
      one: '1 chapter available',
    );
    return '$_temp0';
  }

  @override
  String downloadNewChapters(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString of them are new',
      one: '1 of them is new',
    );
    return '$_temp0';
  }

  @override
  String downloadLockedNote(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$countString chapters are locked on the site and will be skipped.',
      one: '1 chapter is locked on the site and will be skipped.',
    );
    return '$_temp0';
  }

  @override
  String get downloadNoChapters => 'No chapters found on the site.';

  @override
  String get downloadUpToDate =>
      'All chapters are downloaded already. You can still create another file.';

  @override
  String downloadAppend(int from, int to, int newTo) {
    return 'Add to “Chapters $from–$to” → chapters $from–$newTo';
  }

  @override
  String get downloadNewFile => 'Create a new file';

  @override
  String get downloadFrom => 'From chapter';

  @override
  String get downloadTo => 'To chapter';

  @override
  String downloadMax(int count) {
    return 'Up to $count';
  }

  @override
  String get downloadStart => 'Download';

  @override
  String get readerChapters => 'Chapters';

  @override
  String get readerTextSize => 'Text size';

  @override
  String get readerSmaller => 'Smaller text';

  @override
  String get readerLarger => 'Larger text';

  @override
  String get readerOpenInBrowser => 'Open in browser';

  @override
  String readerPosition(int current, int total) {
    return '$current / $total';
  }

  @override
  String get readerLoading => 'Loading chapter…';

  @override
  String get readerBrowserHint =>
      'If a ReadTrack browser window opens, complete the website’s confirmation or sign-in there. Leave it open while reading or downloading.';

  @override
  String get readerRetry => 'Try again';

  @override
  String get readerNoChapters =>
      'No chapters yet. Load the chapter list first.';

  @override
  String get readerNoSource =>
      'This entry\'s site isn\'t supported for reading in the app.';

  @override
  String get readerLockedChapter => 'This chapter is locked on the site.';

  @override
  String get readerNotDownloaded => 'This chapter isn\'t downloaded.';

  @override
  String get readerLatestChapter => 'You\'ve reached the latest chapter.';

  @override
  String get readerEndOfDownload => 'End of this download.';

  @override
  String get sortStatus => 'By reading status';

  @override
  String get filterStatus => 'Status';

  @override
  String get chooseExisting => 'Choose from existing';

  @override
  String get pickTags => 'Choose tags';

  @override
  String get pickCategory => 'Choose a category';

  @override
  String get pickAuthor => 'Choose an author';

  @override
  String get pickerSearch => 'Search…';

  @override
  String get pickerDone => 'Done';

  @override
  String get frequentlyUsed => 'Frequently used:';

  @override
  String pickerAdd(String value) {
    return 'Add “$value”';
  }

  @override
  String get sectionPairings => 'Pairings';

  @override
  String get filterPairing => 'Pairing';

  @override
  String get addPairing => 'Add pairing';

  @override
  String get addPairingHint => 'e.g. Naruto/Hinata';

  @override
  String get pickPairings => 'Choose pairings';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get hideAdultTags => 'Hide 18+ tags';

  @override
  String get hideAdultTagsHint =>
      'Tags with adult content stay on your entries but are not shown.';

  @override
  String get adultTagsHeading => '18+ tags';

  @override
  String get adultTagsHint =>
      'Tags are marked automatically when they look like adult content or the site marks them. Tick or untick to correct it.';

  @override
  String hiddenAdultTags(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count hidden 18+ tags',
      one: '+1 hidden 18+ tag',
    );
    return '$_temp0';
  }

  @override
  String get exportAs => 'Export as…';

  @override
  String exportedAs(String format) {
    return 'Saved as $format';
  }

  @override
  String get downloadFormatHint =>
      'EPUB works in most e-book readers, FB2 in many Russian ones, HTML in any browser. Files are saved to ~/Documents/ReadTrack.';

  @override
  String get addFromFile => 'Import a file';

  @override
  String get addFromFileHint =>
      'EPUB, FB2, TXT or HTML you already have – read it in ReadTrack';

  @override
  String get bookFiles => 'Books';

  @override
  String importingFile(String name) {
    return 'Importing $name…';
  }

  @override
  String importedFile(String name) {
    return 'Imported $name';
  }

  @override
  String importFailed(String error) {
    return 'Couldn\'t import the file: $error';
  }

  @override
  String get readerSettings => 'Reading settings';

  @override
  String get readerFont => 'Font';

  @override
  String get readerFontSystem => 'System';

  @override
  String get readerFontSerif => 'Serif';

  @override
  String get readerFontSans => 'Sans';

  @override
  String get readerFontMono => 'Mono';

  @override
  String get readerLineSpacing => 'Line spacing';

  @override
  String get readerTheme => 'Theme';

  @override
  String get readerThemeApp => 'App';

  @override
  String get readerThemeLight => 'Light';

  @override
  String get readerThemeSepia => 'Sepia';

  @override
  String get readerThemeDark => 'Dark';

  @override
  String get readerThemeBlack => 'Night';

  @override
  String get readerJustify => 'Justify text';

  @override
  String get addBookmark => 'Add bookmark';

  @override
  String get bookmarkAdded => 'Bookmark added';

  @override
  String bookmarkAt(int percent) {
    return 'Bookmark at $percent %';
  }

  @override
  String get saveQuote => 'Save quote';

  @override
  String get quoteSaved => 'Quote saved';

  @override
  String get addNote => 'Add note';

  @override
  String get editNote => 'Edit note';

  @override
  String get noteSaved => 'Note saved';

  @override
  String get noteHint => 'Your thoughts…';

  @override
  String get annotationsTitle => 'Bookmarks, quotes & notes';

  @override
  String get annotationsEmpty =>
      'Nothing yet. Add a bookmark with the bookmark button, or select text to save a quote or note.';

  @override
  String showAllAnnotations(int count) {
    return 'Show all ($count)';
  }

  @override
  String get filterLength => 'Length';

  @override
  String atLeastWords(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '$countString+ words';
  }

  @override
  String get filterCompletion => 'Completion';

  @override
  String get completeOnly => 'Complete';

  @override
  String get ongoingOnly => 'Ongoing';

  @override
  String get saveShelf => 'Save as shelf';

  @override
  String get saveShelfTitle => 'Save these filters as a shelf';

  @override
  String get shelfNameHint => 'e.g. Long finished romance';

  @override
  String get openShelf => 'Show this shelf';

  @override
  String get deleteShelf => 'Delete shelf';

  @override
  String get showAsGrid => 'Show as grid';

  @override
  String get showAsList => 'Show as list';

  @override
  String get backupHeading => 'Backup';

  @override
  String get backupHint =>
      'Saves your whole library – entries, progress, notes and downloaded books – in one zip file.';

  @override
  String get createBackup => 'Create backup';

  @override
  String backupCreated(String path) {
    return 'Backup saved: $path';
  }

  @override
  String backupFailed(String error) {
    return 'Backup failed: $error';
  }

  @override
  String get backupFiles => 'ReadTrack backups';

  @override
  String get restoreBackup => 'Restore backup';

  @override
  String get restoreBackupTitle => 'Restore this backup?';

  @override
  String get restoreBackupWarning =>
      'Your current library is replaced by the backup. A copy of it is kept as \"before-restore\" in the app folder.';

  @override
  String get restoreReadyTitle => 'Backup ready';

  @override
  String get restoreReadyHint =>
      'Restart ReadTrack to finish restoring the backup.';

  @override
  String restoreFailed(String error) {
    return 'Could not restore the backup: $error';
  }

  @override
  String get later => 'Later';

  @override
  String get closeApp => 'Close ReadTrack';

  @override
  String get checkForUpdates => 'Check for new chapters';

  @override
  String updatesFound(int chapters, int works) {
    String _temp0 = intl.Intl.pluralLogic(
      chapters,
      locale: localeName,
      other: '$chapters new chapters',
      one: '1 new chapter',
    );
    String _temp1 = intl.Intl.pluralLogic(
      works,
      locale: localeName,
      other: '$works stories',
      one: '1 story',
    );
    return '$_temp0 in $_temp1';
  }

  @override
  String get noUpdatesFound => 'No new chapters';

  @override
  String updatesFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stories',
      one: '1 story',
    );
    return 'No new chapters found; $_temp0 could not be checked';
  }

  @override
  String newChaptersBadge(int count) {
    return '+$count new';
  }

  @override
  String get abandonedBadge => 'No update for over a year';

  @override
  String get abandonedShort => 'Abandoned?';

  @override
  String get checkOnStart => 'Check for new chapters on start';

  @override
  String get checkOnStartHint =>
      'Ongoing stories that update often are checked more often, finished ones about once a month. Sites that need a browser window are only checked from the story page.';

  @override
  String get updatesHeading => 'Updates';

  @override
  String saveFailed(String error) {
    return 'Could not save: $error';
  }

  @override
  String deleteTitle(String title) {
    return 'Delete “$title”?';
  }

  @override
  String get deleteToTrashHint =>
      'It goes to the trash in Settings, where you can restore it for six months.';

  @override
  String movedToTrash(String title) {
    return '“$title” moved to the trash';
  }

  @override
  String get trashTitle => 'Trash';

  @override
  String get trashHint =>
      'Deleted entries stay here for six months, then they are removed for good together with their downloaded files.';

  @override
  String get trashEmpty => 'The trash is empty';

  @override
  String trashDates(String deleted, String purge) {
    return 'Deleted $deleted · removed for good on $purge';
  }

  @override
  String trashCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries',
      one: '1 entry',
      zero: 'Empty',
    );
    return '$_temp0';
  }

  @override
  String get restore => 'Restore';

  @override
  String get deleteForever => 'Delete for good';

  @override
  String deleteForeverTitle(String title) {
    return 'Delete “$title” for good?';
  }

  @override
  String get emptyTrash => 'Empty trash';

  @override
  String emptyTrashTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Delete $count entries for good?',
      one: 'Delete 1 entry for good?',
    );
    return '$_temp0';
  }

  @override
  String get cannotUndo =>
      'Downloaded chapters and files are deleted too. This cannot be undone.';

  @override
  String get restoredFromTrash => 'Restored from the trash';
}
