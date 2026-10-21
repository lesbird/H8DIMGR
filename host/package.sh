#!/usr/bin/env bash
# Publishes the GUI and CLI as self-contained single-file executables and
# packages them for one platform.
#
#   host/package.sh <rid> <version> [dist-dir]
#   e.g. host/package.sh osx-arm64 1.0.0
#
# Output: dist/H8DIMGR-Host-<version>-<platform>.(zip|tar.gz)
set -euo pipefail

rid=${1:?usage: package.sh <rid> <version> [dist-dir]}
version=${2:?usage: package.sh <rid> <version> [dist-dir]}
root=$(cd "$(dirname "$0")/.." && pwd)
dist=$(mkdir -p "${3:-$root/dist}" && cd "${3:-$root/dist}" && pwd)
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

case $rid in
  win-*)   platform=windows-${rid#win-} ;;
  linux-*) platform=linux-${rid#linux-} ;;
  osx-*)   platform=macos-${rid#osx-} ;;
  *) echo "unsupported rid $rid" >&2; exit 1 ;;
esac
name="H8DIMGR-Host-$version-$platform"

for project in H8DImgGui H8DImgHost; do
  dotnet publish "$root/host/$project" -c Release -r "$rid" --self-contained \
    -p:PublishSingleFile=true \
    -p:IncludeNativeLibrariesForSelfExtract=true \
    -p:EnableCompressionInSingleFile=true \
    -p:DebugType=none \
    -p:Version="$version" \
    -o "$work/publish/$project"
done

pkg="$work/$name"
mkdir -p "$pkg"
cp "$root/README.md" "$pkg/"

case $rid in
  win-*)
    cp "$work/publish/H8DImgGui/H8DImgGui.exe" "$pkg/H8DIMGR Host.exe"
    cp "$work/publish/H8DImgHost/h8dimghost.exe" "$pkg/"
    (cd "$work" && 7z a -tzip "$dist/$name.zip" "$name" >/dev/null)
    ;;
  linux-*)
    cp "$work/publish/H8DImgGui/H8DImgGui" "$pkg/h8dimgr-host"
    cp "$work/publish/H8DImgHost/h8dimghost" "$pkg/"
    chmod +x "$pkg/h8dimgr-host" "$pkg/h8dimghost"
    tar -C "$work" -czf "$dist/$name.tar.gz" "$name"
    ;;
  osx-*)
    app="$pkg/H8DIMGR Host.app"
    mkdir -p "$app/Contents/MacOS"
    cp "$work/publish/H8DImgGui/H8DImgGui" "$app/Contents/MacOS/"
    cat > "$app/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key><string>H8DIMGR Host</string>
  <key>CFBundleDisplayName</key><string>H8DIMGR Host</string>
  <key>CFBundleIdentifier</key><string>com.lesbird.h8dimgrhost</string>
  <key>CFBundleExecutable</key><string>H8DImgGui</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>$version</string>
  <key>CFBundleVersion</key><string>$version</string>
  <key>LSMinimumSystemVersion</key><string>12.0</string>
  <key>NSHighResolutionCapable</key><true/>
</dict>
</plist>
EOF
    cp "$work/publish/H8DImgHost/h8dimghost" "$pkg/"
    # Ad-hoc signatures: required to run on Apple Silicon. Not notarized.
    codesign --force --sign - "$app/Contents/MacOS/H8DImgGui"
    codesign --force --sign - "$app"
    codesign --force --sign - "$pkg/h8dimghost"
    (cd "$work" && ditto -c -k --keepParent "$name" "$dist/$name.zip")
    ;;
esac

echo "$dist/$(ls "$dist" | grep "^$name")"
