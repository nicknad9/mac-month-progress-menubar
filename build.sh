#!/bin/bash
set -e
cd "$(dirname "$0")"

APP_NAME="New Month's Resolution"
BUILD_DIR="build"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
EXEC_PATH="$APP_BUNDLE/Contents/MacOS/$APP_NAME"
MIN_MACOS=11.0

rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"

SLICES=$(mktemp -d)
trap 'rm -rf "$SLICES"' EXIT

swiftc -target arm64-apple-macos$MIN_MACOS  -o "$SLICES/arm64"  main.swift
swiftc -target x86_64-apple-macos$MIN_MACOS -o "$SLICES/x86_64" main.swift
lipo -create -output "$EXEC_PATH" "$SLICES/arm64" "$SLICES/x86_64"

cp Info.plist "$APP_BUNDLE/Contents/"

echo "Built $APP_BUNDLE"

# Create DMG
DMG_PATH="$BUILD_DIR/$APP_NAME.dmg"
rm -f "$DMG_PATH"
hdiutil create -volname "$APP_NAME" -srcfolder "$APP_BUNDLE" -ov -format UDZO "$DMG_PATH"
echo "Created $DMG_PATH"
