class DailyForecast {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final int weatherCode;
  final String condition;

  DailyForecast({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.weatherCode,
    required this.condition,
  });

  factory DailyForecast.fromJson({
    required String dateStr,
    required double maxTemp,
    required double minTemp,
    required int weatherCode,
    required String condition,
  }) {
    return DailyForecast(
      date: DateTime.tryParse(dateStr) ?? DateTime.now(),
      maxTemp: maxTemp,
      minTemp: minTemp,
      weatherCode: weatherCode,
      condition: condition,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'maxTemp': maxTemp,
      'minTemp': minTemp,
      'weatherCode': weatherCode,
      'condition': condition,
    };
  }
}
