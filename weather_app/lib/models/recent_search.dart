class RecentSearch {
  final String city;
  final String country;
  final double temperature;
  final String condition;
  final int weatherCode;
  final DateTime searchedAt;

  RecentSearch({
    required this.city,
    required this.country,
    required this.temperature,
    required this.condition,
    required this.weatherCode,
    required this.searchedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'city': city,
      'country': country,
      'temperature': temperature,
      'condition': condition,
      'weatherCode': weatherCode,
      'searchedAt': searchedAt.toIso8601String(),
    };
  }

  factory RecentSearch.fromMap(Map<dynamic, dynamic> map) {
    return RecentSearch(
      city: map['city'] as String? ?? 'Unknown',
      country: map['country'] as String? ?? '',
      temperature: (map['temperature'] as num?)?.toDouble() ?? 0.0,
      condition: map['condition'] as String? ?? 'Clear',
      weatherCode: map['weatherCode'] as int? ?? 0,
      searchedAt: DateTime.tryParse(map['searchedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
