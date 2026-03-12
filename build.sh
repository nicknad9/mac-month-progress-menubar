#!/bin/bash
set -e
cd "$(dirname "$0")"

APP_NAME="MonthProgress"
BUILD_DIR="build"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"

rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"

swiftc -o "$APP_BUNDLE/Contents/MacOS/$APP_NAME" main.swift
cp Info.plist "$APP_BUNDLE/Contents/"

echo "Built $APP_BUNDLE"
