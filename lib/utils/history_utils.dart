import '../models/weather_data.dart';

class HistoryUtils {
  static String generateWeatherHistorySummary(WeatherData data) {
    final temp = data.tempAvg ?? 0;
    final prcp = data.precip ?? 0;
    if (temp > 25 && prcp == 0) return 'It was hot and dry during this period.';
    if (temp < 10) return 'It was quite cold. Dress warmly.';
    if (prcp > 5) return 'Some wet days due to notable rainfall.';
    return 'The weather was fairly mild with occasional variation.';
  }
}
