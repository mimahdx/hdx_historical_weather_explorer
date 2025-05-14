import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../core/env.dart';
import '../models/weather_data.dart';

class HistoryRepository {
  Future<Map<String, double>> getCoordinatesFromCity(String city) async {
    final url = Uri.parse(
      '${Environment.nominatimBaseUrl}/search?q=$city&format=json&limit=1',
    );

    final response = await http.get(
      url,
      headers: {
        'User-Agent': 'HistoricalWeatherExplorer/1.0 (irraex@gmail.com)',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.isNotEmpty) {
        final lat = double.parse(data[0]['lat']);
        final lon = double.parse(data[0]['lon']);
        return {'lat': lat, 'lon': lon};
      } else {
        throw Exception('City not found');
      }
    } else {
      throw Exception('Failed to fetch coordinates');
    }
  }

  Future<WeatherData> getHistoricalWeather(
    String city,
    DateTimeRange range,
  ) async {
    final startDate = range.start.toIso8601String().split("T")[0];
    final endDate = range.end.toIso8601String().split("T")[0];

    final coordinates = await getCoordinatesFromCity(city);
    final lat = coordinates['lat'];
    final lon = coordinates['lon'];

    final url = Uri.parse(
      '${Environment.meteostatBaseUrl}/point/monthly?lat=$lat&lon=$lon&start=$startDate&end=$endDate',
    );

    final response = await http.get(
      url,
      headers: {
        'x-rapidapi-host': 'meteostat.p.rapidapi.com',
        'x-rapidapi-key': Environment.meteostatApiKey,
      },
    );

    if (response.statusCode == 200) {
      final jsonMap = json.decode(response.body);
      var data = WeatherData.fromJson(jsonMap);
      data.city = city;
      data.lat = lat;
      data.lon = lon;
      return data;
    } else {
      throw Exception('Failed to load historical weather');
    }
  }

  Future<String> reverseGeocodeCity(LatLng location) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse?lat=${location.latitude}&lon=${location.longitude}&format=json',
    );

    final response = await http.get(
      url,
      headers: {
        'User-Agent': 'HistoricalWeatherExplorer/1.0 (irraexc@gmail.com)',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final city =
          data['address']['city'] ??
          data['address']['town'] ??
          data['address']['village'] ??
          data['address']['state'] ??
          'Unknown';
      return city;
    } else {
      throw Exception('Failed to reverse geocode');
    }
  }
}
