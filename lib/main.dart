import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'data/database.dart';
import 'data/database_scope.dart';
import 'diagnostics/app_log.dart';
import 'l10n/l10n.dart';
import 'library/backup.dart';
import 'library/download_service.dart';
import 'library/library_scope.dart';
import 'library/storage.dart';
import 'library/trash.dart';
import 'library/update_checker.dart';
import 'screens/library_screen.dart';
import 'screens/log_screen.dart';
import 'ui/app_settings.dart';
import 'ui/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final log = await AppLog.open(
    Directory(p.join((await getApplicationSupportDirectory()).path, 'logs')),
  );
  final unfinished = await log.startSession();
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    logError(
      'flutter',
      details.exceptionAsString(),
      error: details.context?.toDescription(),
      stack: details.stack,
    );
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    logError('app', 'Uncaught error', error: error, stack: stack);
    return false;
  };
  AppLifecycleListener(
    onExitRequested: () async {
      await log.endSession();
      return AppExitResponse.exit;
    },
    onDetach: () => unawaited(log.endSession()),
  );
  final storage = await LibraryStorage.open();
  final backup = await LibraryBackup.open(storage);
  final restoredFrom = await backup.applyPendingRestore();
  final db = AppDatabase();
  if (restoredFrom != null) {
    await db.moveCoverPaths(restoredFrom, storage.dataDir.path);
  }
  await deleteFromTrash(
    db,
    storage,
    before: DateTime.now().subtract(kTrashKeep),
  );
  final settings = AppSettings(db);
  await settings.load();
  runApp(
    ReadTrackApp(
      db: db,
      storage: storage,
      downloads: DownloadService(db, storage),
      updates: UpdateChecker(db),
      settings: settings,
      unfinishedSession: unfinished,
    ),
  );
}

class ReadTrackApp extends StatelessWidget {
  const ReadTrackApp({
    super.key,
    required this.db,
    required this.storage,
    required this.downloads,
    this.updates,
    this.settings,
    this.unfinishedSession,
  });

  /// What the previous session left in the log if it ended unexpectedly.
  final Map<String, Object?>? unfinishedSession;

  final AppDatabase db;
  final LibraryStorage storage;
  final DownloadService downloads;
  final UpdateChecker? updates;

  /// Defaults to unloaded settings (nothing hidden), e.g. in tests.
  final AppSettings? settings;

  @override
  Widget build(BuildContext context) {
    return DatabaseScope(
      db: db,
      child: LibraryScope(
        storage: storage,
        downloads: downloads,
        updates: updates,
        child: SettingsScope(
          settings: settings ?? AppSettings(db),
          // Uses the system accent color on Android 12+ (Material You). The
          // scheme is still built with fromSeed because dynamic_color's
          // schemes lack some of the current Material 3 color roles.
          child: DynamicColorBuilder(
            builder: (light, dark) => MaterialApp(
              onGenerateTitle: (context) => context.l10n.appTitle,
              debugShowCheckedModeBanner: false,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              theme: buildTheme(light?.primary ?? kSeedColor, Brightness.light),
              darkTheme: buildTheme(
                dark?.primary ?? kSeedColor,
                Brightness.dark,
              ),
              home: unfinishedSession == null
                  ? const LibraryScreen()
                  : _CrashNotice(
                      session: unfinishedSession!,
                      child: const LibraryScreen(),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tells once after start that the last session ended unexpectedly.
class _CrashNotice extends StatefulWidget {
  const _CrashNotice({required this.session, required this.child});

  final Map<String, Object?> session;
  final Widget child;

  @override
  State<_CrashNotice> createState() => _CrashNoticeState();
}

class _CrashNoticeState extends State<_CrashNotice> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final l10n = context.l10n;
      final download = widget.session['download'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 10),
          content: Text(
            download is Map
                ? l10n.crashDuringDownload(
                    '${download['title']}',
                    '${download['done']}',
                    '${download['total']}',
                  )
                : l10n.crashNotice,
          ),
          action: SnackBarAction(
            label: l10n.showLog,
            onPressed: () =>
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const LogScreen())),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
