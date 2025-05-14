import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import '../data/history_repository.dart';
import 'history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  final HistoryRepository repo;
  HistoryCubit(this.repo) : super(HistoryInitial());

  Future<void> fetchHistoricalWeather(String city, DateTimeRange range) async {
    emit(HistoryLoading());
    try {
      final data = await repo.getHistoricalWeather(city, range);
      emit(HistoryLoaded(data));
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }

   Future<void> fetchReverseGeocodedCity(LatLng location) async {
    try {
      final city = await repo.reverseGeocodeCity(location);
      emit(LocationCityResolved(city: city, location: location));
    } catch (e) {
      emit(HistoryError('Failed to get city from location'));
    }
  }
}
