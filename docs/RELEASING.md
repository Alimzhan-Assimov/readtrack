# Releasing ReadTrack

`pubspec.yaml` is the version source: `MAJOR.MINOR.PATCH+BUILD`. All three platforms
share the same release version; BUILD must increase for Android updates. The
runtime/log/About version in `lib/version.dart` must match. Stable tags are
`vMAJOR.MINOR.PATCH`. Release assets include the version in their filenames.

1. Start a feature branch from `develop`. Run e.g.
   `python3 scripts/release.py set-version 1.2.0` (increments BUILD automatically).
2. Add the version's changes to `CHANGELOG.md`. Run
   `python3 scripts/release.py verify` and the usual CI checks.
3. Merge the PR into `develop`, then the release PR `develop` → `main`.
4. On that tested `main` commit create and push the matching tag:
   `git tag -a v1.2.0 -m 'ReadTrack 1.2.0'` and `git push origin v1.2.0`.
5. The Release workflow tests the code, builds Android/Windows/Linux and publishes
   all packages, installation instructions and checksums **only if every job passes**.
   Inspect the release and its downloads. Never move/reuse a published version tag.

Release-related PRs build all three platforms before merging. Android PR previews
are explicitly debug-signed; tag/manual builds require the permanent release key
and never fall back to a debug key. Manual workflow runs build artifacts without
publishing a release. No paid signing service or app store account is needed.

## Android signing

Repository Actions secrets (not committed): `ANDROID_KEYSTORE_BASE64` (base64 of a
PKCS12 keystore), `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`,
`ANDROID_KEY_PASSWORD`. CI writes temporary `android/key.properties` and
`android/app/upload.p12`, verifies the APK signature and removes signing files.
Back up the keystore and passwords securely: the same key is needed for updates.
A lost signing key cannot be recovered from the APK or from GitHub secret values.
For local release builds create the same ignored `android/key.properties` file.

## Packaging

- Android: one signed universal APK (also easy for Obtainium to select).
- Windows: per-user Inno Setup installer and a full ZIP with C++ runtime DLLs;
  the installer includes Microsoft's WebView2 bootstrapper, verified during packaging.
- Linux: `.deb` with declared runtime dependencies and a tar archive with a user
  installer. Built on Ubuntu 22.04 for a glibc 2.35 baseline.
- `SHA256SUMS.txt` covers every uploaded package and `INSTALL.md`.

See [INSTALL.md](INSTALL.md) for platform requirements and current Android limits.
