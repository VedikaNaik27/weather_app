import 'package:flutter/material.dart';
import 'daily_forecast.dart';

class WeatherModel {
  final String cityName;
  final String country;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final double pressure;
  final String condition;
  final int weatherCode;
  final bool isDay;
  final double precipitation;
  final DateTime updatedAt;
  final List<DailyForecast> forecast;

  WeatherModel({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.condition,
    required this.weatherCode,
    required this.isDay,
    required this.precipitation,
    required this.updatedAt,
    required this.forecast,
  });

  /// Factory constructor to parse Open-Meteo JSON responses
  factory WeatherModel.fromOpenMeteo({
    required String cityName,
    required String country,
    required Map<String, dynamic> json,
  }) {
    final current = json['current'] as Map<String, dynamic>? ?? {};
    final daily = json['daily'] as Map<String, dynamic>? ?? {};

    final code = (current['weather_code'] as num?)?.toInt() ?? 0;
    final conditionName = _getConditionFromWmoCode(code);

    // Parse daily forecast
    final List<DailyForecast> forecastList = [];
    final times = daily['time'] as List<dynamic>? ?? [];
    final maxTemps = daily['temperature_2m_max'] as List<dynamic>? ?? [];
    final minTemps = daily['temperature_2m_min'] as List<dynamic>? ?? [];
    final weatherCodes = daily['weather_code'] as List<dynamic>? ?? [];

    for (int i = 0; i < times.length; i++) {
      final fCode = i < weatherCodes.length ? (weatherCodes[i] as num).toInt() : 0;
      forecastList.add(
        DailyForecast(
          date: DateTime.tryParse(times[i].toString()) ?? DateTime.now(),
          maxTemp: i < maxTemps.length ? (maxTemps[i] as num).toDouble() : 0.0,
          minTemp: i < minTemps.length ? (minTemps[i] as num).toDouble() : 0.0,
          weatherCode: fCode,
          condition: _getConditionFromWmoCode(fCode),
        ),
      );
    }

    return WeatherModel(
      cityName: cityName,
      country: country,
      temperature: (current['temperature_2m'] as num?)?.toDouble() ?? 0.0,
      feelsLike: (current['apparent_temperature'] as num?)?.toDouble() ?? 0.0,
      humidity: (current['relative_humidity_2m'] as num?)?.toInt() ?? 0,
      windSpeed: (current['wind_speed_10m'] as num?)?.toDouble() ?? 0.0,
      pressure: (current['surface_pressure'] as num?)?.toDouble() ?? 1013.25,
      condition: conditionName,
      weatherCode: code,
      isDay: (current['is_day'] as num?)?.toInt() == 1,
      precipitation: (current['precipitation'] as num?)?.toDouble() ?? 0.0,
      updatedAt: DateTime.now(),
      forecast: forecastList,
    );
  }

  /// Factory constructor to parse OpenWeatherMap JSON responses
  factory WeatherModel.fromOpenWeatherMap(Map<String, dynamic> json) {
    final main = json['main'] as Map<String, dynamic>? ?? {};
    final wind = json['wind'] as Map<String, dynamic>? ?? {};
    final sys = json['sys'] as Map<String, dynamic>? ?? {};
    final weatherList = json['weather'] as List<dynamic>? ?? [];
    final weatherFirst = weatherList.isNotEmpty ? weatherList[0] as Map<String, dynamic> : {};

    final conditionMain = weatherFirst['main'] as String? ?? 'Clear';
    final code = (weatherFirst['id'] as num?)?.toInt() ?? 800;

    return WeatherModel(
      cityName: json['name'] as String? ?? 'Unknown',
      country: sys['country'] as String? ?? '',
      temperature: (main['temp'] as num?)?.toDouble() ?? 0.0,
      feelsLike: (main['feels_like'] as num?)?.toDouble() ?? 0.0,
      humidity: (main['humidity'] as num?)?.toInt() ?? 0,
      windSpeed: (wind['speed'] as num?)?.toDouble() ?? 0.0,
      pressure: (main['pressure'] as num?)?.toDouble() ?? 1013.25,
      condition: conditionMain,
      weatherCode: code,
      isDay: true,
      precipitation: 0.0,
      updatedAt: DateTime.now(),
      forecast: [],
    );
  }

  /// Convert WMO weather codes to human-readable weather conditions
  static String _getConditionFromWmoCode(int code) {
    if (code == 0) return 'Clear Sky';
    if (code == 1) return 'Mainly Clear';
    if (code == 2) return 'Partly Cloudy';
    if (code == 3) return 'Overcast';
    if (code == 45 || code == 48) return 'Fog';
    if (code >= 51 && code <= 55) return 'Drizzle';
    if (code >= 61 && code <= 65) return 'Rain';
    if (code >= 71 && code <= 77) return 'Snow';
    if (code >= 80 && code <= 82) return 'Rain Showers';
    if (code >= 85 && code <= 86) return 'Snow Showers';
    if (code >= 95 && code <= 99) return 'Thunderstorm';
    return 'Cloudy';
  }

  /// Returns weather icon corresponding to the condition
  IconData get iconData {
    if (weatherCode == 0) {
      return isDay ? Icons.wb_sunny : Icons.nightlight_round;
    }
    if (weatherCode == 1 || weatherCode == 2) {
      return isDay ? Icons.wb_cloudy_outlined : Icons.cloud;
    }
    if (weatherCode == 3) {
      return Icons.cloud;
    }
    if (weatherCode == 45 || weatherCode == 48) {
      return Icons.waves;
    }
    if (weatherCode >= 51 && weatherCode <= 67) {
      return Icons.water_drop;
    }
    if (weatherCode >= 71 && weatherCode <= 77) {
      return Icons.ac_unit;
    }
    if (weatherCode >= 80 && weatherCode <= 82) {
      return Icons.grain;
    }
    if (weatherCode >= 95) {
      return Icons.flash_on;
    }
    return Icons.wb_cloudy;
  }

  /// Color palette / gradient according to weather and day/night
  List<Color> get gradientColors {
    if (!isDay) {
      return [
        const Color(0xFF0F2027),
        const Color(0xFF203A43),
        const Color(0xFF2C5364),
      ];
    }

    if (weatherCode == 0 || weatherCode == 1) {
      // Sunny / Clear
      return [
        const Color(0xFF2193b0),
        const Color(0xFF6dd5ed),
      ];
    }

    if (weatherCode >= 95) {
      // Thunderstorm
      return [
        const Color(0xFF373B44),
        const Color(0xFF4286f4),
      ];
    }

    if (weatherCode >= 51 && weatherCode <= 82) {
      // Rain
      return [
        const Color(0xFF3a7bd5),
        const Color(0xFF3a6073),
      ];
    }

    if (weatherCode >= 71 && weatherCode <= 77) {
      // Snow
      return [
        const Color(0xFF83a4d4),
        const Color(0xFFb6fbff),
      ];
    }

    // Default Cloudy
    return [
      const Color(0xFF4b6cb7),
      const Color(0xFF182848),
    ];
  }
}
