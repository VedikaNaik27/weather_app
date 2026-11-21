import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class LocationResult {
  final double latitude;
  final double longitude;
  final String cityName;
  final String country;

  LocationResult({
    required this.latitude,
    required this.longitude,
    required this.cityName,
    required this.country,
  });
}

class LocationService {
  /// Check permissions and get current GPS coordinates with reverse geocoding
  Future<LocationResult> getCurrentLocation() async {
    // 1. Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (kIsWeb) {
        throw Exception(
          'Browser geolocation is disabled or not supported. Please allow location access or search by city name.',
        );
      } else {
        throw Exception(
          'Location services are disabled on your device. Please turn on GPS.',
        );
      }
    }

    // 2. Check and request permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (kIsWeb) {
          throw Exception(
            'Location access was denied. Please allow location permissions in your browser or search for a city.',
          );
        } else {
          throw Exception(
            'Location permissions are denied. Please grant location access.',
          );
        }
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (kIsWeb) {
        throw Exception(
          'Location access is blocked in your browser site permissions. Please click the icon in your address bar to allow location.',
        );
      } else {
        throw Exception(
          'Location permissions are permanently denied. Please enable them in device settings.',
        );
      }
    }

    // 3. Get device position
    Position position;
    try {
      position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 12),
        ),
      );
    } catch (_) {
      // Fallback to last known position if current times out
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        position = lastKnown;
      } else {
        throw Exception(
          'Unable to acquire location coordinates. Please try again or search by city.',
        );
      }
    }

    // 4. Reverse geocode coordinates to get human-friendly city and country
    String cityName = 'Current Location';
    String country = '';

    try {
      final reverseUrl = Uri.parse(
        'https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=${position.latitude}&longitude=${position.longitude}&localityLanguage=en',
      );
      final response = await http.get(reverseUrl).timeout(
            const Duration(seconds: 8),
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final city = data['city'] as String? ??
            data['locality'] as String? ??
            data['principalSubdivision'] as String?;
        final cName = data['countryName'] as String? ?? '';

        if (city != null && city.trim().isNotEmpty) {
          cityName = city;
        }
        country = cName;
      }
    } catch (_) {
      // Graceful fallback when reverse geocoding is unavailable
      cityName = 'My Location';
    }

    return LocationResult(
      latitude: position.latitude,
      longitude: position.longitude,
      cityName: cityName,
      country: country,
    );
  }
}
