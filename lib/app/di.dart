import 'package:get_it/get_it.dart';
import '../data/datasources/local/card_local_ds.dart';
import '../data/repositories/card_repository_impl.dart';
import '../domain/repositories/card_repository.dart';

/// Service locator for dependency injection
final getIt = GetIt.instance;

/// Initializes all dependencies
Future<void> setupDependencies() async {
  // Data layer
  final cardLocalDataSource = CardLocalDataSource();
  await cardLocalDataSource.init();
  getIt.registerSingleton<CardLocalDataSource>(cardLocalDataSource);
  
  // Repository
  getIt.registerLazySingleton<CardRepository>(
    () => CardRepositoryImpl(getIt<CardLocalDataSource>()),
  );
}