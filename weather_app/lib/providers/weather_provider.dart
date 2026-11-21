import 'package:flutter/foundation.dart';
import '../models/recent_search.dart';
import '../models/weather_model.dart';
import '../services/location_service.dart';
import '../services/storage_service.dart';
import '../services/weather_service.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  final LocationService _locationService = LocationService();
  final StorageService _storageService = StorageService();

  WeatherModel? _currentWeather;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isCelsius = true;
  List<RecentSearch> _recentSearches = [];

  // Getters
  WeatherModel? get currentWeather => _currentWeather;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isCelsius => _isCelsius;
  List<RecentSearch> get recentSearches => _recentSearches;
  WeatherService get weatherService => _weatherService;
  StorageService get storageService => _storageService;

  WeatherProvider() {
    _init();
  }

  /// Initialize state from Hive local storage
  Future<void> _init() async {
    _isCelsius = _storageService.isCelsius();
    _loadRecentSearches();

    // Check if there is a last searched city to restore
    final lastCity = _storageService.getLastCity();
    if (lastCity != null && lastCity.isNotEmpty) {
      await fetchWeatherByCity(lastCity, saveToRecent: false);
    } else {
      // Try GPS first, or fallback to a standard city
      try {
        await fetchWeatherByLocation();
      } catch (_) {
        await fetchWeatherByCity('London', saveToRecent: false);
      }
    }
  }

  /// Load recent searches from Hive
  void _loadRecentSearches() {
    _recentSearches = _storageService.getRecentSearches();
    notifyListeners();
  }

  /// Fetch weather for a specific city name
  Future<void> fetchWeatherByCity(String cityName, {bool saveToRecent = true}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final apiKey = _storageService.getOpenWeatherApiKey();
      final weather = await _weatherService.fetchWeatherByCity(
        cityName,
        openWeatherApiKey: apiKey,
      );

      _currentWeather = weather;
      _errorMessage = null;

      if (saveToRecent) {
        final recent = RecentSearch(
          city: weather.cityName,
          country: weather.country,
          temperature: weather.temperature,
          condition: weather.condition,
          weatherCode: weather.weatherCode,
          searchedAt: DateTime.now(),
        );
        await _storageService.saveRecentSearch(recent);
        _loadRecentSearches();
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch weather for the current GPS device location
  Future<void> fetchWeatherByLocation() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final location = await _locationService.getCurrentLocation();
      final apiKey = _storageService.getOpenWeatherApiKey();

      final weather = await _weatherService.fetchWeatherByCoordinates(
        location.latitude,
        location.longitude,
        cityName: location.cityName,
        country: location.country,
        openWeatherApiKey: apiKey,
      );

      _currentWeather = weather;
      _errorMessage = null;

      final recent = RecentSearch(
        city: weather.cityName,
        country: weather.country,
        temperature: weather.temperature,
        condition: weather.condition,
        weatherCode: weather.weatherCode,
        searchedAt: DateTime.now(),
      );
      await _storageService.saveRecentSearch(recent);
      _loadRecentSearches();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggle temperature unit between Celsius and Fahrenheit
  Future<void> toggleTemperatureUnit() async {
    _isCelsius = !_isCelsius;
    await _storageService.setCelsius(_isCelsius);
    notifyListeners();
  }

  /// Formatted temperature with unit (°C or °F)
  String formatTemperature(double celsius) {
    if (_isCelsius) {
      return '${celsius.round()}°C';
    } else {
      final fahrenheit = (celsius * 9 / 5) + 32;
      return '${fahrenheit.round()}°F';
    }
  }

  /// Delete a recent search entry
  Future<void> removeRecentSearch(String cityName) async {
    await _storageService.removeRecentSearch(cityName);
    _loadRecentSearches();
  }

  /// Clear all recent search entries from Hive
  Future<void> clearAllRecentSearches() async {
    await _storageService.clearRecentSearches();
    _loadRecentSearches();
  }
}
