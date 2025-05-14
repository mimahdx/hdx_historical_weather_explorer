// lib/main_staging.dart
import 'package:flutter/material.dart';
import 'core/env.dart';
import 'core/service_locator.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Environment.env = Env.staging;
  await setupLocator();
  runApp(const HistoricalWeatherApp());
}