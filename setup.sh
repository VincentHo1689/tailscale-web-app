#!/bin/bash
set -e

if ! command -v flutter >/dev/null 2>&1; then
    echo "ERROR: Flutter SDK was not found. Install Flutter and try again."
    exit 1
fi

if ! command -v go >/dev/null 2>&1; then
    echo "ERROR: Go was not found. Install Go and try again."
    exit 1
fi

if [ ! -f ".env" ]; then
    cp .env.example .env
    echo "Created .env from .env.example. Edit it, then run ./setup.sh again."
    exit 1
fi

set -a
source .env
set +a

for value in WEB_URL APP_NAME APP_PACKAGE TAILSCALE_HOSTNAME; do
    if [ -z "${!value:-}" ]; then
        echo "ERROR: Missing $value in .env."
        exit 1
    fi
done

if [[ ! "$APP_PACKAGE" =~ ^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+$ ]]; then
    echo "ERROR: APP_PACKAGE must look like com.example.myapp."
    exit 1
fi

project_name="${APP_PACKAGE##*.}"
org="${APP_PACKAGE%.*}"
escaped_package=$(printf '%s' "$APP_PACKAGE" | sed 's/[\/&]/\\&/g')
escaped_app_name=$(printf '%s' "$APP_NAME" | sed 's/[\/&]/\\&/g')

flutter create --platforms=android --org "$org" --project-name "$project_name" .

cp pubspec.yaml.template pubspec.yaml
cp main.dart.template lib/main.dart
rm -rf test

main_activity=$(find android/app/src/main/kotlin -name MainActivity.kt -type f -print -quit)
if [ -z "$main_activity" ]; then
    echo "ERROR: Flutter did not create MainActivity.kt."
    exit 1
fi
sed "s/__APP_PACKAGE__/$escaped_package/g" MainActivity.kt.template > "$main_activity"
sed -i.bak "s/__APP_PACKAGE__/$escaped_package/g" lib/main.dart
rm -f lib/main.dart.bak

sed -i.bak "s#applicationId = \"[^\"]*\"#applicationId = \"$escaped_package\"#" android/app/build.gradle.kts
sed -i.bak "s#namespace = \"[^\"]*\"#namespace = \"$escaped_package\"#" android/app/build.gradle.kts
rm -f android/app/build.gradle.kts.bak

if ! grep -q 'androidx.webkit:webkit' android/app/build.gradle.kts; then
    sed -i.bak '/dependencies {/a\    implementation("androidx.webkit:webkit:1.12.1")' android/app/build.gradle.kts
    rm -f android/app/build.gradle.kts.bak
fi

manifest="android/app/src/main/AndroidManifest.xml"
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

flutter pub get
flutter pub run flutter_launcher_icons:main

echo "Setup complete. Run ./build_app.sh to create the APK."
