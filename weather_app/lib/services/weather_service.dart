import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class CitySearchResult {
  final String name;
  final String country;
  final String? admin1;
  final double latitude;
  final double longitude;

  CitySearchResult({
    required this.name,
    required this.country,
    this.admin1,
    required this.latitude,
    required this.longitude,
  });

  String get displayName {
    if (country.isEmpty || country.trim().toLowerCase() == name.trim().toLowerCase()) {
      return admin1 != null && admin1!.isNotEmpty && admin1 != name
          ? '$name, $admin1'
          : name;
    }
    if (admin1 != null && admin1!.isNotEmpty && admin1 != name) {
      return '$name, $admin1, $country';
    }
    return '$name, $country';
  }
}

class WeatherService {
  static const Duration timeoutDuration = Duration(seconds: 12);

  /// Search city suggestions by name (autocomplete / suggestions)
  Future<List<CitySearchResult>> searchCities(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return [];

    final url = Uri.parse(
      'https://geocoding-api.open-meteo.com/v1/search?name=${Uri.encodeComponent(cleanQuery)}&count=6&language=en&format=json',
    );

    try {
      final response = await http.get(url).timeout(timeoutDuration);
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>?;
        if (results == null) return [];

        return results.map((item) {
          final m = item as Map<String, dynamic>;
          return CitySearchResult(
            name: m['name'] as String? ?? '',
            country: m['country'] as String? ?? '',
            admin1: m['admin1'] as String?,
            latitude: (m['latitude'] as num).toDouble(),
            longitude: (m['longitude'] as num).toDouble(),
          );
        }).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Fetch weather by city name
  Future<WeatherModel> fetchWeatherByCity(
    String cityName, {
    String? openWeatherApiKey,
  }) async {
    final trimmedCity = cityName.trim();
    if (trimmedCity.isEmpty) {
      throw Exception('City name cannot be empty.');
    }

    // If an OpenWeatherMap API key is provided, attempt OpenWeatherMap first
    if (openWeatherApiKey != null && openWeatherApiKey.trim().isNotEmpty) {
      try {
        final owmUrl = Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=${Uri.encodeComponent(trimmedCity)}&appid=${openWeatherApiKey.trim()}&units=metric',
        );
        final response = await http.get(owmUrl).timeout(timeoutDuration);
        if (response.statusCode == 200) {
          final data = json.decode(response.body) as Map<String, dynamic>;
          return WeatherModel.fromOpenWeatherMap(data);
        }
      } catch (_) {
        // Fall back to Open-Meteo
      }
    }

    try {
      // Step 1: Geocode city name to lat & lon using Open-Meteo
      final geoUrl = Uri.parse(
        'https://geocoding-api.open-meteo.com/v1/search?name=${Uri.encodeComponent(trimmedCity)}&count=1&language=en&format=json',
      );

      final geoResponse = await http.get(geoUrl).timeout(timeoutDuration);

      if (geoResponse.statusCode != 200) {
        throw Exception('Geocoding service unavailable (${geoResponse.statusCode}).');
      }

      final geoData = json.decode(geoResponse.body) as Map<String, dynamic>;
      final results = geoData['results'] as List<dynamic>?;

      if (results == null || results.isEmpty) {
        throw Exception('City "$trimmedCity" not found. Please check spelling.');
      }

      final match = results[0] as Map<String, dynamic>;
      final double lat = (match['latitude'] as num).toDouble();
      final double lon = (match['longitude'] as num).toDouble();
      final String resolvedCity = match['name'] as String? ?? trimmedCity;
      final String country = match['country'] as String? ?? '';

      // Step 2: Fetch weather details using coordinates
      return await fetchWeatherByCoordinates(
        lat,
        lon,
        cityName: resolvedCity,
        country: country,
      );
    } on http.ClientException {
      throw Exception('Network connection error. Please check your internet connection.');
    } on TimeoutException {
      throw Exception('Connection timed out. Please check your network.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to fetch weather: $e');
    }
  }

  /// Fetch weather by latitude and longitude coordinates
  Future<WeatherModel> fetchWeatherByCoordinates(
    double latitude,
    double longitude, {
    String? cityName,
    String? country,
    String? openWeatherApiKey,
  }) async {
    // If an OpenWeatherMap API key is provided, attempt OpenWeatherMap first
    if (openWeatherApiKey != null && openWeatherApiKey.trim().isNotEmpty) {
      try {
        final owmUrl = Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=${openWeatherApiKey.trim()}&units=metric',
        );
        final response = await http.get(owmUrl).timeout(timeoutDuration);
        if (response.statusCode == 200) {
          final data = json.decode(response.body) as Map<String, dynamic>;
          return WeatherModel.fromOpenWeatherMap(data);
        }
      } catch (_) {
        // Fall back to Open-Meteo
      }
    }

    try {
      final forecastUrl = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude'
        '&current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,weather_code,wind_speed_10m,surface_pressure'
        '&daily=weather_code,temperature_2m_max,temperature_2m_min&timezone=auto',
      );

      final response = await http.get(forecastUrl).timeout(timeoutDuration);

      if (response.statusCode != 200) {
        throw Exception('Weather service returned status ${response.statusCode}');
      }

      final data = json.decode(response.body) as Map<String, dynamic>;

      return WeatherModel.fromOpenMeteo(
        cityName: cityName ?? 'Location (${latitude.toStringAsFixed(2)}, ${longitude.toStringAsFixed(2)})',
        country: country ?? '',
        json: data,
      );
    } on http.ClientException {
      throw Exception('Network connection error. Please check your internet connection.');
    } on TimeoutException {
      throw Exception('Connection timed out. Please check your network.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to fetch weather: $e');
    }
  }
}
