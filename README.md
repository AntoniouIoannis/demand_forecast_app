# Demand Forecast App

A Flutter application for demand forecasting, built with FlutterFlow and Firebase.

## 🌐 Live Web App

The app is automatically deployed to GitHub Pages on every push to `main`:

**URL:** https://AntoniouIoannis.github.io/demand_forecast_app/

> **One-time setup:** Go to your repository **Settings → Pages**, set the source to the `gh-pages` branch, and save. The URL above will be live after the first successful workflow run.

## 📱 Download APK (Android)

The Android APK is automatically built and published as a GitHub Release on every push to `main`.

**Download:** Go to the [Releases](https://github.com/AntoniouIoannis/demand_forecast_app/releases) page and download the latest `app-release.apk`.

> **Note:** The APK is signed with debug keys. To install it on an Android device, enable **"Install from unknown sources"** in your device settings.

## 🖥️ Download macOS App

The macOS desktop app is automatically built on every push to `main` using a cloud macOS runner.

**Download:** Go to the [Actions](https://github.com/AntoniouIoannis/demand_forecast_app/actions/workflows/build_macos.yml) tab, open the latest `Build Flutter macOS` run, and download the `macos-release` artifact (a `.dmg` disk image).

> **Note:** The app is built without code signing (CI build). macOS may show a security warning on first launch. Right-click the app and choose **Open**, then confirm in the security dialog that appears. You only need to do this once.

## CI/CD Workflows

| Workflow | Trigger | Result |
|---|---|---|
| `deploy_web.yml` | Push to `main` | Deploys web build to GitHub Pages |
| `build_apk.yml` | Push to `main` | Builds APK and creates a GitHub Release |
| `build_macos.yml` | Push to `main` | Builds macOS `.dmg` and uploads as Actions artifact |

All workflows can also be triggered manually from the **Actions** tab.

## Getting Started (Local Development)

FlutterFlow projects are built to run on the Flutter _stable_ release.

```bash
flutter pub get
flutter run
```
