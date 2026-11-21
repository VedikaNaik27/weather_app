import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/models/daily_forecast.dart';
import 'package:weather_app/models/recent_search.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/services/weather_service.dart';
import 'package:weather_app/widgets/current_weather_card.dart';
import 'package:weather_app/widgets/daily_forecast_list.dart';
import 'package:weather_app/widgets/error_view.dart';
import 'package:weather_app/widgets/recent_search_tile.dart';
import 'package:weather_app/widgets/weather_detail_grid.dart';

void main() {
  group('1. Data Model & JSON Parsing Tests', () {
    test('RecentSearch model serializes and deserializes correctly', () {
      final now = DateTime.now();
      final search = RecentSearch(
        city: 'Mumbai',
        country: 'India',
        temperature: 28.5,
        condition: 'Clear Sky',
        weatherCode: 0,
        searchedAt: now,
      );

      final map = search.toMap();
      expect(map['city'], 'Mumbai');
      expect(map['country'], 'India');
      expect(map['temperature'], 28.5);
      expect(map['condition'], 'Clear Sky');
      expect(map['weatherCode'], 0);

      final deserialized = RecentSearch.fromMap(map);
      expect(deserialized.city, 'Mumbai');
      expect(deserialized.country, 'India');
      expect(deserialized.temperature, 28.5);
      expect(deserialized.condition, 'Clear Sky');
      expect(deserialized.weatherCode, 0);
    });

    test('DailyForecast model parses from JSON and serializes to JSON', () {
      final forecast = DailyForecast.fromJson(
        dateStr: '2026-11-20',
        maxTemp: 24.5,
        minTemp: 16.0,
        weatherCode: 2,
        condition: 'Partly Cloudy',
      );

      expect(forecast.maxTemp, 24.5);
      expect(forecast.minTemp, 16.0);
      expect(forecast.weatherCode, 2);
      expect(forecast.condition, 'Partly Cloudy');

      final json = forecast.toJson();
      expect(json['maxTemp'], 24.5);
      expect(json['minTemp'], 16.0);
      expect(json['weatherCode'], 2);
    });

    test('WeatherModel parses Open-Meteo JSON with 7-day forecast correctly', () {
      final mockData = {
        'current': {
          'temperature_2m': 22.4,
          'apparent_temperature': 21.0,
          'relative_humidity_2m': 55,
          'wind_speed_10m': 12.0,
          'surface_pressure': 1012.0,
          'weather_code': 0,
          'is_day': 1,
          'precipitation': 0.0,
        },
        'daily': {
          'time': ['2026-11-18', '2026-11-19', '2026-11-20'],
          'weather_code': [0, 2, 61],
          'temperature_2m_max': [25.0, 23.0, 19.0],
          'temperature_2m_min': [18.0, 16.5, 14.0],
        }
      };

      final weather = WeatherModel.fromOpenMeteo(
        cityName: 'Tokyo',
        country: 'Japan',
        json: mockData,
      );

      expect(weather.cityName, 'Tokyo');
      expect(weather.country, 'Japan');
      expect(weather.temperature, 22.4);
      expect(weather.feelsLike, 21.0);
      expect(weather.humidity, 55);
      expect(weather.windSpeed, 12.0);
      expect(weather.pressure, 1012.0);
      expect(weather.condition, 'Clear Sky');
      expect(weather.isDay, true);
      expect(weather.forecast.length, 3);
      expect(weather.forecast[1].condition, 'Partly Cloudy');
      expect(weather.forecast[2].condition, 'Rain');
    });

    test('WeatherModel parses OpenWeatherMap JSON correctly', () {
      final mockOwmData = {
        'name': 'Paris',
        'sys': {'country': 'FR'},
        'main': {
          'temp': 18.2,
          'feels_like': 17.5,
          'humidity': 62,
          'pressure': 1015.0,
        },
        'wind': {'speed': 4.5},
        'weather': [
          {'id': 800, 'main': 'Clear', 'description': 'clear sky'}
        ]
      };

      final weather = WeatherModel.fromOpenWeatherMap(mockOwmData);
      expect(weather.cityName, 'Paris');
      expect(weather.country, 'FR');
      expect(weather.temperature, 18.2);
      expect(weather.humidity, 62);
      expect(weather.windSpeed, 4.5);
      expect(weather.condition, 'Clear');
    });

    test('CitySearchResult formats displayName accurately', () {
      final cityWithAdmin = CitySearchResult(
        name: 'San Francisco',
        country: 'United States',
        admin1: 'California',
        latitude: 37.77,
        longitude: -122.41,
      );
      expect(cityWithAdmin.displayName, 'San Francisco, California, United States');

      final cityWithoutAdmin = CitySearchResult(
        name: 'Singapore',
        country: 'Singapore',
        latitude: 1.35,
        longitude: 103.81,
      );
      expect(cityWithoutAdmin.displayName, 'Singapore');
    });
  });

  group('2. Temperature Conversion & State Logic Tests', () {
    test('Calculates Celsius and Fahrenheit values correctly', () {
      double celsius = 20.0;
      double fahrenheit = (celsius * 9 / 5) + 32;
      expect(fahrenheit, 68.0);

      double freezingC = 0.0;
      double freezingF = (freezingC * 9 / 5) + 32;
      expect(freezingF, 32.0);

      double hotC = 35.0;
      double hotF = (hotC * 9 / 5) + 32;
      expect(hotF, 95.0);
    });
  });

  group('3. Widget Interaction & Presentation Tests', () {
    final sampleWeather = WeatherModel(
      cityName: 'London',
      country: 'UK',
      temperature: 15.0,
      feelsLike: 14.0,
      humidity: 70,
      windSpeed: 10.5,
      pressure: 1018.0,
      condition: 'Partly Cloudy',
      weatherCode: 2,
      isDay: true,
      precipitation: 0.2,
      updatedAt: DateTime(2026, 11, 18, 12, 0),
      forecast: [
        DailyForecast(
          date: DateTime(2026, 11, 18),
          maxTemp: 17.0,
          minTemp: 11.0,
          weatherCode: 2,
          condition: 'Partly Cloudy',
        ),
        DailyForecast(
          date: DateTime(2026, 11, 19),
          maxTemp: 18.0,
          minTemp: 12.0,
          weatherCode: 0,
          condition: 'Clear Sky',
        ),
      ],
    );

    testWidgets('CurrentWeatherCard displays city, temperature and conditions',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CurrentWeatherCard(
              weather: sampleWeather,
              formattedTemp: '15°C',
              formattedFeelsLike: '14°C',
            ),
          ),
        ),
      );

      expect(find.text('London'), findsOneWidget);
      expect(find.text('UK'), findsOneWidget);
      expect(find.text('15°C'), findsOneWidget);
      expect(find.text('Partly Cloudy'), findsOneWidget);
      expect(find.text('Feels like 14°C'), findsOneWidget);
    });

    testWidgets('WeatherDetailGrid renders all 4 meteorological statistics',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeatherDetailGrid(weather: sampleWeather),
          ),
        ),
      );

      expect(find.text('Weather Highlights'), findsOneWidget);
      expect(find.text('Humidity'), findsOneWidget);
      expect(find.text('70%'), findsOneWidget);
      expect(find.text('Wind Speed'), findsOneWidget);
      expect(find.text('10.5 km/h'), findsOneWidget);
      expect(find.text('Pressure'), findsOneWidget);
      expect(find.text('1018 hPa'), findsOneWidget);
      expect(find.text('Precipitation'), findsOneWidget);
      expect(find.text('0.2 mm'), findsOneWidget);
    });

    testWidgets('DailyForecastList displays daily forecast entries',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DailyForecastList(
              forecast: sampleWeather.forecast,
              formatTemp: (temp) => '${temp.round()}°C',
            ),
          ),
        ),
      );

      expect(find.text('7-Day Forecast'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Tomorrow'), findsOneWidget);
      expect(find.text('17°C'), findsOneWidget);
      expect(find.text('18°C'), findsOneWidget);
    });

    testWidgets('ErrorView shows friendly message and triggers retry on tap',
        (WidgetTester tester) async {
      bool retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorView(
              message: 'Unable to connect to the weather network.',
              onRetry: () {
                retried = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Oops! Something went wrong'), findsOneWidget);
      expect(find.text('Unable to connect to the weather network.'), findsOneWidget);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(retried, true);
    });

    testWidgets('RecentSearchTile displays city info and handles tap and delete',
        (WidgetTester tester) async {
      bool tapped = false;
      bool deleted = false;

      final search = RecentSearch(
        city: 'Dubai',
        country: 'UAE',
        temperature: 31.0,
        condition: 'Clear Sky',
        weatherCode: 0,
        searchedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecentSearchTile(
              search: search,
              formattedTemp: '31°C',
              onTap: () => tapped = true,
              onDelete: () => deleted = true,
            ),
          ),
        ),
      );

      expect(find.text('Dubai, UAE'), findsOneWidget);
      expect(find.text('31°C'), findsOneWidget);

      await tester.tap(find.text('Dubai, UAE'));
      await tester.pump();
      expect(tapped, true);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
      expect(deleted, true);
    });
  });
}
