#!/bin/bash
set -e

if ! command -v flutter &> /dev/null; then
    echo "ERROR: Flutter not found. Please install Flutter and ensure it's in your PATH."
    exit 1
fi

if [ ! -f ".env" ]; then
    cp .env.example .env
    echo "ERROR: .env file not found. Created a new one from .env.example. Please edit it and run this script again."
    exit 1
fi

source .env

if [ -z "$TAILSCALE_AUTH_KEY" ] || [ -z "$WEB_URL" ]; then
    echo "ERROR: Missing TAILSCALE_AUTH_KEY or WEB_URL in .env. Please set them and run this script again."
    exit 1
fi

echo "Creating Flutter 项目: $APP_NAME ($APP_PACKAGE)"
project_name=$(echo $APP_NAME | tr '[:upper:]' '[:lower:]' | sed 's/ //g')
flutter create --org ... --project-name $project_name .

cp lib/main.dart.template lib/main.dart

flutter pub add tailscale webview_flutter flutter_dotenv path_provider
flutter pub add --dev flutter_launcher_icons

cat >> pubspec.yaml <<'YAMLEND'

flutter_icons:
  android: true
  ios: true
  image_path: "icons/icon.png"
  adaptive_icon_background: "#ffffff"
  adaptive_icon_foreground: "icons/icon.png"
YAMLEND

if [ -f "icons/icon.png" ]; then
    flutter pub run flutter_launcher_icons:main
else
    echo "WARNING: icons/icon.png not found, using default icon. Please replace it with your own icon."
fi

echo "Initialization complete! Now run ./build_app.sh to build the APK"
