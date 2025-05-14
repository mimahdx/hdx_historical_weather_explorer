import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hdx_historical_weather_explorer/ui/home_page.dart';
import 'package:hdx_historical_weather_explorer/cubit/history_cubit.dart';
import 'package:hdx_historical_weather_explorer/cubit/history_state.dart';

class MockHistoryCubit extends Mock implements HistoryCubit {}

void main() {
  late MockHistoryCubit mockCubit;

  setUpAll(() {
    registerFallbackValue(DateTimeRange(
      start: DateTime(2020, 1, 1),
      end: DateTime(2020, 1, 2),
    ));
  });

  setUp(() {
    mockCubit = MockHistoryCubit();
    when(() => mockCubit.state).thenReturn(HistoryInitial());
    when(() => mockCubit.stream).thenAnswer((_) => const Stream<HistoryState>.empty());
    when(() => mockCubit.fetchHistoricalWeather(any(), any()))
        .thenAnswer((_) async {});
  });

  testWidgets('presses Get History button', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<HistoryCubit>.value(
          value: mockCubit,
          child: const HomePage(),
        ),
      ),
    );

    // Wait for initial build
    await tester.pumpAndSettle();

    final buttonFinder = find.widgetWithText(ElevatedButton, 'Get History');
    expect(buttonFinder, findsOneWidget);

    await tester.tap(buttonFinder);
    await tester.pump();

    verify(() => mockCubit.fetchHistoricalWeather(any(), any())).called(greaterThanOrEqualTo(1));
  });
}
