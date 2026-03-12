# monthly,

A small macOS menu bar app that shows how far you are into the current month. The idea is to set goals each month instead of once a year.

<img width="504" height="357" alt="image" src="https://github.com/user-attachments/assets/37f29651-e7b0-46c2-83ac-b025c3d8d74e" />

## Install

1. Download `New Month's Resolution.dmg` from the [latest release](../../releases/latest)
2. Open the `.dmg` and drag the app to your Applications folder
3. Since the app is not code-signed, macOS will block it on first launch. Right-click the app, select Open, then click Open again in the dialog. You only need to do this once.

## Launch at login

Open System Settings > General > Login Items, click +, and add the app.

## Languages

English, Italiano, Español, Français, Português, Deutsch, 简体中文, 繁體中文, 日本語, 한국어.

## Build from source (for developers)

Requires Xcode Command Line Tools (`xcode-select --install`).

```
git clone https://github.com/nicknad9/mac-month-progress-menubar.git
cd mac-month-progress-menubar
./build.sh
open "build/New Month's Resolution.app"
```
