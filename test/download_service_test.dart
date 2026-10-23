import 'dart:io';

import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readtrack/data/database.dart';
import 'package:readtrack/library/download_service.dart';
import 'package:readtrack/library/exporters.dart';
import 'package:readtrack/library/storage.dart';
import 'package:readtrack/sources/sources.dart';

import 'sources/fake_fetcher.dart';

/// A site with five chapters; chapter 5 is locked and chapter 2 has an image.
class _FakeSource extends StorySource {
  const _FakeSource();

  @override
  String get name => 'Fake';

  @override
  List<String> get hosts => const ['fake.test'];

  @override
  FetchMode get fetchMode => FetchMode.http;

  @override
  Uri? storyUrl(Uri uri) => uri;

  @override
  Future<StoryInfo> fetchStory(Uri storyUrl, PageFetcher fetcher) =>
      throw UnimplementedError();

  @override
  Future<ChapterContent> fetchChapter(
    ChapterRef chapter,
    PageFetcher fetcher,
  ) async {
    final image = chapter.number == 2
        ? '<img src="https://fake.test/map.png">'
        : '';
    return ChapterContent(
      title: chapter.title,
      html: '<p>Text of chapter ${chapter.number}.</p>$image',
    );
  }
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late LibraryStorage storage;
  late DownloadService service;
  late Work work;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    final temp = Directory.systemTemp.createTempSync('readtrack_dl');
    addTearDown(() => temp.delete(recursive: true));
    storage = LibraryStorage(
      dataDir: Directory('${temp.path}/books'),
      exportDir: Directory('${temp.path}/exports'),
    );
    final png = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
    service = DownloadService(
      db,
      storage,
      openFetcherFor: (_) =>
          FakeFetcher(const {}, bytes: {'https://fake.test/map.png': png}),
    );
    final id = await db.saveWork(
      WorksCompanion.insert(
        type: WorkType.fanfiction,
        format: WorkFormat.online,
        title: 'Kingdom: Rise',
        author: const Value('Someone'),
        sourceUrl: const Value('https://fake.test/story'),
      ),
    );
    await db.saveChapterList(id, [
      for (var n = 1; n <= 5; n++)
        (
          number: n,
          title: 'Chapter $n',
          url: 'https://fake.test/$n',
          locked: n == 5,
        ),
    ]);
    work = (await db.watchWork(id).first)!.work;
  });

  tearDown(() => db.close());

  test(
    'downloads a range, saves images locally and exports a TXT file',
    () async {
      final result = await service.download(
        work: work,
        source: const _FakeSource(),
        from: 1,
        to: 3,
      );

      expect(result.downloaded, 3);
      expect(result.cancelled, isFalse);
      final file = result.file!;
      expect(file.path, endsWith('Kingdom Rise (Chapters 1–3).txt'));
      final txt = file.readAsStringSync();
      expect(txt, contains('Kingdom: Rise\nby Someone'));
      expect(
        txt,
        contains('Chapter 2\n${'=' * 60}\n\nText of chapter 2.\n\n[Image]'),
      );
      expect(txt, isNot(contains('Text of chapter 4')));

      final chapter2 = (await db.chaptersOf(work.id))[1];
      expect(
        chapter2.content,
        matches(RegExp(r'<img src="images/[0-9a-f]+\.png">')),
      );
      final download = (await db.downloadsOf(work.id)).single;
      expect(
        (download.fromChapter, download.toChapter, download.filePath),
        (1, 3, file.path),
      );
    },
  );

  test('new chapters can extend a download or become a new file', () async {
    await service.download(
      work: work,
      source: const _FakeSource(),
      from: 1,
      to: 3,
    );
    final first = (await db.downloadsOf(work.id)).single;

    // Extend 1–3 to 1–4: the file is renamed, nothing is fetched twice.
    final appended = await service.download(
      work: work,
      source: const _FakeSource(),
      from: 4,
      to: 4,
      appendTo: first,
    );
    expect(appended.downloaded, 1);
    expect(File(first.filePath!).existsSync(), isFalse);
    expect(appended.file!.path, endsWith('(Chapters 1–4).txt'));
    expect((await db.downloadsOf(work.id)).single.toChapter, 4);

    // A separate file for 4–5; the locked chapter 5 is skipped.
    final separate = await service.download(
      work: work,
      source: const _FakeSource(),
      from: 4,
      to: 5,
    );
    expect(separate.downloaded, 0);
    expect(separate.locked, 1);
    expect(
      separate.file!.readAsStringSync(),
      contains('[This chapter is locked on the site.]'),
    );
    expect(
      [
        for (final d in await db.downloadsOf(work.id))
          '${d.fromChapter}-${d.toChapter}',
      ],
      ['1-4', '4-5'],
    );
  });

  test('deleting a download forgets text no other download covers', () async {
    await service.download(
      work: work,
      source: const _FakeSource(),
      from: 1,
      to: 2,
    );
    await service.download(
      work: work,
      source: const _FakeSource(),
      from: 3,
      to: 4,
    );
    final second = (await db.downloadsOf(work.id)).last;

    await db.deleteDownload(second.id);
    await db.purgeUncoveredText(work.id);

    final stored = [
      for (final c in await db.chaptersOf(work.id)) c.content != null,
    ];
    expect(stored, [true, true, false, false, false]);
  });

  test('downloads in the chosen format; extending keeps it', () async {
    final first = await service.download(
      work: work,
      source: const _FakeSource(),
      from: 1,
      to: 2,
      format: ExportFormat.epub,
    );
    expect(first.file!.path, endsWith('(Chapters 1–2).epub'));
    final download = (await db.downloadsOf(work.id)).single;
    expect(download.format, 'epub');

    final extended = await service.download(
      work: work,
      source: const _FakeSource(),
      from: 3,
      to: 3,
      appendTo: download,
      format: ExportFormat.txt, // ignored when extending
    );
    expect(extended.file!.path, endsWith('(Chapters 1–3).epub'));

    final copy = await service.exportAs(
      (await db.downloadsOf(work.id)).single,
      ExportFormat.fb2,
    );
    expect(copy.path, endsWith('(Chapters 1–3).fb2'));
    expect((await db.downloadsOf(work.id)).single.format, 'epub');
  });
}
