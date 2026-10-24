#!/usr/bin/env bash
# Install a prebuilt archive for the current user. Library data is kept.
set -euo pipefail
cd "$(dirname "$0")"
base="${XDG_DATA_HOME:-$HOME/.local/share}"
opt="$HOME/.local/opt"
mkdir -p "$opt" "$base/applications" "$base/icons/hicolor/scalable/apps"
stage=$(mktemp -d "$opt/readtrack-install.XXXXXX")
trap 'rm -rf "$stage"' EXIT
cp -a app/. "$stage/"
test -x "$stage/readtrack"
rm -rf "$opt/readtrack.previous"
if [[ -d "$opt/readtrack" ]]; then mv "$opt/readtrack" "$opt/readtrack.previous"; fi
mv "$stage" "$opt/readtrack"
cp de.alimi.readtrack.svg "$base/icons/hicolor/scalable/apps/"
cat > "$base/applications/de.alimi.readtrack.desktop" <<DESKTOP
[Desktop Entry]
Type=Application
Name=ReadTrack
Exec="$opt/readtrack/readtrack"
Icon=de.alimi.readtrack
Categories=Office;Education;
Terminal=false
DESKTOP
if command -v update-desktop-database >/dev/null; then update-desktop-database -q "$base/applications"; fi
printf 'ReadTrack installed. Close and reopen the app to use this version.\n'
