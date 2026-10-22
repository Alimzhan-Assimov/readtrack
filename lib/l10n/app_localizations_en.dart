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
}
