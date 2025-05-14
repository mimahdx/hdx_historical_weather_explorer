enum Env { prod, dev, staging }

class Environment {
  static late Env env;

  static String get packageName => 'com.example.historical_weather_explorer';

  static String get baseUrl => 'https://meteostat.p.rapidapi.com';
  static String get apiKey => 'afabcc77efmshd3169f481d5c978p12be0cjsn2143b6017db9';

  static String get nominatimBaseUrl => 'https://nominatim.openstreetmap.org';
  static String get openstreetmapTileUrl => 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
}

