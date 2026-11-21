# SkyPulse — Weather App with Live API & Responsive Web Dashboard

A modern, responsive, cross-platform **Weather Website & Mobile Application** built with **Flutter**, **Dart**, **Provider**, **Hive Database**, and the **Open-Meteo REST API**.

---

## 📋 Project Overview
**SkyPulse Weather** is designed to provide real-time meteorological data, global city searches with instant suggestions, GPS-based location detection, and 7-day weather forecasts. It features an adaptive user interface engineered specifically for desktop web browsers, tablets, and mobile devices (Android/iOS) from a single unified codebase.

---

## 🎯 Objectives & Features Checklist

| # | Requirement | Implementation Status | Details |
|---|---|:---:|---|
| 1 | **Live Weather Information** | ✅ Completed | Real-time temperature, apparent temperature ("feels like"), condition, day/night status |
| 2 | **Search Cities with Suggestions** | ✅ Completed | Live debounced autocomplete via Open-Meteo Geocoding API + Quick city chips |
| 3 | **Current Location Weather (GPS)** | ✅ Completed | Browser & mobile GPS with runtime permission handling and reverse geocoding |
| 4 | **7-Day Weather Forecast** | ✅ Completed | Daily high/low temperatures, day of week, and weather condition indicators |
| 5 | **Celsius & Fahrenheit Toggle** | ✅ Completed | Real-time conversion formula `(°C * 9/5) + 32` with persistent Hive storage |
| 6 | **Detailed Weather Metrics** | ✅ Completed | Relative Humidity (%), Wind Speed (km/h), Surface Pressure (hPa), Precipitation (mm) |
| 7 | **Recent Search History** | ✅ Completed | Local NoSQL storage with Hive (IndexedDB on Web) with 1-tap reload and delete |
| 8 | **Persistent Settings** | ✅ Completed | Remembers temperature unit, last visited city, and optional OpenWeatherMap API key |
| 9 | **Pull-to-Refresh & Web Refresh** | ✅ Completed | Mobile swipe-to-refresh (`RefreshIndicator`) + dedicated desktop AppBar refresh action |
| 10 | **Loading Indicators** | ✅ Completed | Non-blocking update badge, linear search indicators, and initial shimmer spinners |
| 11 | **Friendly Error Messages** | ✅ Completed | Dedicated `ErrorView` with retry action for network drops, timeouts, and GPS denial |
| 12 | **Proper Empty States** | ✅ Completed | Clear visual prompts when search history is empty or initial location is waiting |
| 13 | **Last Searched City Restoration** | ✅ Completed | Restores the user's previously viewed city automatically on app startup |

---

## 💻 Tech Stack & Architecture

- **Framework**: Flutter 3.50+ (Stable Channel)
- **Language**: Dart 3.14+
- **State Management**: `Provider` (Centralized `WeatherProvider` with `ChangeNotifier`)
- **Primary REST API**: [Open-Meteo API](https://open-meteo.com/) (100% Free, CORS-enabled, Zero API key required)
- **Reverse Geocoding**: BigDataCloud Reverse Geocoding API
- **Local Storage**: `Hive` & `hive_flutter` (IndexedDB on Web, native binary file box on Android)
- **Geolocation**: `geolocator` with web permission and secure context handling
- **Networking**: `http` package with cross-platform error handling (eliminating `dart:io` runtime incompatibilities)
- **Formatting**: `intl` for localization, dates, and timestamps

---

## 📂 Project Structure

```
weather_app/
├── android/                        # Android project configuration & permissions
├── ios/                            # iOS runner configuration
├── web/                            # Web configuration, index.html, and manifest.json
├── lib/
│   ├── main.dart                   # Entry point, MultiProvider, custom AppScrollBehavior
│   │
│   ├── models/
│   │   ├── weather_model.dart      # Strongly-typed weather model & JSON parsers
│   │   ├── daily_forecast.dart     # 7-Day forecast data structure & serialization
│   │   └── recent_search.dart      # Hive storage search history model
│   │
│   ├── services/
│   │   ├── weather_service.dart    # Web-compatible HTTP REST client & city autocomplete
│   │   ├── location_service.dart   # GPS geolocation & browser permission workflow
│   │   └── storage_service.dart    # Hive database service for persistent state
│   │
│   ├── providers/
│   │   └── weather_provider.dart   # Reactive state management with ChangeNotifier
│   │
│   ├── views/
│   │   ├── home_screen.dart        # Responsive dashboard (multi-column desktop & mobile)
│   │   ├── search_screen.dart      # Search view with live suggestions & Hive history
│   │   └── settings_screen.dart    # Temperature unit, API options, and Hive data view
│   │
│   └── widgets/
│       ├── current_weather_card.dart # Glassmorphic hero weather display
│       ├── weather_detail_grid.dart  # Humidity, Wind, Pressure, Precipitation cards
│       ├── daily_forecast_list.dart  # 7-Day weather forecast list
│       ├── recent_search_tile.dart   # Search history tile with reload and delete
│       └── error_view.dart          # Network & GPS error view with retry button
│
├── test/
│   └── widget_test.dart            # Complete automated test suite (models, logic, widgets)
├── pubspec.yaml                    # Package dependencies and overrides
└── README.md                       # Documentation & setup guide
```

---

## 🖥️ Responsive Web & Mobile Design

The app dynamically adapts to all display viewports:
- **Desktop & Laptop (> 900px)**:
  - Multi-column layout with a 440px sticky Hero card on the left.
  - Analytics and 7-day forecast grid on the right.
  - Quick-jump city chips ("📍 My Location", London, New York, Tokyo, Paris, Mumbai, Sydney).
  - Dedicated refresh button, unit switch pill, and keyboard shortcuts (`Escape` to close modals, `Enter` to search).
- **Tablet (600px – 899px)**:
  - Balanced flexible cards with auto-adjusting grid columns.
- **Mobile (< 600px)**:
  - Touch-optimized vertical feed with smooth pull-to-refresh gestures.

---

## 🚀 Setup & Execution Guide

### 1. Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version 3.24+ or 3.50+)
- Google Chrome or any modern web browser
- Android Studio / Android SDK (for Android deployment)

### 2. Install Dependencies
```bash
cd weather_app
flutter pub get
```

### 3. Run Static Code Analysis
```bash
flutter analyze
```
*(Expected: `No issues found!`)*

### 4. Run Automated Test Suite
```bash
flutter test
```
*(Runs 11 automated unit and widget tests verifying JSON parsing, temperature conversions, and UI widgets)*

### 5. Run Locally on Chrome (Web)
```bash
flutter run -d chrome
```

### 6. Run on Connected Android Device or Emulator
```bash
flutter run -d android
```

---

## 🌐 Production Web Build & Deployment

To compile the optimized, tree-shaken Web release:

```bash
flutter build web --release
```

The output files will be generated in `build/web/`.

### Deployment Options:
- **Firebase Hosting**:
  ```bash
  firebase init hosting  # Set public directory to build/web
  firebase deploy
  ```
- **GitHub Pages**:
  ```bash
  flutter build web --release --base-href="/your-repo-name/"
  ```
  Push the contents of `build/web/` to your `gh-pages` branch.
- **Vercel / Netlify**:
  Deploy the `build/web` folder directly via drag-and-drop or Git integration (Build command: `flutter build web --release`, Output directory: `build/web`).

---

## 📱 Android Build

To compile a release APK for Android devices:

```bash
flutter build apk --release
```
The output file will be generated at `build/app/outputs/flutter-apk/app-release.apk`.

---

## ⚠️ Remaining Limitations & Notes

1. **Browser Geolocation Requirements**:
   - Modern browsers (Chrome, Firefox, Safari, Edge) strictly enforce the **W3C Geolocation API** requirement: GPS location is **only allowed on secure contexts** (`https://` or `http://localhost`). When deployed over plain `http://`, the browser will automatically deny location access. Use HTTPS for web hosting.
2. **Reverse Geocoding Rate Limits**:
   - The default reverse geocoding provider (BigDataCloud) provides free client-side lookups for device coordinates without an API key. In the rare event that reverse lookup times out, the app safely defaults to coordinate markers or allows searching any city by name.
3. **OpenWeatherMap Integration**:
   - Open-Meteo is used by default because it works immediately out of the box with zero API keys. If using OpenWeatherMap via the Settings screen, please allow up to 10–20 minutes after generating a new OpenWeatherMap key for their servers to activate it.

---

## 👤 Author
**Vedika Naik**
- GitHub: [VedikaNaik27](https://github.com/VedikaNaik27)
