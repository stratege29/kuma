import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kuma/core/error/failure.dart';
import 'package:kuma/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:kuma/features/auth/data/datasources/auth_remote_data_source_v2.dart';
import 'package:kuma/features/auth/domain/repositories/auth_repository.dart';
import 'package:kuma/shared/domain/entities/user.dart';
import 'package:kuma/features/onboarding/presentation/bloc/onboarding_bloc.dart';

class AuthRepositoryImplV2 implements AuthRepository {
  final AuthRemoteDataSourceV2 remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImplV2({
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
      await remoteDataSource.updateUserData(updatedUser);
      return updatedUser;
    }
    
    // Create new user if doesn't exist
    final savedSettings = UserSettingsStore.getSettings();
    
    // Try to get onboarding status from local cache as fallback
    final localSettings = await localDataSource.getLastUserSettings();
    final onboardingCompleted = savedSettings?.isOnboardingCompleted ?? 
                               localSettings?.isOnboardingCompleted ?? 
                               false;
    
    final userSettings = savedSettings ?? UserSettings(
      startingCountry: localSettings?.startingCountry ?? '',
      primaryGoal: localSettings?.primaryGoal ?? '',
      preferredReadingTime: localSettings?.preferredReadingTime ?? '',
      language: 'fr',
      isOnboardingCompleted: onboardingCompleted,
      notificationsEnabled: localSettings?.notificationsEnabled ?? false,
      soundEnabled: localSettings?.soundEnabled ?? false,
      fontSize: localSettings?.fontSize ?? 16.0,
      darkMode: localSettings?.darkMode ?? false,
    );
    
    final newUser = AppUser(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      userType: 'parent',
      settings: userSettings,
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
    try {
      final firebaseUser = await remoteDataSource.signInWithGoogle();
      final appUser = await _createOrUpdateAppUser(firebaseUser);
      return Right(appUser);
    } catch (e) {
      return Left(AuthFailure(
        message: 'Erreur lors de la connexion Google: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<Failure, AppUser>> signInWithApple() async {
    try {
      final firebaseUser = await remoteDataSource.signInWithApple();
      final appUser = await _createOrUpdateAppUser(firebaseUser);
      return Right(appUser);
    } catch (e) {
      return Left(AuthFailure(
        message: 'Erreur lors de la connexion Apple: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<Failure, AppUser>> signInWithEmailPassword(String email, String password) async {
    try {
      final firebaseUser = await remoteDataSource.signInWithEmailPassword(email, password);
      final appUser = await _createOrUpdateAppUser(firebaseUser);
      return Right(appUser);
    } catch (e) {
      return Left(AuthFailure(
        message: e.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, AppUser>> signUpWithEmailPassword(String email, String password) async {
    try {
      final firebaseUser = await remoteDataSource.signUpWithEmailPassword(email, password);
      final appUser = await _createOrUpdateAppUser(firebaseUser, isNewUser: true);
      return Right(appUser);
    } catch (e) {
      return Left(AuthFailure(
        message: e.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, AppUser>> linkWithGoogle() async {
    try {
      final currentFirebaseUser = await remoteDataSource.getCurrentUser();
      if (currentFirebaseUser == null) {
        return const Left(AuthFailure(message: 'Aucun utilisateur connecté'));
      }

      // Get current user data before linking
      final currentUserData = await remoteDataSource.getUserData(currentFirebaseUser.uid);
      if (currentUserData == null) {
        return const Left(AuthFailure(message: 'Données utilisateur introuvables'));
      }

      // Link with Google
      final linkedUser = await remoteDataSource.linkWithGoogle();
      
      // Update user data with new email if available
      final updatedUser = currentUserData.copyWith(
        email: linkedUser.email ?? currentUserData.email,
      );
      
      await remoteDataSource.updateUserData(updatedUser);
      return Right(updatedUser);
    } catch (e) {
      return Left(AuthFailure(
        message: e.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, AppUser>> linkWithApple() async {
    try {
      final currentFirebaseUser = await remoteDataSource.getCurrentUser();
      if (currentFirebaseUser == null) {
        return const Left(AuthFailure(message: 'Aucun utilisateur connecté'));
      }

      // Get current user data before linking
      final currentUserData = await remoteDataSource.getUserData(currentFirebaseUser.uid);
      if (currentUserData == null) {
        return const Left(AuthFailure(message: 'Données utilisateur introuvables'));
      }

      // Link with Apple
      final linkedUser = await remoteDataSource.linkWithApple();
      
      // Update user data with new email if available
      final updatedUser = currentUserData.copyWith(
        email: linkedUser.email ?? currentUserData.email,
      );
      
      await remoteDataSource.updateUserData(updatedUser);
      return Right(updatedUser);
    } catch (e) {
      return Left(AuthFailure(
        message: e.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, AppUser>> linkWithEmailPassword(String email, String password) async {
    try {
      final currentFirebaseUser = await remoteDataSource.getCurrentUser();
      if (currentFirebaseUser == null) {
        return const Left(AuthFailure(message: 'Aucun utilisateur connecté'));
      }

      // Get current user data before linking
      final currentUserData = await remoteDataSource.getUserData(currentFirebaseUser.uid);
      if (currentUserData == null) {
        return const Left(AuthFailure(message: 'Données utilisateur introuvables'));
      }

      // Link with email/password
      final linkedUser = await remoteDataSource.linkWithEmailPassword(email, password);
      
      // Update user data with new email
      final updatedUser = currentUserData.copyWith(email: email);
      
      await remoteDataSource.updateUserData(updatedUser);
      return Right(updatedUser);
    } catch (e) {
      return Left(AuthFailure(
        message: e.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, AppUser?>> getCurrentUser() async {
    try {
      print('AuthRepository: Getting current Firebase user...');
      final firebaseUser = await remoteDataSource.getCurrentUser();
      print('AuthRepository: Firebase user: ${firebaseUser?.uid}');
      
      if (firebaseUser == null) {
        print('AuthRepository: No Firebase user found');
        return const Right(null);
      }

      print('AuthRepository: Getting user data for: ${firebaseUser.uid}');
      final appUser = await remoteDataSource.getUserData(firebaseUser.uid);
      print('AuthRepository: App user found: ${appUser?.id}');
      
      // If Firebase user exists but no app user document, create it
      if (appUser == null) {
        print('AuthRepository: Creating missing user document for existing Firebase user');
        final newUser = await _createOrUpdateAppUser(firebaseUser, isNewUser: true);
        print('AuthRepository: Created user document: ${newUser.id}');
        return Right(newUser);
      }
      
      return Right(appUser);
    } catch (e) {
      print('AuthRepository: Error in getCurrentUser: $e');
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
      print('AuthRepository: Saving user settings...');
      print('AuthRepository: Settings to save - Country: ${settings.startingCountry}, Completed: ${settings.isOnboardingCompleted}');
      
      // Save locally
      await localDataSource.cacheUserSettings(settings);
      UserSettingsStore.saveSettings(settings);
      print('AuthRepository: Settings saved locally and in memory store');
      
      // Update in Firestore if user is logged in
      final firebaseUser = await remoteDataSource.getCurrentUser();
      if (firebaseUser != null) {
        print('AuthRepository: Firebase user found: ${firebaseUser.uid}');
        final userData = await remoteDataSource.getUserData(firebaseUser.uid);
        if (userData != null) {
          print('AuthRepository: Current user data found, updating settings...');
          print('AuthRepository: Old settings - Country: ${userData.settings.startingCountry}, Completed: ${userData.settings.isOnboardingCompleted}');
          
          final updatedUser = userData.copyWith(settings: settings);
          print('AuthRepository: New settings - Country: ${updatedUser.settings.startingCountry}, Completed: ${updatedUser.settings.isOnboardingCompleted}');
          
          await remoteDataSource.updateUserData(updatedUser);
          print('AuthRepository: User data updated in Firestore successfully');
        } else {
          print('AuthRepository: WARNING - No user data found for Firebase user');
        }
      } else {
        print('AuthRepository: WARNING - No Firebase user found');
      }
      
      return const Right(null);
    } catch (e) {
      print('AuthRepository: Error saving user settings: $e');
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
      await remoteDataSource.updateUserData(user);
      
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
    try {
      await remoteDataSource.sendPasswordResetEmail(email);
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(
        message: e.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getAuthProviders(String email) async {
    try {
      final providers = await remoteDataSource.getAuthProviders(email);
      return Right(providers);
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Erreur lors de la vérification: ${e.toString()}',
      ));
    }
  }

  @override
  Stream<User?> get authStateChanges => remoteDataSource.authStateChanges;
}