import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<WeatherProvider>(context, listen: false);
    final savedKey = provider.storageService.getOpenWeatherApiKey();
    if (savedKey != null) {
      _apiKeyController.text = savedKey;
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = context.watch<WeatherProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Configuration'),
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 740),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
              // Preferences Section
              const Text(
                'PREFERENCES',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: Theme.of(context).dividerColor.withValues(alpha: 0.15),
                  ),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      Icons.thermostat,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: const Text(
                    'Temperature Unit',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    weatherProvider.isCelsius ? 'Celsius (°C)' : 'Fahrenheit (°F)',
                  ),
                  trailing: Switch(
                    value: weatherProvider.isCelsius,
                    activeTrackColor: Colors.blueAccent,
                    onChanged: (_) => weatherProvider.toggleTemperatureUnit(),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // REST API Configuration Section
              const Text(
                'REST API & LIVE DATA',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: Theme.of(context).dividerColor.withValues(alpha: 0.15),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.blue.withValues(alpha: 0.15),
                            child: const Icon(Icons.cloud_sync, color: Colors.blueAccent),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Live Weather REST API',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '• Primary Provider: Open-Meteo REST API (Free, Real-Time, CORS-Enabled, Zero API Key Required).\n• Reverse Geocoding: BigDataCloud Geocoding API.\n• Optional: You can provide an OpenWeatherMap API key below if required by your evaluator.',
                        style: TextStyle(fontSize: 13.5, height: 1.5),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _apiKeyController,
                        decoration: InputDecoration(
                          labelText: 'OpenWeatherMap API Key (Optional)',
                          hintText: 'Enter API key here...',
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_apiKeyController.text.isNotEmpty)
                                IconButton(
                                  icon: const Icon(Icons.clear, size: 20),
                                  onPressed: () async {
                                    _apiKeyController.clear();
                                    await weatherProvider.storageService.setOpenWeatherApiKey('');
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('API Key cleared. Using Open-Meteo.'),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              IconButton(
                                icon: const Icon(Icons.save),
                                tooltip: 'Save Key',
                                onPressed: () async {
                                  await weatherProvider.storageService
                                      .setOpenWeatherApiKey(_apiKeyController.text.trim());
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('API Key preference saved in Hive!'),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Local Storage Section
              const Text(
                'LOCAL STORAGE (HIVE DATABASE)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: Theme.of(context).dividerColor.withValues(alpha: 0.15),
                  ),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple.withValues(alpha: 0.15),
                    child: const Icon(Icons.storage, color: Colors.deepPurple),
                  ),
                  title: const Text(
                    'Stored Searches in Hive Box',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${weatherProvider.recentSearches.length} items recorded (IndexedDB on Web, Hive Box on Mobile)',
                  ),
                  trailing: TextButton(
                    onPressed: () async {
                      await weatherProvider.clearAllRecentSearches();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Hive storage cleared!'),
                          ),
                        );
                      }
                    },
                    child: const Text('Clear', style: TextStyle(color: Colors.red)),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Web & GPS Info
              if (kIsWeb) ...[
                const Text(
                  'BROWSER LOCATION GUIDANCE',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 0,
                  color: Theme.of(context).cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: Theme.of(context).dividerColor.withValues(alpha: 0.15),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, color: Colors.teal),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Web browsers require a secure connection (HTTPS or localhost) to access GPS location. If location prompt was previously dismissed, click the lock/settings icon in the browser address bar to allow location.',
                            style: TextStyle(fontSize: 13, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Project & Author Metadata
              const Text(
                'PROJECT & AUTHOR',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: Theme.of(context).dividerColor.withValues(alpha: 0.15),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Minor Project 03 — Weather App with Live API',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15.5,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Full-featured cross-platform Weather Website and Mobile Application built with Flutter, Provider, Hive, and Open-Meteo REST API.',
                        style: TextStyle(fontSize: 13.5, height: 1.4),
                      ),
                      SizedBox(height: 12),
                      Divider(),
                      SizedBox(height: 8),
                      Text(
                        'Developer: Vedika Naik',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'GitHub: VedikaNaik27',
                        style: TextStyle(fontSize: 13, color: Colors.blueAccent),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
