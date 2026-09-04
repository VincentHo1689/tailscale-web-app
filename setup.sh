#!/bin/bash
set -e

if ! command -v flutter &> /dev/null; then
    echo "ERROR: Flutter not found. Please install Flutter."
    exit 1
fi

if ! command -v go &> /dev/null; then
    echo "ERROR: Go not found. Please install Go 1.26+ (brew install go / apt install golang-go / etc.)"
    exit 1
fi

if [ ! -f ".env" ]; then
    cp .env.example .env
    echo "ERROR: .env file not found. Created one from .env.example. Please edit it and rerun."
    exit 1
fi

source .env

if [ -z "$WEB_URL" ]; then
    echo "ERROR: Missing WEB_URL in .env."
    exit 1
fi

echo "Creating Flutter project: $APP_NAME ($APP_PACKAGE)"
project_name=$(echo $APP_NAME | tr '[:upper:]' '[:lower:]' | sed 's/ //g')
org=$(echo $APP_PACKAGE | cut -d'.' -f1,2)
flutter create --org $org --project-name $project_name .

sed "s/{{PROJECT_NAME}}/$project_name/g" pubspec.yaml.template > pubspec.yaml

flutter pub add tailscale flutter_dotenv path_provider flutter_inappwebview url_launcher
flutter pub add --dev flutter_launcher_icons

flutter pub get

manifest="android/app/src/main/AndroidManifest.xml"
app_name="${APP_NAME:-My App}"
escaped_app_name=$(printf '%s' "$app_name" | sed 's/[\/&]/\\&/g')
sed -i.bak "s#android:label=\"[^\"]*\"#android:label=\"$escaped_app_name\"#" "$manifest"
rm -f "$manifest.bak"
if ! grep -q 'android.permission.INTERNET' "$manifest"; then
    sed -i.bak '1a\
    <uses-permission android:name="android.permission.INTERNET" />' "$manifest"
    rm -f "$manifest.bak"
fi
if ! grep -q 'android:usesCleartextTraffic="true"' "$manifest"; then
    sed -i.bak 's#<application#<application android:usesCleartextTraffic="true"#' "$manifest"
    rm -f "$manifest.bak"
fi

if [ -f "icons/icon.png" ]; then
    flutter pub run flutter_launcher_icons:main
else
    echo "WARNING: icons/icon.png not found, using default icon."
fi

echo "Initialization complete! Now run ./build_app.sh"