import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/weather_model.dart';

class WeatherDetailGrid extends StatelessWidget {
  final WeatherModel weather;

  const WeatherDetailGrid({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.insights, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Weather Highlights',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            // Determine column count based on available width
            final isVeryCompact = constraints.maxWidth < 320;
            if (isVeryCompact) {
              return Column(
                children: [
                  _buildDetailCard(
                    icon: Icons.water_drop,
                    label: 'Humidity',
                    value: '${weather.humidity}%',
                    subtext: _humidityLevel(weather.humidity),
                    color: const Color(0xFF4FC3F7),
                  ),
                  const SizedBox(height: 10),
                  _buildDetailCard(
                    icon: Icons.air,
                    label: 'Wind Speed',
                    value: '${weather.windSpeed.toStringAsFixed(1)} km/h',
                    subtext: _windDescription(weather.windSpeed),
                    color: const Color(0xFF81C784),
                  ),
                  const SizedBox(height: 10),
                  _buildDetailCard(
                    icon: Icons.speed,
                    label: 'Pressure',
                    value: '${weather.pressure.round()} hPa',
                    subtext: _pressureDescription(weather.pressure),
                    color: const Color(0xFFFFB74D),
                  ),
                  const SizedBox(height: 10),
                  _buildDetailCard(
                    icon: Icons.umbrella,
                    label: 'Precipitation',
                    value: '${weather.precipitation.toStringAsFixed(1)} mm',
                    subtext: weather.precipitation > 0 ? 'Precipitation detected' : 'Dry conditions',
                    color: const Color(0xFFBA68C8),
                  ),
                ],
              );
            }

            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailCard(
                        icon: Icons.water_drop,
                        label: 'Humidity',
                        value: '${weather.humidity}%',
                        subtext: _humidityLevel(weather.humidity),
                        color: const Color(0xFF4FC3F7),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDetailCard(
                        icon: Icons.air,
                        label: 'Wind Speed',
                        value: '${weather.windSpeed.toStringAsFixed(1)} km/h',
                        subtext: _windDescription(weather.windSpeed),
                        color: const Color(0xFF81C784),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailCard(
                        icon: Icons.speed,
                        label: 'Pressure',
                        value: '${weather.pressure.round()} hPa',
                        subtext: _pressureDescription(weather.pressure),
                        color: const Color(0xFFFFB74D),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDetailCard(
                        icon: Icons.umbrella,
                        label: 'Precipitation',
                        value: '${weather.precipitation.toStringAsFixed(1)} mm',
                        subtext: weather.precipitation > 0 ? 'Precipitation detected' : 'Dry conditions',
                        color: const Color(0xFFBA68C8),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String label,
    required String value,
    required String subtext,
    required Color color,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.22),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.28),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.white.withValues(alpha: 0.78),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtext,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.65),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _humidityLevel(int humidity) {
    if (humidity < 30) return 'Low / Dry air';
    if (humidity <= 60) return 'Comfortable';
    if (humidity <= 80) return 'Humid';
    return 'Very humid';
  }

  static String _windDescription(double speed) {
    if (speed < 5) return 'Calm breeze';
    if (speed < 20) return 'Moderate breeze';
    if (speed < 40) return 'Strong wind';
    return 'High gale';
  }

  static String _pressureDescription(double pressure) {
    if (pressure < 1000) return 'Low pressure';
    if (pressure <= 1020) return 'Normal atmospheric';
    return 'High pressure';
  }
}
