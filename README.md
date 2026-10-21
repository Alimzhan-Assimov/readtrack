# Lesetracker

Eine App, um alle gelesenen Bücher, Fanfictions, Webnovels und Manga an einem
Ort zu verwalten – physisch im Regal oder online.

## Starten

```bash
flutter pub get
flutter run -d linux --profile   # flüssig, zum Ausprobieren
flutter run -d linux             # Debug-Modus mit Hot Reload (ruckelt, das ist normal)
```

Der **Debug-Modus ist in Flutter grundsätzlich ruckelig** (JIT-Kompilierung,
zusätzliche Prüfungen). Wie sich die App wirklich anfühlt, zeigen nur
`--profile` oder `--release`.

Nach Änderungen an den Datenbanktabellen (`lib/data/database.dart`) den
generierten Code neu erzeugen:

```bash
dart run build_runner build
```

## Tests und Analyse

```bash
flutter analyze
flutter test
```

## Git-Workflow

- `main` – stabiler Stand, nur über Pull Requests aus `develop`.
- `develop` – Integrationszweig, Ziel aller Feature-PRs.
- `feature/<name>`, `fix/<name>`, `chore/<name>` – werden von `develop`
  abgezweigt und per Pull Request zurück nach `develop` gemerged.

Ein Release ist ein Pull Request `develop` → `main`.
