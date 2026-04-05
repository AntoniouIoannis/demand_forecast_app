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

## CI/CD Workflows

| Workflow | Trigger | Result |
|---|---|---|
| `deploy_web.yml` | Push to `main` | Deploys web build to GitHub Pages |
| `build_apk.yml` | Push to `main` | Builds APK and creates a GitHub Release |

Both workflows can also be triggered manually from the **Actions** tab.

## Getting Started (Local Development)

FlutterFlow projects are built to run on the Flutter _stable_ release.

```bash
flutter pub get
flutter run
```
