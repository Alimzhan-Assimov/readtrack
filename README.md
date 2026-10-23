# ReadTrack

An app to keep all the books, fanfiction, web novels and manga you read in one
place, whether they sit on your shelf or live online.

## Features

- Library of books, fanfiction, web novels, manga and comics with categories
  (fandoms), tags, reading status, progress and ratings.
- **Add from a link:** paste the link to a story and title, author, cover,
  fandom, tags, chapters and word count are filled in.
- **Read online** inside the app; chapters are loaded live from the site and
  reading continues where you stopped.
- **Download** chapters for offline reading, including images. Each download
  is a chapter range (e.g. 1–30) exported as a TXT file to
  `~/Documents/ReadTrack`. When new chapters appear, add them to an existing
  download (1–30 → 1–40) or create a separate one (31–40).

### Supported sites

| Site | How it is loaded |
| --- | --- |
| FanFiction.Net | Browser window (Cloudflare) |
| Archive of Our Own | HTTP, browser as fallback |
| WebNovel | Browser window (Cloudflare); paid chapters are skipped |
| Royal Road | HTTP, browser as fallback |
| Scribble Hub | Browser window (Cloudflare) |
| Author.Today | HTTP; only chapters that are free to read |
| Ficbook | HTTP, browser as fallback |
| SpaceBattles, Sufficient Velocity, Questionable Questing | HTTP, browser as fallback; chapters are threadmarks |
| Wattpad | public JSON API |
| FictionPress | Browser window (Cloudflare) |
| Quotev | Browser window |
| Tapas | HTTP, browser as fallback; paid episodes are skipped |
| Inkitt | HTTP, browser as fallback |
| Honeyfeed | Browser window (Cloudflare) |
| Wuxiaworld | HTTP, browser as fallback; paid chapters are skipped |
| Novel Updates | Browser window; details only, chapters live on the translators' sites |
| Fanfics.me | HTTP, browser as fallback |
| Litnet | HTTP; only chapters that are free to read |
| LitMarket | HTTP; only the freely readable part |
| Samlib | HTTP (KOI8-R); each work is one chapter |
| Proza.ru | HTTP (Windows-1251); each work is one chapter |
| Rulate | HTTP, browser as fallback; paid chapters are skipped |
| ПродаМан | HTTP, browser as fallback; each reader page is a chapter |
| Целлюлоза | details only; the site protects its text |
| Project Gutenberg | HTTP; the book file is split at its chapter headings |
| Standard Ebooks | HTTP; chapters from the single-page edition |
| Wikisource (ru, en, de, uk) | MediaWiki API; a work's direct subpages are its chapters |

Sites protected against bots are loaded through a small browser window
(WebKitGTK on Linux), so pages arrive exactly as in a normal browser. Paywalls
are never bypassed. Downloads are meant for personal offline reading.

Parsers live in `lib/sources/`, one file per site.

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
