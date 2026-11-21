import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../services/weather_service.dart';
import '../widgets/recent_search_tile.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<CitySearchResult> _suggestions = [];
  bool _isSearchingSuggestions = false;
  Timer? _debounceTimer;

  static const List<String> popularCities = [
    'London',
    'New York',
    'Tokyo',
    'Paris',
    'Mumbai',
    'Singapore',
    'Dubai',
    'Sydney',
    'San Francisco',
  ];

  @override
  void initState() {
    super.initState();
    // Auto-focus on input
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _suggestions = [];
        _isSearchingSuggestions = false;
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 320), () async {
      setState(() => _isSearchingSuggestions = true);
      final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
      final results = await weatherProvider.weatherService.searchCities(query);
      if (mounted) {
        setState(() {
          _suggestions = results;
          _isSearchingSuggestions = false;
        });
      }
    });
  }

  void _selectCity(String cityName) {
    final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
    weatherProvider.fetchWeatherByCity(cityName);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = context.watch<WeatherProvider>();
    final recentSearches = weatherProvider.recentSearches;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () {
          Navigator.maybePop(context);
        },
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Search Worldwide Weather'),
          elevation: 0,
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Input Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Search city (e.g. Tokyo, Paris, New York)...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _controller.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _controller.clear();
                                _onQueryChanged('');
                              },
                            )
                          : null,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: _onQueryChanged,
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        _selectCity(value.trim());
                      }
                    },
                  ),
                ),

                // Popular Cities Quick Chips
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: popularCities.map((city) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ActionChip(
                            label: Text(city),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            onPressed: () => _selectCity(city),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Live suggestion loading progress
                if (_isSearchingSuggestions)
                  const LinearProgressIndicator(minHeight: 2),

                // Content: Live Suggestions OR Recent Searches from Hive
                Expanded(
                  child: _suggestions.isNotEmpty
                      ? _buildSuggestionsList()
                      : _buildRecentSearchesSection(weatherProvider, recentSearches),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionsList() {
    return ListView.builder(
      itemCount: _suggestions.length,
      itemBuilder: (context, index) {
        final item = _suggestions[index];
        return ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_city,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(
            item.admin1 != null && item.admin1!.isNotEmpty
                ? '${item.admin1}, ${item.country}'
                : item.country,
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
          onTap: () => _selectCity(item.name),
        );
      },
    );
  }

  Widget _buildRecentSearchesSection(
    WeatherProvider provider,
    List<dynamic> recentSearches,
  ) {
    if (recentSearches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            const Text(
              'No recent searches yet',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 6),
            const Text(
              'Search for a city above to save it to your local Hive database',
              style: TextStyle(fontSize: 12.5, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.history, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Recent Searches (Saved in Hive)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Clear Search History?'),
                      content: const Text(
                        'This will delete all saved search records from the local Hive database.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            provider.clearAllRecentSearches();
                            Navigator.pop(ctx);
                          },
                          child: const Text(
                            'Clear All',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text(
                  'Clear All',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: recentSearches.length,
            itemBuilder: (context, index) {
              final item = recentSearches[index];
              return RecentSearchTile(
                search: item,
                formattedTemp: provider.formatTemperature(item.temperature),
                onTap: () => _selectCity(item.city),
                onDelete: () => provider.removeRecentSearch(item.city),
              );
            },
          ),
        ),
      ],
    );
  }
}
