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
  String deletedMessage(String title) {
    return 'Deleted “$title”';
  }

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
  String openFileFormat(String format) {
    return 'Open $format file';
  }

  @override
  String get deleteDownload => 'Delete download';

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
      'A browser window opens briefly to load this site.';

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
}
