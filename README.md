# Tailscale Web App Template

This repository intentionally contains only the templates and scripts needed to generate the app. The Flutter and Android project files are created locally by `setup.sh` and are ignored by Git.

## Requirements

Install:

- Flutter SDK
- Go SDK
- Android SDK and an Android device or emulator

## Setup

1. Clone this repository.
2. Run `./setup.sh`.
3. The first run creates `.env` from `.env.example` and stops.
4. Edit `.env` with your WebUI and app settings.
5. Run `./setup.sh` again.
6. Run `./build_app.sh`.

The release APK is generated at:

`build/app/outputs/flutter-apk/app-release.apk`

## `.env` settings

```dotenv
WEB_URL=http://100.100.100.100:1234
APP_NAME=My App
APP_PACKAGE=com.example.myapp
TAILSCALE_HOSTNAME=MyApp
STATUS_BAR_COLOR="#FFFFFF"
```

`APP_PACKAGE` must be a valid Android package name. `APP_NAME` is the displayed app name, and `TAILSCALE_HOSTNAME` is the name of this app's separate embedded `tsnet` node.

## Runtime

The app starts its own embedded Tailscale node. It does not use the Tailscale app installed on the device and does not create a system VPN. If authentication is required, the Tailscale Auth URL opens in the system browser. After authentication, the configured `WEB_URL` opens in the full-screen WebView.

The WebView keeps the configured URL as its origin and uses the embedded Tailscale connection for transport, avoiding artificial CORS, redirect, and cookie rewriting.

## Repository contents

The only application files intended for Git are:

- `.env.example`
- `main.dart.template`
- `MainActivity.kt.template`
- `pubspec.yaml.template`
- `README.md`
- `setup.sh`
- `build_app.sh`
- `icons/icon.png`
- `.gitignore`
