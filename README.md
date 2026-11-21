# 🌤️ SkyPulse Weather

**A modern, responsive weather application built with Flutter and Dart.**

SkyPulse Weather provides real-time weather information, city-based weather search, location-based forecasts, and a 7-day weather outlook through a clean and user-friendly interface. It is designed to work across Android and Web platforms.

## 📸 About the Project

SkyPulse Weather is a cross-platform weather application that helps users stay informed about current weather conditions and upcoming forecasts. It uses the Open-Meteo API to retrieve weather information and provides location-based weather updates.

## ✨ Features

- **Live Weather Updates:** Get current weather conditions for different locations.
- **City Search:** Search for cities and explore their weather information.
- **Location Detection:** Get weather updates based on your current GPS location.
- **7-Day Forecast:** View upcoming weather conditions for the next seven days.
- **Temperature Conversion:** Switch between Celsius (°C) and Fahrenheit (°F).
- **Weather Details:** View humidity, wind speed, pressure, and precipitation.
- **Recent Search History:** Access previously searched cities.
- **Persistent Settings:** Save preferences and recent search information locally.
- **Refresh Weather:** Update weather information whenever required.
- **Responsive Interface:** Optimized for desktop and mobile screens.
- **Error Handling:** User-friendly loading, empty, and error states.

## 🛠️ Technologies Used

| Technology | Purpose |
|---|---|
| Flutter | Cross-platform application development |
| Dart | Programming language |
| Provider | State management |
| Open-Meteo API | Weather data |
| HTTP | API communication |
| Hive | Local data storage |
| Geolocator | Location detection |
| Intl | Date and number formatting |

## 🏗️ Project Structure

```text
weather_app/
│
├── android/
├── ios/
├── linux/
├── macos/
├── windows/
├── web/
│
├── lib/
│   ├── main.dart
│   ├── models/
│   ├── providers/
│   ├── services/
│   ├── views/
│   └── widgets/
│
├── test/
├── pubspec.yaml
├── pubspec.lock
└── README.md
```

## 🚀 Getting Started

Follow these steps to run the project locally.

### Prerequisites

- Flutter SDK
- Dart SDK
- Visual Studio Code or Android Studio
- Google Chrome (for web execution)

### 1. Clone the Repository

```bash
git clone https://github.com/VedikaNaik27/weather_app.git
```

### 2. Navigate to the Project

```bash
cd weather_app
```

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Run the Application

For Chrome:

```bash
flutter run -d chrome
```

For Android:

```bash
flutter run
```

## 🌐 Build for Web

To generate the production web application:

```bash
flutter build web --release
```

The generated web files will be available in:

```text
build/web/
```

These files can be deployed using a static web hosting platform such as Netlify.

## 🌦️ Weather API

SkyPulse Weather uses the **Open-Meteo API** to retrieve weather information.

- Website: https://open-meteo.com/
- API Documentation: https://open-meteo.com/en/docs

Open-Meteo provides weather forecast data without requiring an API key for standard non-commercial use.

## 🧪 Testing and Code Quality

The project has been checked using Flutter's development tools.

| Check | Result |
|---|---|
| Dependency installation | Successful |
| Flutter Analyze | No issues found |
| Automated tests | 11 tests passed |
| Web Release Build | Successful |

## 🔮 Future Enhancements

- Weather notifications and alerts.
- Interactive weather maps.
- Hourly weather forecasts.
- Weather widgets.
- Additional weather insights and visualizations.

## 👩‍💻 Developer

**Vedika J Naik**

Information Science and Engineering Student

GitHub: [@VedikaNaik27](https://github.com/VedikaNaik27)

## 📄 License

This project is developed for educational and personal portfolio purposes.

---

⭐ If you find this project interesting, consider giving the repository a star!
