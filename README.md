# Tailscale Web App

Package any internal web service into a standalone Android app with built-in Tailscale connectivity—without interfering with the system VPN.

## Usage

1. Edit the `.env` file (copied from `.env.example`).
2. Replace `icons/icon.png` with your 1024x1024 icon (optional).
3. Run `./setup.sh` to initialize the Flutter project.
4. Run `./build_app.sh` to generate the APK.

## Configuration

- `TAILSCALE_AUTH_KEY`: Generated from the Tailscale Admin Console (must check "Reusable").
- `WEB_URL`: Your WebUI fixed IP:Port.
- `APP_NAME`: Display name of the application (e.g., "My App").
- `APP_PACKAGE`: Application package name (e.g., `com.example.myapp`).
- `TAILSCALE_HOSTNAME`: Device name displayed in Tailscale.

## Notes

- Internet connection is required on the first run to complete Tailscale authentication.
- Saved login state will be reused automatically afterward.
- Does not affect other VPNs on the device (e.g., Clash, Surfshark).
