import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:latlong2/latlong.dart';
import 'package:hdx_historical_weather_explorer/cubit/history_cubit.dart';
import 'package:hdx_historical_weather_explorer/cubit/history_state.dart';
import 'package:hdx_historical_weather_explorer/data/history_repository.dart';
import 'package:hdx_historical_weather_explorer/models/weather_data.dart';

class MockHistoryRepository extends Mock implements HistoryRepository {}

class FakeDateTimeRange extends Fake implements DateTimeRange {}
class FakeLatLng extends Fake implements LatLng {}

void main() {
  late HistoryCubit cubit;
  late MockHistoryRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(FakeDateTimeRange());
    registerFallbackValue(FakeLatLng());
  });

  setUp(() {
    mockRepo = MockHistoryRepository();
    cubit = HistoryCubit(mockRepo);
  });

  group('fetchHistoricalWeather', () {
    final dummyData = WeatherData(
      city: 'Cebu',
      lat: 10.0,
      lon: 123.0,
      tempAvg: 28.0,
      tempMin: 24.0,
      tempMax: 32.0,
      precip: 5.0,
    );

    final range = DateTimeRange(
      start: DateTime(2024, 1, 1),
      end: DateTime(2024, 1, 2),
    );

    test('emits [Loading, Loaded] on success', () async {
      when(() => mockRepo.getHistoricalWeather('Cebu', range))
          .thenAnswer((_) async => dummyData);

      final emitted = <HistoryState>[];
      final sub = cubit.stream.listen(emitted.add);

      await cubit.fetchHistoricalWeather('Cebu', range);
      await Future.delayed(Duration.zero); 

      expect(emitted.length, 2);
      expect(emitted[0], isA<HistoryLoading>());
      expect(emitted[1], isA<HistoryLoaded>()
          .having((s) => s.data.city, 'city', 'Cebu'));

      await sub.cancel();
    });

    test('emits [Loading, Error] on failure', () async {
      when(() => mockRepo.getHistoricalWeather(any(), any()))
          .thenThrow(Exception('fail'));

      final emitted = <HistoryState>[];
      final sub = cubit.stream.listen(emitted.add);

      await cubit.fetchHistoricalWeather('FailCity', range);
      await Future.delayed(Duration.zero);

      expect(emitted.length, 2);
      expect(emitted[0], isA<HistoryLoading>());
      expect(emitted[1], isA<HistoryError>());

      await sub.cancel();
    });
  });

  group('fetchReverseGeocodedCity', () {
    final dummyLocation = LatLng(10.0, 123.0);

    test('emits LocationCityResolved on success', () async {
      when(() => mockRepo.reverseGeocodeCity(dummyLocation))
          .thenAnswer((_) async => 'Cebu');

      final emitted = <HistoryState>[];
      final sub = cubit.stream.listen(emitted.add);

      await cubit.fetchReverseGeocodedCity(dummyLocation);
      await Future.delayed(Duration.zero);

      expect(emitted.length, 1);
      expect(emitted[0], isA<LocationCityResolved>()
          .having((s) => s.city, 'city', 'Cebu')
          .having((s) => s.location.latitude, 'lat', 10.0)
          .having((s) => s.location.longitude, 'lon', 123.0));

      await sub.cancel();
    });

    test('emits HistoryError on failure', () async {
      when(() => mockRepo.reverseGeocodeCity(any()))
          .thenThrow(Exception('fail'));

      final emitted = <HistoryState>[];
      final sub = cubit.stream.listen(emitted.add);

      await cubit.fetchReverseGeocodedCity(LatLng(0, 0));
      await Future.delayed(Duration.zero);

      expect(emitted.length, 1);
      expect(emitted[0], isA<HistoryError>());

      await sub.cancel();
    });
  });
}
