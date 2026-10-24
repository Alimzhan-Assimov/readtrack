#!/usr/bin/env bash
# Builds ReadTrack in release mode and installs it for the current user so it
# shows up in the app launcher. Run it again to update; pass --uninstall to
# remove the app (your library data is kept).
set -euo pipefail

app_id="de.alimi.readtrack"
install_dir="$HOME/.local/opt/readtrack"
icon_file="$HOME/.local/share/icons/hicolor/scalable/apps/$app_id.svg"
desktop_file="$HOME/.local/share/applications/$app_id.desktop"

if [[ "${1:-}" == "--uninstall" ]]; then
  rm -rf "$install_dir"
  rm -f "$icon_file" "$desktop_file"
  echo "ReadTrack removed. Library data is still in ~/.local/share/$app_id."
  exit 0
fi

cd "$(dirname "$0")/.."
flutter build linux --release

rm -rf "$install_dir"
mkdir -p "$install_dir" "$(dirname "$icon_file")" "$(dirname "$desktop_file")"
cp -r build/linux/x64/release/bundle/. "$install_dir/"
cp assets/icon/readtrack.svg "$icon_file"

cat > "$desktop_file" <<EOF
[Desktop Entry]
Type=Application
Name=ReadTrack
Comment=Track and read books, fanfiction, web novels and manga
Exec=$install_dir/readtrack
Icon=$app_id
StartupWMClass=$app_id
Categories=Office;Education;
Terminal=false
EOF

if command -v update-desktop-database >/dev/null; then
  update-desktop-database -q "$(dirname "$desktop_file")"
fi
echo "ReadTrack installed. Start it from your app launcher."
