import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kuma/core/constants/app_constants.dart';
import 'package:kuma/shared/domain/entities/user.dart';

abstract class AuthRemoteDataSource {
  Future<User> signInAnonymously();
  Future<User?> getCurrentUser();
  Future<void> signOut();
  Future<void> saveUserData(AppUser user);
  Future<AppUser?> getUserData(String uid);
  Future<void> updateUserData(AppUser user);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });

  @override
  Future<User> signInAnonymously() async {
    final result = await firebaseAuth.signInAnonymously();
    final user = result.user;
    if (user == null) {
      throw Exception('Échec de la connexion anonyme');
    }
    return user;
  }

  @override
  Future<User?> getCurrentUser() async {
    return firebaseAuth.currentUser;
  }

  @override
  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }

  @override
  Future<void> saveUserData(AppUser user) async {
    final userRef = firestore
        .collection(AppConstants.COLLECTION_USERS)
        .doc(user.id);
    
    await userRef.set(user.toJson(), SetOptions(merge: true));
  }

  @override
  Future<AppUser?> getUserData(String uid) async {
    try {
      final userDoc = await firestore
          .collection(AppConstants.COLLECTION_USERS)
          .doc(uid)
          .get();
      
      if (userDoc.exists && userDoc.data() != null) {
        return AppUser.fromJson(userDoc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updateUserData(AppUser user) async {
    await saveUserData(user);
  }
}