import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/current_weather_card.dart';
import '../widgets/daily_forecast_list.dart';
import '../widgets/error_view.dart';
import '../widgets/weather_detail_grid.dart';
import 'search_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<String> quickCities = [
    'London',
    'New York',
    'Tokyo',
    'Paris',
    'Mumbai',
    'Sydney',
    'Dubai',
  ];

  @override
  Widget build(BuildContext context) {
    final weatherProvider = context.watch<WeatherProvider>();
    final weather = weatherProvider.currentWeather;
    final isLoading = weatherProvider.isLoading;
    final errorMessage = weatherProvider.errorMessage;

    // Background gradient derived from current weather or default calm sky
    final List<Color> gradientColors = weather != null
        ? weather.gradientColors
        : [const Color(0xFF1B2A47), const Color(0xFF2C5364)];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'SkyPulse Weather',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        actions: [
          // Unit toggle pill button (°C / °F)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              onPressed: () => weatherProvider.toggleTemperatureUnit(),
              child: Text(
                weatherProvider.isCelsius ? '°C' : '°F',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),

          // Detect GPS Location
          IconButton(
            icon: const Icon(Icons.my_location, color: Colors.white),
            tooltip: kIsWeb ? 'Current Location (GPS)' : 'Device GPS Location',
            onPressed: () {
              weatherProvider.fetchWeatherByLocation();
            },
          ),

          // Manual Refresh Button (Essential for Web & Desktop)
          IconButton(
            icon: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh Weather',
            onPressed: isLoading
                ? null
                : () {
                    if (weather != null) {
                      weatherProvider.fetchWeatherByCity(
                        weather.cityName,
                        saveToRecent: false,
                      );
                    } else {
                      weatherProvider.fetchWeatherByLocation();
                    }
                  },
          ),

          // Search City
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            tooltip: 'Search City',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
          ),

          // Settings
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            tooltip: 'Settings & Info',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gradientColors,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 900;

              if (isLoading && weather == null) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 20),
                      Text(
                        'Fetching live real-time weather...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (errorMessage != null && weather == null) {
                return ErrorView(
                  message: errorMessage,
                  onRetry: () {
                    weatherProvider.fetchWeatherByLocation();
                  },
                );
              }

              if (weather == null) {
                return Center(
                  child: ElevatedButton.icon(
                    onPressed: () => weatherProvider.fetchWeatherByLocation(),
                    icon: const Icon(Icons.location_on),
                    label: const Text('Detect Current Location'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                    ),
                  ),
                );
              }

              // Responsive Content Wrapper
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1240),
                  child: RefreshIndicator(
                    color: Colors.blueAccent,
                    backgroundColor: Colors.white,
                    onRefresh: () async {
                      await weatherProvider.fetchWeatherByCity(
                        weather.cityName,
                        saveToRecent: false,
                      );
                    },
                    child: Stack(
                      children: [
                        isDesktop
                            ? _buildDesktopLayout(context, weatherProvider, weather)
                            : _buildMobileLayout(context, weatherProvider, weather),

                        // Subtle update banner when refreshing in background
                        if (isLoading)
                          Positioned(
                            top: 8,
                            right: 20,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.45),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Updating...',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Desktop / Wide-Screen Multi-Column Dashboard
  Widget _buildDesktopLayout(
    BuildContext context,
    WeatherProvider provider,
    dynamic weather,
  ) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      children: [
        // Quick City Selector bar
        _buildQuickCityBar(provider, weather.cityName),

        const SizedBox(height: 16),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Hero Column: Current Weather Card & City Selector
            SizedBox(
              width: 440,
              child: Column(
                children: [
                  CurrentWeatherCard(
                    weather: weather,
                    formattedTemp: provider.formatTemperature(weather.temperature),
                    formattedFeelsLike: provider.formatTemperature(weather.feelsLike),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 24),

            // Right Highlights & Forecast Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WeatherDetailGrid(weather: weather),
                  const SizedBox(height: 20),
                  DailyForecastList(
                    forecast: weather.forecast,
                    formatTemp: (temp) => provider.formatTemperature(temp),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Mobile & Tablet Streamlined Layout
  Widget _buildMobileLayout(
    BuildContext context,
    WeatherProvider provider,
    dynamic weather,
  ) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // Quick City Selector bar
        _buildQuickCityBar(provider, weather.cityName),

        const SizedBox(height: 16),

        // Primary Weather Card
        CurrentWeatherCard(
          weather: weather,
          formattedTemp: provider.formatTemperature(weather.temperature),
          formattedFeelsLike: provider.formatTemperature(weather.feelsLike),
        ),

        const SizedBox(height: 20),

        // Weather Details Grid
        WeatherDetailGrid(weather: weather),

        const SizedBox(height: 20),

        // 7-Day Forecast Section
        DailyForecastList(
          forecast: weather.forecast,
          formatTemp: (temp) => provider.formatTemperature(temp),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  /// Quick City Chips Bar
  Widget _buildQuickCityBar(WeatherProvider provider, String currentCity) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              avatar: const Icon(Icons.my_location, size: 16, color: Colors.white),
              label: const Text('My Location'),
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              labelStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
              onPressed: () => provider.fetchWeatherByLocation(),
            ),
          ),
          ...quickCities.map((city) {
            final isSelected = city.toLowerCase() == currentCity.toLowerCase();
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(city),
                selected: isSelected,
                selectedColor: Colors.white,
                backgroundColor: Colors.white.withValues(alpha: 0.16),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.blue.shade900 : Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.25),
                  ),
                ),
                onSelected: (_) {
                  provider.fetchWeatherByCity(city);
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
