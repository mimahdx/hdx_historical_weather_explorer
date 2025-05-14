import 'package:latlong2/latlong.dart';

import '../models/weather_data.dart';

sealed class HistoryState {}
class HistoryInitial extends HistoryState {}
class HistoryLoading extends HistoryState {}
class HistoryLoaded extends HistoryState {
  final WeatherData data;
  HistoryLoaded(this.data);
}
class HistoryError extends HistoryState {
  final String message;
  HistoryError(this.message);
}

class LocationCityResolved extends HistoryState {
  final String city;
  final LatLng location;

  LocationCityResolved({required this.city, required this.location});
}