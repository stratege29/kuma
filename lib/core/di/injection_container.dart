import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';

// Features imports
import 'package:kuma/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:kuma/features/auth/data/datasources/auth_remote_data_source_v2.dart';
import 'package:kuma/features/auth/data/repositories/auth_repository_impl_v2.dart';
import 'package:kuma/features/auth/domain/repositories/auth_repository.dart';
import 'package:kuma/features/auth/presentation/bloc/auth_bloc.dart';

// Story features imports
import 'package:kuma/features/story/data/datasources/story_local_data_source.dart';
import 'package:kuma/features/story/data/datasources/story_remote_data_source.dart';
import 'package:kuma/features/story/data/repositories/story_repository_impl.dart';
import 'package:kuma/features/story/domain/repositories/story_repository.dart';

// Home features imports
import 'package:kuma/features/home/presentation/bloc/home_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Auth
  // Bloc
  sl.registerFactory(() => AuthBloc(authRepository: sl()));

  //! Features - Home
  // Bloc
  sl.registerFactory(() => HomeBloc(storyRepository: sl()));
  
  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImplV2(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );
  
  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSourceV2>(
    () => AuthRemoteDataSourceV2Impl(
      firebaseAuth: sl(),
      firestore: sl(),
      googleSignIn: sl(),
    ),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(hive: sl()),
  );

  //! Features - Story
  // Repository
  sl.registerLazySingleton<StoryRepository>(
    () => StoryRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );
  
  // Data sources
  sl.registerLazySingleton<StoryRemoteDataSource>(
    () => StoryRemoteDataSourceImpl(
      firestore: sl(),
    ),
  );
  sl.registerLazySingleton<StoryLocalDataSource>(
    () => StoryLocalDataSourceImpl(),
  );

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
  
  // Google Sign In
  sl.registerLazySingleton(() => GoogleSignIn());
  
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