# ReadTrack

An app to keep all the books, fanfiction, web novels and manga you read in one
place, whether they sit on your shelf or live online.

## Running

```bash
flutter pub get
flutter run -d linux --profile   # smooth, for trying things out
flutter run -d linux             # debug mode with hot reload (janky, that's normal)
```

Flutter's **debug mode is always janky** (JIT compilation, extra checks). Only
`--profile` or `--release` show how the app really feels.

## Installing on Linux

```bash
./scripts/install_linux.sh              # build in release mode and add to the app launcher
./scripts/install_linux.sh --uninstall  # remove again (library data is kept)
```

Run the script again after pulling new changes to update the installed app.

## Development

After changing database tables (`lib/data/database.dart`), regenerate code:

```bash
dart run build_runner build
```

UI texts live in `lib/l10n/app_en.arb`. The Dart code in `lib/l10n/` is
generated from it by `flutter pub get` (or `flutter gen-l10n`).

```bash
flutter analyze
flutter test
```

## Git workflow

- `main` – stable, only updated through pull requests from `develop`.
- `develop` – integration branch, target of all feature PRs.
- `feature/<name>`, `fix/<name>`, `chore/<name>` – branched off `develop` and
  merged back through a pull request.

A release is a pull request `develop` → `main`.
