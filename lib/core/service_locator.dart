
import 'package:get_it/get_it.dart';
import '../data/history_repository.dart';

final sl = GetIt.instance;

Future<void> setupLocator() async {
  sl.registerLazySingleton(() => HistoryRepository());
}