import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather_model.dart';

class CurrentWeatherCard extends StatelessWidget {
  final WeatherModel weather;
  final String formattedTemp;
  final String formattedFeelsLike;
  final VoidCallback? onRefresh;

  const CurrentWeatherCard({
    super.key,
    required this.weather,
    required this.formattedTemp,
    required this.formattedFeelsLike,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('EEEE, d MMMM • h:mm a').format(weather.updatedAt);
    final todayForecast = weather.forecast.isNotEmpty ? weather.forecast.first : null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.28),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 24,
                spreadRadius: 2,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              // City Name, Country Badge & Day/Night Indicator
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: 26,
                  ),
                  Text(
                    weather.cityName,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (weather.country.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        weather.country,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: weather.isDay
                          ? Colors.amber.withValues(alpha: 0.3)
                          : Colors.indigo.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          weather.isDay ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                          size: 13,
                          color: weather.isDay ? Colors.amberAccent : Colors.lightBlueAccent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          weather.isDay ? 'Day' : 'Night',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Date and Time
              Text(
                timeStr,
                style: TextStyle(
                  fontSize: 13.5,
                  color: Colors.white.withValues(alpha: 0.88),
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 22),

              // Weather Condition Icon with circular glow
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.1),
                      blurRadius: 18,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Icon(
                  weather.iconData,
                  size: 76,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 18),

              // Main Temperature
              Text(
                formattedTemp,
                style: const TextStyle(
                  fontSize: 68,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                  height: 1.0,
                  letterSpacing: -1,
                ),
              ),

              const SizedBox(height: 8),

              // Weather Condition Description
              Text(
                weather.condition,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 8),

              // Feels like & High/Low badges
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 6,
                children: [
                  Text(
                    'Feels like $formattedFeelsLike',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.92),
                    ),
                  ),
                  if (todayForecast != null) ...[
                    Text(
                      '•',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                    Text(
                      'H: ${(todayForecast.maxTemp).round()}°  L: ${(todayForecast.minTemp).round()}°',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.92),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
