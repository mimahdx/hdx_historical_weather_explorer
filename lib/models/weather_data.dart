class WeatherData {
  String? city;
  double? lat;
  double? lon;
  final double? tempAvg;
  final double? tempMin;
  final double? tempMax;
  final double? precip;

  WeatherData({this.city, this.lat, this.lon, this.tempAvg, this.tempMin, this.tempMax, this.precip});

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final data = json['data'][0];
    return WeatherData(
      tempAvg: data['tavg']?.toDouble(),
      tempMin: data['tmin']?.toDouble(),
      tempMax: data['tmax']?.toDouble(),
      precip: data['prcp']?.toDouble(),
    );
  }
}