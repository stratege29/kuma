import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kuma/core/error/failure.dart';
import 'package:kuma/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:kuma/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:kuma/features/auth/domain/repositories/auth_repository.dart';
import 'package:kuma/shared/domain/entities/user.dart';
import 'package:kuma/features/onboarding/presentation/bloc/onboarding_bloc.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  // Helper method to create or update AppUser from Firebase User
  Future<AppUser> _createOrUpdateAppUser(User firebaseUser, {bool isNewUser = false}) async {
    // Try to get existing user data
    AppUser? existingUser = await remoteDataSource.getUserData(firebaseUser.uid);
    
    if (existingUser != null) {
      // Update last login
      final updatedUser = existingUser.copyWith(
        lastLoginAt: DateTime.now(),
      );
      await remoteDataSource.saveUserData(updatedUser);
      return updatedUser;
    }
    
    // Create new user if doesn't exist
    final savedSettings = UserSettingsStore.getSettings();
    final newUser = AppUser(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      userType: 'parent',
      settings: savedSettings ?? const UserSettings(
        startingCountry: '',
        primaryGoal: '',
        preferredReadingTime: '',
        language: 'fr',
        isOnboardingCompleted: false,
      ),
      childProfiles: [],
      progress: UserProgress(
        currentCountry: savedSettings?.startingCountry ?? '',
        completedStories: const {},
        quizResults: const {},
        totalStoriesRead: 0,
        totalTimeSpent: 0,
        unlockedCountries: savedSettings?.startingCountry?.isNotEmpty == true 
            ? [savedSettings!.startingCountry] 
            : [],
        achievements: const [],
      ),
      preferences: const UserPreferences(),
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
    
    await remoteDataSource.saveUserData(newUser);
    return newUser;
  }


  @override
  Future<Either<Failure, AppUser>> signInWithGoogle() async {
    return Left(AuthFailure(
      message: 'Google Sign-In non implémenté dans cette version',
    ));
  }

  @override
  Future<Either<Failure, AppUser>> signInWithApple() async {
    return Left(AuthFailure(
      message: 'Apple Sign-In non implémenté dans cette version',
    ));
  }

  @override
  Future<Either<Failure, AppUser>> signInWithEmailPassword(String email, String password) async {
    return Left(AuthFailure(
      message: 'Email/Password Sign-In non implémenté dans cette version',
    ));
  }

  @override
  Future<Either<Failure, AppUser>> signUpWithEmailPassword(String email, String password) async {
    return Left(AuthFailure(
      message: 'Email/Password Sign-Up non implémenté dans cette version',
    ));
  }

  @override
  Future<Either<Failure, AppUser>> linkWithGoogle() async {
    return Left(AuthFailure(
      message: 'Link with Google non implémenté dans cette version',
    ));
  }

  @override
  Future<Either<Failure, AppUser>> linkWithApple() async {
    return Left(AuthFailure(
      message: 'Link with Apple non implémenté dans cette version',
    ));
  }

  @override
  Future<Either<Failure, AppUser>> linkWithEmailPassword(String email, String password) async {
    return Left(AuthFailure(
      message: 'Link with Email/Password non implémenté dans cette version',
    ));
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
        message: 'Erreur lors de la récupération de l\'utilisateur: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      await localDataSource.clearCache();
      UserSettingsStore.clear();
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
      // Save locally
      await localDataSource.cacheUserSettings(settings);
      UserSettingsStore.saveSettings(settings);
      
      // Update in Firestore if user is logged in
      final firebaseUser = await remoteDataSource.getCurrentUser();
      if (firebaseUser != null) {
        final userData = await remoteDataSource.getUserData(firebaseUser.uid);
        if (userData != null) {
          final updatedUser = userData.copyWith(settings: settings);
          await remoteDataSource.saveUserData(updatedUser);
        }
      }
      
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
      // Try to get from memory first
      var settings = UserSettingsStore.getSettings();
      if (settings != null) {
        return Right(settings);
      }
      
      // Try local cache
      settings = await localDataSource.getLastUserSettings();
      if (settings != null) {
        UserSettingsStore.saveSettings(settings);
        return Right(settings);
      }
      
      // Try from Firestore
      final firebaseUser = await remoteDataSource.getCurrentUser();
      if (firebaseUser != null) {
        final userData = await remoteDataSource.getUserData(firebaseUser.uid);
        if (userData != null) {
          UserSettingsStore.saveSettings(userData.settings);
          await localDataSource.cacheUserSettings(userData.settings);
          return Right(userData.settings);
        }
      }
      
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(
        message: 'Erreur lors de la récupération: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserData(AppUser user) async {
    try {
      await remoteDataSource.saveUserData(user);
      
      // Update local cache
      await localDataSource.cacheUserSettings(user.settings);
      UserSettingsStore.saveSettings(user.settings);
      
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Erreur lors de la mise à jour: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    return Left(AuthFailure(
      message: 'Password reset non implémenté dans cette version',
    ));
  }

  @override
  Future<Either<Failure, List<String>>> getAuthProviders(String email) async {
    return const Right([]);
  }

  @override
  Stream<User?> get authStateChanges {
    try {
      return FirebaseAuth.instance.authStateChanges();
    } catch (e) {
      return Stream.error(e);
    }
  }
}
