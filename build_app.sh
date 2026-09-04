#!/bin/bash
set -e

if [ ! -f ".env" ]; then
    echo "ERROR: .env not found. Run ./setup.sh first."
    exit 1
fi

source .env

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

flutter pub get
flutter build apk --release

echo "APK generated: build/app/outputs/flutter-apk/app-release.apk"