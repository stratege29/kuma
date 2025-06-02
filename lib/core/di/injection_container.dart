import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

// Features imports will be added as we create them
// import 'package:kuma/features/auth/data/datasources/auth_local_data_source.dart';
// import 'package:kuma/features/auth/data/datasources/auth_remote_data_source.dart';
// import 'package:kuma/features/auth/data/repositories/auth_repository_impl.dart';
// import 'package:kuma/features/auth/domain/repositories/auth_repository.dart';
// import 'package:kuma/features/auth/domain/usecases/login_anonymously.dart';
// import 'package:kuma/features/auth/presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Auth
  // Bloc
  // sl.registerFactory(() => AuthBloc(loginAnonymously: sl()));
  
  // Use cases
  // sl.registerLazySingleton(() => LoginAnonymously(sl()));
  
  // Repository
  // sl.registerLazySingleton<AuthRepository>(
  //   () => AuthRepositoryImpl(
  //     remoteDataSource: sl(),
  //     localDataSource: sl(),
  //   ),
  // );
  
  // Data sources
  // sl.registerLazySingleton<AuthRemoteDataSource>(
  //   () => AuthRemoteDataSourceImpl(firebaseAuth: sl()),
  // );
  // sl.registerLazySingleton<AuthLocalDataSource>(
  //   () => AuthLocalDataSourceImpl(hive: sl()),
  // );

  //! Core
  // sl.registerLazySingleton(() => InputConverter());
  // sl.registerLazySingleton(() => NetworkInfo(sl()));

  //! External
  await _registerExternalDependencies();
}

Future<void> _registerExternalDependencies() async {
  // Firebase
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  
  // Hive is registered but initFlutter is not used with HiveInterface
  sl.registerLazySingleton<HiveInterface>(() => Hive);
}

/// Initialize all feature dependencies
Future<void> initFeatures() async {
  // This will be called to register all feature-specific dependencies
  // _initAuth();
  // _initStory();
  // _initQuiz();
  // _initOnboarding();
}

// Individual feature initialization methods will be added here
// void _initAuth() { ... }
// void _initStory() { ... }
// void _initQuiz() { ... }
// void _initOnboarding() { ... }