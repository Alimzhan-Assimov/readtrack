import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'ReadTrack'**
  String get appTitle;

  /// No description provided for @typeBook.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get typeBook;

  /// No description provided for @typeFanfiction.
  ///
  /// In en, this message translates to:
  /// **'Fanfiction'**
  String get typeFanfiction;

  /// No description provided for @typeWebnovel.
  ///
  /// In en, this message translates to:
  /// **'Web novel'**
  String get typeWebnovel;

  /// No description provided for @typeManga.
  ///
  /// In en, this message translates to:
  /// **'Manga'**
  String get typeManga;

  /// No description provided for @typeComic.
  ///
  /// In en, this message translates to:
  /// **'Comic'**
  String get typeComic;

  /// No description provided for @formatPhysical.
  ///
  /// In en, this message translates to:
  /// **'Physical'**
  String get formatPhysical;

  /// No description provided for @formatDigital.
  ///
  /// In en, this message translates to:
  /// **'Digital'**
  String get formatDigital;

  /// No description provided for @formatOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get formatOnline;

  /// No description provided for @statusPlanned.
  ///
  /// In en, this message translates to:
  /// **'Want to read'**
  String get statusPlanned;

  /// No description provided for @statusReading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get statusReading;

  /// No description provided for @statusFinished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get statusFinished;

  /// No description provided for @statusPaused.
  ///
  /// In en, this message translates to:
  /// **'On hold'**
  String get statusPaused;

  /// No description provided for @statusDropped.
  ///
  /// In en, this message translates to:
  /// **'Dropped'**
  String get statusDropped;

  /// No description provided for @sortUpdated.
  ///
  /// In en, this message translates to:
  /// **'Recently updated'**
  String get sortUpdated;

  /// No description provided for @sortAdded.
  ///
  /// In en, this message translates to:
  /// **'Recently added'**
  String get sortAdded;

  /// No description provided for @sortTitle.
  ///
  /// In en, this message translates to:
  /// **'Title A–Z'**
  String get sortTitle;

  /// No description provided for @sortRating.
  ///
  /// In en, this message translates to:
  /// **'Highest rated'**
  String get sortRating;

  /// No description provided for @chapterCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 chapter} other{{count} chapters}}'**
  String chapterCount(int count);

  /// No description provided for @wordCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 word} other{{count} words}}'**
  String wordCount(int count);

  /// No description provided for @pageCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 page} other{{count} pages}}'**
  String pageCount(int count);

  /// No description provided for @libraryTitle.
  ///
  /// In en, this message translates to:
  /// **'My Library'**
  String get libraryTitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search title, author or category'**
  String get searchHint;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @sortTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sortTooltip;

  /// No description provided for @filterCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get filterCategory;

  /// No description provided for @filterTag.
  ///
  /// In en, this message translates to:
  /// **'Tag'**
  String get filterTag;

  /// No description provided for @filterType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get filterType;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @pickerEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get pickerEmpty;

  /// No description provided for @entryCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 entry} other{{count} entries}}'**
  String entryCount(int count);

  /// No description provided for @addButton.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addButton;

  /// No description provided for @addTooltip.
  ///
  /// In en, this message translates to:
  /// **'New entry (Ctrl+N)'**
  String get addTooltip;

  /// No description provided for @emptyLibraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Your library is empty'**
  String get emptyLibraryTitle;

  /// No description provided for @emptyLibraryBody.
  ///
  /// In en, this message translates to:
  /// **'Add your first book or fanfic with “Add”.'**
  String get emptyLibraryBody;

  /// No description provided for @noResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing found'**
  String get noResultsTitle;

  /// No description provided for @noResultsBody.
  ///
  /// In en, this message translates to:
  /// **'Try different filters or search terms.'**
  String get noResultsBody;

  /// No description provided for @noSelection.
  ///
  /// In en, this message translates to:
  /// **'Select an entry on the left'**
  String get noSelection;

  /// No description provided for @errorMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorMessage(Object error);

  /// No description provided for @editTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editTooltip;

  /// No description provided for @deleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteTooltip;

  /// No description provided for @notFound.
  ///
  /// In en, this message translates to:
  /// **'Entry not found'**
  String get notFound;

  /// No description provided for @linkOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the link'**
  String get linkOpenFailed;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @byAuthor.
  ///
  /// In en, this message translates to:
  /// **'by {author}'**
  String byAuthor(String author);

  /// No description provided for @changeStatus.
  ///
  /// In en, this message translates to:
  /// **'Change reading status'**
  String get changeStatus;

  /// No description provided for @chaptersComplete.
  ///
  /// In en, this message translates to:
  /// **'Chapters · complete'**
  String get chaptersComplete;

  /// No description provided for @chaptersOngoing.
  ///
  /// In en, this message translates to:
  /// **'Chapters · ongoing'**
  String get chaptersOngoing;

  /// No description provided for @sectionProgress.
  ///
  /// In en, this message translates to:
  /// **'Reading progress'**
  String get sectionProgress;

  /// No description provided for @chapterProgress.
  ///
  /// In en, this message translates to:
  /// **'Chapter {current} of {total}'**
  String chapterProgress(int current, int total);

  /// No description provided for @chapterCurrent.
  ///
  /// In en, this message translates to:
  /// **'Chapter {current}'**
  String chapterCurrent(int current);

  /// No description provided for @previousChapter.
  ///
  /// In en, this message translates to:
  /// **'Previous chapter'**
  String get previousChapter;

  /// No description provided for @nextChapter.
  ///
  /// In en, this message translates to:
  /// **'Next chapter'**
  String get nextChapter;

  /// No description provided for @sectionLink.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get sectionLink;

  /// No description provided for @readOn.
  ///
  /// In en, this message translates to:
  /// **'Read on {site}'**
  String readOn(String site);

  /// No description provided for @readOnline.
  ///
  /// In en, this message translates to:
  /// **'Read online'**
  String get readOnline;

  /// No description provided for @sectionTags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get sectionTags;

  /// No description provided for @sectionIsbn.
  ///
  /// In en, this message translates to:
  /// **'ISBN'**
  String get sectionIsbn;

  /// No description provided for @sectionSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get sectionSummary;

  /// No description provided for @sectionNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get sectionNotes;

  /// No description provided for @addedUpdated.
  ///
  /// In en, this message translates to:
  /// **'Added {added} · updated {updated}'**
  String addedUpdated(DateTime added, DateTime updated);

  /// No description provided for @newEntry.
  ///
  /// In en, this message translates to:
  /// **'New entry'**
  String get newEntry;

  /// No description provided for @editEntry.
  ///
  /// In en, this message translates to:
  /// **'Edit entry'**
  String get editEntry;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @discardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get discardTitle;

  /// No description provided for @discardBody.
  ///
  /// In en, this message translates to:
  /// **'Your changes haven\'t been saved.'**
  String get discardBody;

  /// No description provided for @keepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get keepEditing;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @numbersOnly.
  ///
  /// In en, this message translates to:
  /// **'Numbers only'**
  String get numbersOnly;

  /// No description provided for @fieldType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get fieldType;

  /// No description provided for @fieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Title *'**
  String get fieldTitle;

  /// No description provided for @titleRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get titleRequired;

  /// No description provided for @fieldAuthor.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get fieldAuthor;

  /// No description provided for @fieldCategory.
  ///
  /// In en, this message translates to:
  /// **'Category / fandom'**
  String get fieldCategory;

  /// No description provided for @fieldCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Naruto, Harry Potter'**
  String get fieldCategoryHint;

  /// No description provided for @fieldLink.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get fieldLink;

  /// No description provided for @fieldLinkHint.
  ///
  /// In en, this message translates to:
  /// **'https://www.fanfiction.net/s/…'**
  String get fieldLinkHint;

  /// No description provided for @invalidLink.
  ///
  /// In en, this message translates to:
  /// **'Invalid link'**
  String get invalidLink;

  /// No description provided for @fieldStatus.
  ///
  /// In en, this message translates to:
  /// **'Reading status'**
  String get fieldStatus;

  /// No description provided for @sectionLength.
  ///
  /// In en, this message translates to:
  /// **'Length'**
  String get sectionLength;

  /// No description provided for @fieldChapters.
  ///
  /// In en, this message translates to:
  /// **'Chapters'**
  String get fieldChapters;

  /// No description provided for @fieldCurrentChapter.
  ///
  /// In en, this message translates to:
  /// **'Read up to chapter'**
  String get fieldCurrentChapter;

  /// No description provided for @fieldWords.
  ///
  /// In en, this message translates to:
  /// **'Words'**
  String get fieldWords;

  /// No description provided for @fieldPages.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get fieldPages;

  /// No description provided for @completeTitle.
  ///
  /// In en, this message translates to:
  /// **'Completed by the author'**
  String get completeTitle;

  /// No description provided for @completeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Off = the story is still being updated'**
  String get completeSubtitle;

  /// No description provided for @fieldIsbn.
  ///
  /// In en, this message translates to:
  /// **'ISBN'**
  String get fieldIsbn;

  /// No description provided for @addTag.
  ///
  /// In en, this message translates to:
  /// **'Add tag'**
  String get addTag;

  /// No description provided for @addTagHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Action, Harem, Kingdom Building'**
  String get addTagHint;

  /// No description provided for @sectionRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get sectionRating;

  /// No description provided for @starTooltip.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 star} other{{count} stars}}'**
  String starTooltip(int count);

  /// No description provided for @sectionDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get sectionDescription;

  /// No description provided for @fieldSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get fieldSummary;

  /// No description provided for @fieldNotes.
  ///
  /// In en, this message translates to:
  /// **'Personal notes'**
  String get fieldNotes;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @moreOptions.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get moreOptions;

  /// No description provided for @addFromLink.
  ///
  /// In en, this message translates to:
  /// **'From a link'**
  String get addFromLink;

  /// No description provided for @addFromLinkHint.
  ///
  /// In en, this message translates to:
  /// **'Fanfic, web novel or book page – details are filled in for you'**
  String get addFromLinkHint;

  /// No description provided for @addManually.
  ///
  /// In en, this message translates to:
  /// **'Enter manually'**
  String get addManually;

  /// No description provided for @addManuallyHint.
  ///
  /// In en, this message translates to:
  /// **'For example a book on your shelf'**
  String get addManuallyHint;

  /// No description provided for @importTitle.
  ///
  /// In en, this message translates to:
  /// **'Add from link'**
  String get importTitle;

  /// No description provided for @importIntro.
  ///
  /// In en, this message translates to:
  /// **'Paste the link to a story. ReadTrack loads its title, author, chapters and more, and you can check everything before saving.'**
  String get importIntro;

  /// No description provided for @importLinkLabel.
  ///
  /// In en, this message translates to:
  /// **'Link to the story'**
  String get importLinkLabel;

  /// No description provided for @importPaste.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get importPaste;

  /// No description provided for @importDetected.
  ///
  /// In en, this message translates to:
  /// **'Recognized: {site}'**
  String importDetected(String site);

  /// No description provided for @importFetch.
  ///
  /// In en, this message translates to:
  /// **'Load details'**
  String get importFetch;

  /// No description provided for @importLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get importLoading;

  /// No description provided for @importInvalidLink.
  ///
  /// In en, this message translates to:
  /// **'That doesn\'t look like a link.'**
  String get importInvalidLink;

  /// No description provided for @importUnsupported.
  ///
  /// In en, this message translates to:
  /// **'This site isn\'t supported yet. You can still add the entry manually.'**
  String get importUnsupported;

  /// No description provided for @importAlreadyInLibrary.
  ///
  /// In en, this message translates to:
  /// **'This story is already in your library.'**
  String get importAlreadyInLibrary;

  /// No description provided for @importSupported.
  ///
  /// In en, this message translates to:
  /// **'Supported sites'**
  String get importSupported;

  /// No description provided for @importBrowserNote.
  ///
  /// In en, this message translates to:
  /// **'FanFiction.Net, Scribble Hub, WebNovel and sometimes AO3 and Royal Road are protected against bots. For them a small browser window opens while ReadTrack loads pages. If it shows a verification, solve it once.'**
  String get importBrowserNote;

  /// No description provided for @importedFrom.
  ///
  /// In en, this message translates to:
  /// **'Imported from {site}'**
  String importedFrom(String site);

  /// No description provided for @importedSummary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 chapter found} other{{count} chapters found}} – check the details and save.'**
  String importedSummary(int count);

  /// No description provided for @sectionRead.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get sectionRead;

  /// No description provided for @readOnlineInApp.
  ///
  /// In en, this message translates to:
  /// **'Read online'**
  String get readOnlineInApp;

  /// No description provided for @continueOnline.
  ///
  /// In en, this message translates to:
  /// **'Continue online · chapter {chapter}'**
  String continueOnline(int chapter);

  /// No description provided for @loadChapterList.
  ///
  /// In en, this message translates to:
  /// **'Load chapter list'**
  String get loadChapterList;

  /// No description provided for @checkForNewChapters.
  ///
  /// In en, this message translates to:
  /// **'Check for new chapters'**
  String get checkForNewChapters;

  /// No description provided for @newChaptersFound.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 new chapter} other{{count} new chapters}}'**
  String newChaptersFound(int count);

  /// No description provided for @noNewChapters.
  ///
  /// In en, this message translates to:
  /// **'No new chapters'**
  String get noNewChapters;

  /// No description provided for @downloadsHeading.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get downloadsHeading;

  /// No description provided for @noDownloadsYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing downloaded yet. Downloads can be read offline.'**
  String get noDownloadsYet;

  /// No description provided for @downloadRange.
  ///
  /// In en, this message translates to:
  /// **'Chapters {from}–{to}'**
  String downloadRange(int from, int to);

  /// No description provided for @downloadSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{format} · updated {date}'**
  String downloadSubtitle(String format, DateTime date);

  /// No description provided for @readDownload.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get readDownload;

  /// No description provided for @openFile.
  ///
  /// In en, this message translates to:
  /// **'Open file'**
  String get openFile;

  /// No description provided for @logTitle.
  ///
  /// In en, this message translates to:
  /// **'Diagnostic log'**
  String get logTitle;

  /// No description provided for @logHint.
  ///
  /// In en, this message translates to:
  /// **'Errors and download problems, for bug reports. No passwords or book text.'**
  String get logHint;

  /// No description provided for @logEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing logged yet.'**
  String get logEmpty;

  /// No description provided for @copyLog.
  ///
  /// In en, this message translates to:
  /// **'Copy log'**
  String get copyLog;

  /// No description provided for @exportLog.
  ///
  /// In en, this message translates to:
  /// **'Save log as file'**
  String get exportLog;

  /// No description provided for @clearLog.
  ///
  /// In en, this message translates to:
  /// **'Clear log'**
  String get clearLog;

  /// No description provided for @clearLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear the diagnostic log?'**
  String get clearLogTitle;

  /// No description provided for @logExported.
  ///
  /// In en, this message translates to:
  /// **'Log saved: {path}'**
  String logExported(String path);

  /// No description provided for @showLog.
  ///
  /// In en, this message translates to:
  /// **'Show log'**
  String get showLog;

  /// No description provided for @crashNotice.
  ///
  /// In en, this message translates to:
  /// **'ReadTrack didn\'t close normally last time. The log may show why.'**
  String get crashNotice;

  /// No description provided for @crashDuringDownload.
  ///
  /// In en, this message translates to:
  /// **'ReadTrack stopped unexpectedly while downloading “{title}” ({done} of {total} chapters). Downloaded chapters are kept; start the download again to continue.'**
  String crashDuringDownload(String title, String done, String total);

  /// No description provided for @openFileFormat.
  ///
  /// In en, this message translates to:
  /// **'Open {format} file'**
  String openFileFormat(String format);

  /// No description provided for @deleteDownload.
  ///
  /// In en, this message translates to:
  /// **'Delete download'**
  String get deleteDownload;

  /// No description provided for @downloadIncomplete.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 chapter missing} other{{count} chapters missing}}'**
  String downloadIncomplete(int count);

  /// No description provided for @loadMissingChapters.
  ///
  /// In en, this message translates to:
  /// **'Load missing chapters'**
  String get loadMissingChapters;

  /// No description provided for @downloadButton.
  ///
  /// In en, this message translates to:
  /// **'Download…'**
  String get downloadButton;

  /// No description provided for @downloadPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing download…'**
  String get downloadPreparing;

  /// No description provided for @downloadProgress.
  ///
  /// In en, this message translates to:
  /// **'Downloading chapter {current} of {total}…'**
  String downloadProgress(int current, int total);

  /// No description provided for @downloadDone.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Download updated} =1{Downloaded 1 chapter} other{Downloaded {count} chapters}}'**
  String downloadDone(int count);

  /// No description provided for @downloadDoneWithErrors.
  ///
  /// In en, this message translates to:
  /// **'Downloaded {done}, {failed} failed'**
  String downloadDoneWithErrors(int done, int failed);

  /// No description provided for @downloadCancelled.
  ///
  /// In en, this message translates to:
  /// **'Download cancelled after {count} chapters'**
  String downloadCancelled(int count);

  /// No description provided for @downloadTitle.
  ///
  /// In en, this message translates to:
  /// **'Download chapters'**
  String get downloadTitle;

  /// No description provided for @downloadChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking {site} for new chapters…'**
  String downloadChecking(String site);

  /// No description provided for @downloadCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t check for new chapters: {error}'**
  String downloadCheckFailed(String error);

  /// No description provided for @downloadAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 chapter available} other{{count} chapters available}}'**
  String downloadAvailable(int count);

  /// No description provided for @downloadNewChapters.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 of them is new} other{{count} of them are new}}'**
  String downloadNewChapters(int count);

  /// No description provided for @downloadLockedNote.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 chapter is locked on the site and will be skipped.} other{{count} chapters are locked on the site and will be skipped.}}'**
  String downloadLockedNote(int count);

  /// No description provided for @downloadNoChapters.
  ///
  /// In en, this message translates to:
  /// **'No chapters found on the site.'**
  String get downloadNoChapters;

  /// No description provided for @downloadUpToDate.
  ///
  /// In en, this message translates to:
  /// **'All chapters are downloaded already. You can still create another file.'**
  String get downloadUpToDate;

  /// No description provided for @downloadAppend.
  ///
  /// In en, this message translates to:
  /// **'Add to “Chapters {from}–{to}” → chapters {from}–{newTo}'**
  String downloadAppend(int from, int to, int newTo);

  /// No description provided for @downloadNewFile.
  ///
  /// In en, this message translates to:
  /// **'Create a new file'**
  String get downloadNewFile;

  /// No description provided for @downloadFrom.
  ///
  /// In en, this message translates to:
  /// **'From chapter'**
  String get downloadFrom;

  /// No description provided for @downloadTo.
  ///
  /// In en, this message translates to:
  /// **'To chapter'**
  String get downloadTo;

  /// No description provided for @downloadMax.
  ///
  /// In en, this message translates to:
  /// **'Up to {count}'**
  String downloadMax(int count);

  /// No description provided for @downloadStart.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get downloadStart;

  /// No description provided for @readerChapters.
  ///
  /// In en, this message translates to:
  /// **'Chapters'**
  String get readerChapters;

  /// No description provided for @readerTextSize.
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get readerTextSize;

  /// No description provided for @readerSmaller.
  ///
  /// In en, this message translates to:
  /// **'Smaller text'**
  String get readerSmaller;

  /// No description provided for @readerLarger.
  ///
  /// In en, this message translates to:
  /// **'Larger text'**
  String get readerLarger;

  /// No description provided for @readerOpenInBrowser.
  ///
  /// In en, this message translates to:
  /// **'Open in browser'**
  String get readerOpenInBrowser;

  /// No description provided for @readerPosition.
  ///
  /// In en, this message translates to:
  /// **'{current} / {total}'**
  String readerPosition(int current, int total);

  /// No description provided for @readerLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading chapter…'**
  String get readerLoading;

  /// No description provided for @readerBrowserHint.
  ///
  /// In en, this message translates to:
  /// **'If a ReadTrack browser window opens, complete the website’s confirmation or sign-in there. Leave it open while reading or downloading.'**
  String get readerBrowserHint;

  /// No description provided for @readerRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get readerRetry;

  /// No description provided for @readerNoChapters.
  ///
  /// In en, this message translates to:
  /// **'No chapters yet. Load the chapter list first.'**
  String get readerNoChapters;

  /// No description provided for @readerNoSource.
  ///
  /// In en, this message translates to:
  /// **'This entry\'s site isn\'t supported for reading in the app.'**
  String get readerNoSource;

  /// No description provided for @readerLockedChapter.
  ///
  /// In en, this message translates to:
  /// **'This chapter is locked on the site.'**
  String get readerLockedChapter;

  /// No description provided for @readerNotDownloaded.
  ///
  /// In en, this message translates to:
  /// **'This chapter isn\'t downloaded.'**
  String get readerNotDownloaded;

  /// No description provided for @readerLatestChapter.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached the latest chapter.'**
  String get readerLatestChapter;

  /// No description provided for @readerEndOfDownload.
  ///
  /// In en, this message translates to:
  /// **'End of this download.'**
  String get readerEndOfDownload;

  /// No description provided for @sortStatus.
  ///
  /// In en, this message translates to:
  /// **'By reading status'**
  String get sortStatus;

  /// No description provided for @filterStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get filterStatus;

  /// No description provided for @chooseExisting.
  ///
  /// In en, this message translates to:
  /// **'Choose from existing'**
  String get chooseExisting;

  /// No description provided for @pickTags.
  ///
  /// In en, this message translates to:
  /// **'Choose tags'**
  String get pickTags;

  /// No description provided for @pickCategory.
  ///
  /// In en, this message translates to:
  /// **'Choose a category'**
  String get pickCategory;

  /// No description provided for @pickAuthor.
  ///
  /// In en, this message translates to:
  /// **'Choose an author'**
  String get pickAuthor;

  /// No description provided for @pickerSearch.
  ///
  /// In en, this message translates to:
  /// **'Search…'**
  String get pickerSearch;

  /// No description provided for @pickerDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get pickerDone;

  /// No description provided for @frequentlyUsed.
  ///
  /// In en, this message translates to:
  /// **'Frequently used:'**
  String get frequentlyUsed;

  /// No description provided for @pickerAdd.
  ///
  /// In en, this message translates to:
  /// **'Add “{value}”'**
  String pickerAdd(String value);

  /// No description provided for @sectionPairings.
  ///
  /// In en, this message translates to:
  /// **'Pairings'**
  String get sectionPairings;

  /// No description provided for @filterPairing.
  ///
  /// In en, this message translates to:
  /// **'Pairing'**
  String get filterPairing;

  /// No description provided for @addPairing.
  ///
  /// In en, this message translates to:
  /// **'Add pairing'**
  String get addPairing;

  /// No description provided for @addPairingHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Naruto/Hinata'**
  String get addPairingHint;

  /// No description provided for @pickPairings.
  ///
  /// In en, this message translates to:
  /// **'Choose pairings'**
  String get pickPairings;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @hideAdultTags.
  ///
  /// In en, this message translates to:
  /// **'Hide 18+ tags'**
  String get hideAdultTags;

  /// No description provided for @hideAdultTagsHint.
  ///
  /// In en, this message translates to:
  /// **'Tags with adult content stay on your entries but are not shown.'**
  String get hideAdultTagsHint;

  /// No description provided for @adultTagsHeading.
  ///
  /// In en, this message translates to:
  /// **'18+ tags'**
  String get adultTagsHeading;

  /// No description provided for @adultTagsHint.
  ///
  /// In en, this message translates to:
  /// **'Tags are marked automatically when they look like adult content or the site marks them. Tick or untick to correct it.'**
  String get adultTagsHint;

  /// No description provided for @hiddenAdultTags.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{+1 hidden 18+ tag} other{+{count} hidden 18+ tags}}'**
  String hiddenAdultTags(int count);

  /// No description provided for @exportAs.
  ///
  /// In en, this message translates to:
  /// **'Export as…'**
  String get exportAs;

  /// No description provided for @exportedAs.
  ///
  /// In en, this message translates to:
  /// **'Saved as {format}'**
  String exportedAs(String format);

  /// No description provided for @downloadFormatHint.
  ///
  /// In en, this message translates to:
  /// **'EPUB works in most e-book readers, FB2 in many Russian ones, HTML in any browser. Files are saved to ~/Documents/ReadTrack.'**
  String get downloadFormatHint;

  /// No description provided for @addFromFile.
  ///
  /// In en, this message translates to:
  /// **'Import a file'**
  String get addFromFile;

  /// No description provided for @addFromFileHint.
  ///
  /// In en, this message translates to:
  /// **'EPUB, FB2, TXT or HTML you already have – read it in ReadTrack'**
  String get addFromFileHint;

  /// No description provided for @bookFiles.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get bookFiles;

  /// No description provided for @importingFile.
  ///
  /// In en, this message translates to:
  /// **'Importing {name}…'**
  String importingFile(String name);

  /// No description provided for @importedFile.
  ///
  /// In en, this message translates to:
  /// **'Imported {name}'**
  String importedFile(String name);

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t import the file: {error}'**
  String importFailed(String error);

  /// No description provided for @readerSettings.
  ///
  /// In en, this message translates to:
  /// **'Reading settings'**
  String get readerSettings;

  /// No description provided for @readerFont.
  ///
  /// In en, this message translates to:
  /// **'Font'**
  String get readerFont;

  /// No description provided for @readerFontSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get readerFontSystem;

  /// No description provided for @readerFontSerif.
  ///
  /// In en, this message translates to:
  /// **'Serif'**
  String get readerFontSerif;

  /// No description provided for @readerFontSans.
  ///
  /// In en, this message translates to:
  /// **'Sans'**
  String get readerFontSans;

  /// No description provided for @readerFontMono.
  ///
  /// In en, this message translates to:
  /// **'Mono'**
  String get readerFontMono;

  /// No description provided for @readerLineSpacing.
  ///
  /// In en, this message translates to:
  /// **'Line spacing'**
  String get readerLineSpacing;

  /// No description provided for @readerTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get readerTheme;

  /// No description provided for @readerThemeApp.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get readerThemeApp;

  /// No description provided for @readerThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get readerThemeLight;

  /// No description provided for @readerThemeSepia.
  ///
  /// In en, this message translates to:
  /// **'Sepia'**
  String get readerThemeSepia;

  /// No description provided for @readerThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get readerThemeDark;

  /// No description provided for @readerThemeBlack.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get readerThemeBlack;

  /// No description provided for @readerJustify.
  ///
  /// In en, this message translates to:
  /// **'Justify text'**
  String get readerJustify;

  /// No description provided for @addBookmark.
  ///
  /// In en, this message translates to:
  /// **'Add bookmark'**
  String get addBookmark;

  /// No description provided for @bookmarkAdded.
  ///
  /// In en, this message translates to:
  /// **'Bookmark added'**
  String get bookmarkAdded;

  /// No description provided for @bookmarkAt.
  ///
  /// In en, this message translates to:
  /// **'Bookmark at {percent} %'**
  String bookmarkAt(int percent);

  /// No description provided for @saveQuote.
  ///
  /// In en, this message translates to:
  /// **'Save quote'**
  String get saveQuote;

  /// No description provided for @quoteSaved.
  ///
  /// In en, this message translates to:
  /// **'Quote saved'**
  String get quoteSaved;

  /// No description provided for @addNote.
  ///
  /// In en, this message translates to:
  /// **'Add note'**
  String get addNote;

  /// No description provided for @editNote.
  ///
  /// In en, this message translates to:
  /// **'Edit note'**
  String get editNote;

  /// No description provided for @noteSaved.
  ///
  /// In en, this message translates to:
  /// **'Note saved'**
  String get noteSaved;

  /// No description provided for @noteHint.
  ///
  /// In en, this message translates to:
  /// **'Your thoughts…'**
  String get noteHint;

  /// No description provided for @annotationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks, quotes & notes'**
  String get annotationsTitle;

  /// No description provided for @annotationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing yet. Add a bookmark with the bookmark button, or select text to save a quote or note.'**
  String get annotationsEmpty;

  /// No description provided for @showAllAnnotations.
  ///
  /// In en, this message translates to:
  /// **'Show all ({count})'**
  String showAllAnnotations(int count);

  /// No description provided for @filterLength.
  ///
  /// In en, this message translates to:
  /// **'Length'**
  String get filterLength;

  /// No description provided for @atLeastWords.
  ///
  /// In en, this message translates to:
  /// **'{count}+ words'**
  String atLeastWords(int count);

  /// No description provided for @filterCompletion.
  ///
  /// In en, this message translates to:
  /// **'Completion'**
  String get filterCompletion;

  /// No description provided for @completeOnly.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get completeOnly;

  /// No description provided for @ongoingOnly.
  ///
  /// In en, this message translates to:
  /// **'Ongoing'**
  String get ongoingOnly;

  /// No description provided for @saveShelf.
  ///
  /// In en, this message translates to:
  /// **'Save as shelf'**
  String get saveShelf;

  /// No description provided for @saveShelfTitle.
  ///
  /// In en, this message translates to:
  /// **'Save these filters as a shelf'**
  String get saveShelfTitle;

  /// No description provided for @shelfNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Long finished romance'**
  String get shelfNameHint;

  /// No description provided for @openShelf.
  ///
  /// In en, this message translates to:
  /// **'Show this shelf'**
  String get openShelf;

  /// No description provided for @deleteShelf.
  ///
  /// In en, this message translates to:
  /// **'Delete shelf'**
  String get deleteShelf;

  /// No description provided for @showAsGrid.
  ///
  /// In en, this message translates to:
  /// **'Show as grid'**
  String get showAsGrid;

  /// No description provided for @showAsList.
  ///
  /// In en, this message translates to:
  /// **'Show as list'**
  String get showAsList;

  /// No description provided for @backupHeading.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backupHeading;

  /// No description provided for @backupHint.
  ///
  /// In en, this message translates to:
  /// **'Saves your whole library – entries, progress, notes and downloaded books – in one zip file.'**
  String get backupHint;

  /// No description provided for @createBackup.
  ///
  /// In en, this message translates to:
  /// **'Create backup'**
  String get createBackup;

  /// No description provided for @backupCreated.
  ///
  /// In en, this message translates to:
  /// **'Backup saved: {path}'**
  String backupCreated(String path);

  /// No description provided for @backupFailed.
  ///
  /// In en, this message translates to:
  /// **'Backup failed: {error}'**
  String backupFailed(String error);

  /// No description provided for @backupFiles.
  ///
  /// In en, this message translates to:
  /// **'ReadTrack backups'**
  String get backupFiles;

  /// No description provided for @restoreBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore backup'**
  String get restoreBackup;

  /// No description provided for @restoreBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore this backup?'**
  String get restoreBackupTitle;

  /// No description provided for @restoreBackupWarning.
  ///
  /// In en, this message translates to:
  /// **'Your current library is replaced by the backup. A copy of it is kept as \"before-restore\" in the app folder.'**
  String get restoreBackupWarning;

  /// No description provided for @restoreReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup ready'**
  String get restoreReadyTitle;

  /// No description provided for @restoreReadyHint.
  ///
  /// In en, this message translates to:
  /// **'Restart ReadTrack to finish restoring the backup.'**
  String get restoreReadyHint;

  /// No description provided for @restoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not restore the backup: {error}'**
  String restoreFailed(String error);

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @closeApp.
  ///
  /// In en, this message translates to:
  /// **'Close ReadTrack'**
  String get closeApp;

  /// No description provided for @checkForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for new chapters'**
  String get checkForUpdates;

  /// No description provided for @updatesFound.
  ///
  /// In en, this message translates to:
  /// **'{chapters, plural, =1{1 new chapter} other{{chapters} new chapters}} in {works, plural, =1{1 story} other{{works} stories}}'**
  String updatesFound(int chapters, int works);

  /// No description provided for @noUpdatesFound.
  ///
  /// In en, this message translates to:
  /// **'No new chapters'**
  String get noUpdatesFound;

  /// No description provided for @updatesFailed.
  ///
  /// In en, this message translates to:
  /// **'No new chapters found; {count, plural, =1{1 story} other{{count} stories}} could not be checked'**
  String updatesFailed(int count);

  /// No description provided for @newChaptersBadge.
  ///
  /// In en, this message translates to:
  /// **'+{count} new'**
  String newChaptersBadge(int count);

  /// No description provided for @abandonedBadge.
  ///
  /// In en, this message translates to:
  /// **'No update for over a year'**
  String get abandonedBadge;

  /// No description provided for @abandonedShort.
  ///
  /// In en, this message translates to:
  /// **'Abandoned?'**
  String get abandonedShort;

  /// No description provided for @checkOnStart.
  ///
  /// In en, this message translates to:
  /// **'Check for new chapters on start'**
  String get checkOnStart;

  /// No description provided for @checkOnStartHint.
  ///
  /// In en, this message translates to:
  /// **'Ongoing stories that update often are checked more often, finished ones about once a month. Sites that need a browser window are only checked from the story page.'**
  String get checkOnStartHint;

  /// No description provided for @updatesHeading.
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get updatesHeading;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save: {error}'**
  String saveFailed(String error);

  /// No description provided for @deleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete “{title}”?'**
  String deleteTitle(String title);

  /// No description provided for @deleteToTrashHint.
  ///
  /// In en, this message translates to:
  /// **'It goes to the trash in Settings, where you can restore it for six months.'**
  String get deleteToTrashHint;

  /// No description provided for @movedToTrash.
  ///
  /// In en, this message translates to:
  /// **'“{title}” moved to the trash'**
  String movedToTrash(String title);

  /// No description provided for @trashTitle.
  ///
  /// In en, this message translates to:
  /// **'Trash'**
  String get trashTitle;

  /// No description provided for @trashHint.
  ///
  /// In en, this message translates to:
  /// **'Deleted entries stay here for six months, then they are removed for good together with their downloaded files.'**
  String get trashHint;

  /// No description provided for @trashEmpty.
  ///
  /// In en, this message translates to:
  /// **'The trash is empty'**
  String get trashEmpty;

  /// No description provided for @trashDates.
  ///
  /// In en, this message translates to:
  /// **'Deleted {deleted} · removed for good on {purge}'**
  String trashDates(String deleted, String purge);

  /// No description provided for @trashCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Empty} =1{1 entry} other{{count} entries}}'**
  String trashCount(int count);

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @deleteForever.
  ///
  /// In en, this message translates to:
  /// **'Delete for good'**
  String get deleteForever;

  /// No description provided for @deleteForeverTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete “{title}” for good?'**
  String deleteForeverTitle(String title);

  /// No description provided for @emptyTrash.
  ///
  /// In en, this message translates to:
  /// **'Empty trash'**
  String get emptyTrash;

  /// No description provided for @emptyTrashTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Delete 1 entry for good?} other{Delete {count} entries for good?}}'**
  String emptyTrashTitle(int count);

  /// No description provided for @cannotUndo.
  ///
  /// In en, this message translates to:
  /// **'Downloaded chapters and files are deleted too. This cannot be undone.'**
  String get cannotUndo;

  /// No description provided for @restoredFromTrash.
  ///
  /// In en, this message translates to:
  /// **'Restored from the trash'**
  String get restoredFromTrash;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
