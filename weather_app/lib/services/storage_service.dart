import 'package:hive_flutter/hive_flutter.dart';
import '../models/recent_search.dart';

class StorageService {
  static const String recentSearchesBoxName = 'recent_searches';
  static const String settingsBoxName = 'settings';

  static const String keyLastCity = 'last_city';
  static const String keyIsCelsius = 'is_celsius';
  static const String keyOpenWeatherApiKey = 'owm_api_key';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(recentSearchesBoxName);
    await Hive.openBox(settingsBoxName);
  }

  Box get _recentBox => Hive.box(recentSearchesBoxName);
  Box get _settingsBox => Hive.box(settingsBoxName);

  /// Get list of recent searches
  List<RecentSearch> getRecentSearches() {
    try {
      final rawList = _recentBox.values.toList();
      final searches = <RecentSearch>[];

      for (var item in rawList) {
        if (item is Map) {
          searches.add(RecentSearch.fromMap(item));
        }
      }

      // Sort with newest first
      searches.sort((a, b) => b.searchedAt.compareTo(a.searchedAt));
      return searches;
    } catch (e) {
      return [];
    }
  }

  /// Save or update a recent search
  Future<void> saveRecentSearch(RecentSearch search) async {
    try {
      // Check if city already exists, remove older entry to keep it unique
      dynamic existingKey;
      for (var key in _recentBox.keys) {
        final val = _recentBox.get(key);
        if (val is Map && (val['city'] as String?)?.toLowerCase() == search.city.toLowerCase()) {
          existingKey = key;
          break;
        }
      }

      if (existingKey != null) {
        await _recentBox.delete(existingKey);
      }

      // Keep maximum 15 recent searches
      if (_recentBox.length >= 15) {
        final firstKey = _recentBox.keys.first;
        await _recentBox.delete(firstKey);
      }

      await _recentBox.add(search.toMap());
      await saveLastCity(search.city);
    } catch (e) {
      // Local storage failure fallback
    }
  }

  /// Remove a specific search by city name
  Future<void> removeRecentSearch(String cityName) async {
    dynamic targetKey;
    for (var key in _recentBox.keys) {
      final val = _recentBox.get(key);
      if (val is Map && (val['city'] as String?)?.toLowerCase() == cityName.toLowerCase()) {
        targetKey = key;
        break;
      }
    }
    if (targetKey != null) {
      await _recentBox.delete(targetKey);
    }
  }

  /// Clear all recent searches
  Future<void> clearRecentSearches() async {
    await _recentBox.clear();
  }

  /// Save last searched city
  Future<void> saveLastCity(String cityName) async {
    await _settingsBox.put(keyLastCity, cityName);
  }

  /// Retrieve last searched city
  String? getLastCity() {
    return _settingsBox.get(keyLastCity) as String?;
  }

  /// Save temperature unit preference (true for Celsius, false for Fahrenheit)
  Future<void> setCelsius(bool isCelsius) async {
    await _settingsBox.put(keyIsCelsius, isCelsius);
  }

  /// Retrieve temperature unit preference
  bool isCelsius() {
    return _settingsBox.get(keyIsCelsius, defaultValue: true) as bool;
  }

  /// Save optional OpenWeatherMap API key
  Future<void> setOpenWeatherApiKey(String apiKey) async {
    await _settingsBox.put(keyOpenWeatherApiKey, apiKey);
  }

  /// Retrieve optional OpenWeatherMap API key
  String? getOpenWeatherApiKey() {
    return _settingsBox.get(keyOpenWeatherApiKey) as String?;
  }
}
