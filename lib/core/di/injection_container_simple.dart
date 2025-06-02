import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Core - Simple initialization without Firebase
  
  //! External
  await _registerExternalDependencies();
}

Future<void> _registerExternalDependencies() async {
  // Hive only (no Firebase)
  sl.registerLazySingleton<HiveInterface>(() => Hive);
}

/// Initialize all feature dependencies
Future<void> initFeatures() async {
  // This will be called to register all feature-specific dependencies
  // when Firebase is properly configured
}