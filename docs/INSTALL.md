# Install ReadTrack

Download the package for your device from [GitHub Releases](https://github.com/Alimzhan-Assimov/readtrack/releases/latest).
You do not need Flutter, Git or a compiler. Close ReadTrack before updating;
install over the existing app to keep your library. Backups are available in the
app's settings. Windows and Linux support x64; Android includes ARM and x64.

## Android

Download `readtrack-VERSION-android.apk` to your phone, open it and allow your
browser/file manager to install this APK when Android asks. Future APKs use the
same signing key, so they install as updates. Obtainium can track this repository's
releases and select the single `.apk` asset.

Local book files and HTTP sources work on Android. The embedded browser is
currently desktop-only: sources needing Cloudflare or an interactive age/sign-in
confirmation cannot load through that browser on Android yet.

## Windows 10/11 (64 bit)

Run `readtrack-VERSION-windows-x64-setup.exe`. It installs for your user and creates
a Start menu entry. If missing, it installs Microsoft's WebView2 Runtime (internet
required for that prerequisite). The installer is currently not code-signed, so
Windows may show an unknown-publisher/SmartScreen prompt.

The `.zip` is an alternative: extract the **whole folder** and run `readtrack.exe`.
Keep the DLLs and `data` folder next to it. Install [Microsoft WebView2 Runtime](https://developer.microsoft.com/microsoft-edge/webview2/)
if the embedded browser is unavailable. The C++ runtime DLLs are included.

## Linux (x64)

Ubuntu 22.04+/compatible Debian-based distributions: download the `.deb`, then:

```sh
sudo apt install ./readtrack-VERSION-linux-x64.deb
```

Other distributions: extract `readtrack-VERSION-linux-x64.tar.gz`, open the
`ReadTrack` directory and run `./install.sh`. This adds the app to your launcher
without root access; it uses `~/.local/opt/readtrack`, like the development installer.
You can also run `./app/readtrack` directly from the extracted folder.

The archive needs glibc 2.35+, GTK 3, WebKitGTK 4.1, libsoup 3 and libsecret
(for AI keys in the keyring) from your system.
On Arch/Omarchy: `sudo pacman -S gtk3 webkit2gtk-4.1 libsoup3 libsecret`.
On Fedora: `sudo dnf install gtk3 webkit2gtk4.1 libsoup3 libsecret`.
The Debian package installs its dependencies through apt. This is not a Flatpak or
fully self-contained AppImage.

## Verify a download

Every release includes `SHA256SUMS.txt`. On Linux run
`sha256sum --check SHA256SUMS.txt --ignore-missing`; on Windows use
`Get-FileHash .\readtrack-VERSION-windows-x64-setup.exe -Algorithm SHA256`
and compare the hash with the matching line in the checksum file.
