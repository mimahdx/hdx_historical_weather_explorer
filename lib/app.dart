import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/service_locator.dart';
import 'cubit/history_cubit.dart';
import 'data/history_repository.dart';
import 'ui/home_page.dart';

class HistoricalWeatherApp extends StatelessWidget {
  const HistoricalWeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Historical Weather Explorer',
      home: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => HistoryCubit(sl<HistoryRepository>()),
          ),
        ],
        child: const HomePage(),
      ),
    );
  }
}
