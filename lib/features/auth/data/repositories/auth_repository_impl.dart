import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kuma/core/error/failure.dart';
import 'package:kuma/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:kuma/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:kuma/features/auth/domain/repositories/auth_repository.dart';
import 'package:kuma/shared/domain/entities/user.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, AppUser>> signInAnonymously() async {
    try {
      final firebaseUser = await remoteDataSource.signInAnonymously();

      // Créer un AppUser par défaut
      final appUser = AppUser(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        userType: 'parent',
        settings: const UserSettings(
          startingCountry: '',
          primaryGoal: '',
          preferredReadingTime: '',
          language: 'fr',
        ),
        childProfiles: [],
        progress: const UserProgress(
          currentCountry: '',
          completedStories: {},
          quizResults: {},
          totalStoriesRead: 0,
          totalTimeSpent: 0,
          unlockedCountries: [],
          achievements: [],
        ),
        preferences: const UserPreferences(),
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      // Sauvegarder dans Firestore
      await remoteDataSource.saveUserData(appUser);

      return Right(appUser);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(
        message: 'Erreur d\'authentification: ${e.message}',
        code: e.code,
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Erreur inconnue: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<Failure, AppUser?>> getCurrentUser() async {
    try {
      final firebaseUser = await remoteDataSource.getCurrentUser();
      if (firebaseUser == null) {
        return const Right(null);
      }

      final appUser = await remoteDataSource.getUserData(firebaseUser.uid);
      return Right(appUser);
    } catch (e) {
      return Left(UnknownFailure(
        message:
            'Erreur lors de la récupération de l\'utilisateur: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      await localDataSource.clearCache();
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Erreur lors de la déconnexion: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> saveUserSettings(UserSettings settings) async {
    try {
      await localDataSource.cacheUserSettings(settings);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(
        message: 'Erreur lors de la sauvegarde: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<Failure, UserSettings?>> getUserSettings() async {
    try {
      final settings = await localDataSource.getLastUserSettings();
      return Right(settings);
    } catch (e) {
      return Left(CacheFailure(
        message: 'Erreur lors de la récupération: ${e.toString()}',
      ));
    }
  }
}
