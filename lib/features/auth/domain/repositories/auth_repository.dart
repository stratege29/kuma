import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kuma/core/error/failure.dart';
import 'package:kuma/shared/domain/entities/user.dart';

abstract class AuthRepository {
  // Authentication methods
  Future<Either<Failure, AppUser>> signInWithGoogle();
  Future<Either<Failure, AppUser>> signInWithApple();
  Future<Either<Failure, AppUser>> signInWithEmailPassword(String email, String password);
  Future<Either<Failure, AppUser>> signUpWithEmailPassword(String email, String password);
  
  // Account linking
  Future<Either<Failure, AppUser>> linkWithGoogle();
  Future<Either<Failure, AppUser>> linkWithApple();
  Future<Either<Failure, AppUser>> linkWithEmailPassword(String email, String password);
  
  // User management
  Future<Either<Failure, AppUser?>> getCurrentUser();
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, void>> saveUserSettings(UserSettings settings);
  Future<Either<Failure, UserSettings?>> getUserSettings();
  Future<Either<Failure, void>> updateUserData(AppUser user);
  
  // Password reset
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);
  
  // Check auth provider
  Future<Either<Failure, List<String>>> getAuthProviders(String email);
  Stream<User?> get authStateChanges;
}