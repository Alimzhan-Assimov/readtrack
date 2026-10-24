#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
version=$(python3 -c 'import sys; sys.path.insert(0,"scripts"); import release; print(release.verify()[0])')
build=$(python3 -c 'import sys; sys.path.insert(0,"scripts"); import release; print(release.verify()[1])')
bundle=build/linux/x64/release/bundle
test -x "$bundle/readtrack"
mkdir -p dist
stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT
archive="$stage/ReadTrack"
mkdir -p "$archive/app"
cp -a "$bundle/." "$archive/app/"
cp assets/icon/readtrack.svg "$archive/de.alimi.readtrack.svg"
cp packaging/linux/install.sh "$archive/"
cp docs/INSTALL.md "$archive/INSTALL.md"
tar -czf "dist/readtrack-$version-linux-x64.tar.gz" -C "$stage" ReadTrack

pkg="$stage/deb"
mkdir -p "$pkg/DEBIAN" "$pkg/usr/lib/readtrack" "$pkg/usr/bin" \
  "$pkg/usr/share/applications" "$pkg/usr/share/icons/hicolor/scalable/apps"
cp -a "$bundle/." "$pkg/usr/lib/readtrack/"
cp assets/icon/readtrack.svg "$pkg/usr/share/icons/hicolor/scalable/apps/de.alimi.readtrack.svg"
printf '#!/bin/sh\nexec /usr/lib/readtrack/readtrack "$@"\n' > "$pkg/usr/bin/readtrack"
chmod 755 "$pkg/usr/bin/readtrack"
cat > "$pkg/usr/share/applications/de.alimi.readtrack.desktop" <<'DESKTOP'
[Desktop Entry]
Type=Application
Name=ReadTrack
Comment=Track and read books, fanfiction, web novels and manga
Exec=readtrack
Icon=de.alimi.readtrack
Categories=Office;Education;
Terminal=false
DESKTOP
cat > "$pkg/DEBIAN/control" <<CONTROL
Package: readtrack
Version: $version-$build
Section: education
Priority: optional
Architecture: amd64
Maintainer: ReadTrack <readtrack@users.noreply.github.com>
Homepage: https://github.com/Alimzhan-Assimov/readtrack
Depends: libc6 (>= 2.35), libstdc++6, libgtk-3-0 | libgtk-3-0t64, libwebkit2gtk-4.1-0, libsoup-3.0-0
Description: Personal reading library and offline reader
 Track books, web novels, fanfiction, manga and comics.
CONTROL
chmod 755 "$pkg/DEBIAN"
dpkg-deb --root-owner-group --build "$pkg" "dist/readtrack-$version-linux-x64.deb"
