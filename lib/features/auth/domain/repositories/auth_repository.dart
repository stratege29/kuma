import 'package:dartz/dartz.dart';
import 'package:kuma/core/error/failure.dart';
import 'package:kuma/shared/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, AppUser>> signInAnonymously();
  Future<Either<Failure, AppUser?>> getCurrentUser();
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, void>> saveUserSettings(UserSettings settings);
  Future<Either<Failure, UserSettings?>> getUserSettings();
}