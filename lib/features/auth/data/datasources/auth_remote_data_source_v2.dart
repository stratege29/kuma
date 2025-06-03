import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:kuma/core/constants/app_constants.dart';
import 'package:kuma/shared/domain/entities/user.dart';

abstract class AuthRemoteDataSourceV2 {
  // Authentication methods
  Future<User> signInAnonymously();
  Future<User> signInWithGoogle();
  Future<User> signInWithApple();
  Future<User> signInWithEmailPassword(String email, String password);
  Future<User> signUpWithEmailPassword(String email, String password);
  
  // Account linking
  Future<User> linkWithGoogle();
  Future<User> linkWithApple();
  Future<User> linkWithEmailPassword(String email, String password);
  
  // User management
  Future<User?> getCurrentUser();
  Future<void> signOut();
  Future<void> saveUserData(AppUser user);
  Future<AppUser?> getUserData(String uid);
  Future<void> updateUserData(AppUser user);
  
  // Password reset
  Future<void> sendPasswordResetEmail(String email);
  
  // Auth providers
  Future<List<String>> getAuthProviders(String email);
  Stream<User?> get authStateChanges;
}

class AuthRemoteDataSourceV2Impl implements AuthRemoteDataSourceV2 {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSourceV2Impl({
    required this.firebaseAuth,
    required this.firestore,
    GoogleSignIn? googleSignIn,
  }) : googleSignIn = googleSignIn ?? GoogleSignIn();

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
  Future<User> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('Connexion Google annulée');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final result = await firebaseAuth.signInWithCredential(credential);
      final user = result.user;
      
      if (user == null) {
        throw Exception('Échec de la connexion Google');
      }
      
      return user;
    } catch (e) {
      throw Exception('Erreur lors de la connexion Google: $e');
    }
  }

  @override
  Future<User> signInWithApple() async {
    try {
      // Request credential for the currently signed in Apple account
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create an OAuthCredential from the credential returned by Apple
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in the user with Firebase
      final result = await firebaseAuth.signInWithCredential(oauthCredential);
      final user = result.user;
      
      if (user == null) {
        throw Exception('Échec de la connexion Apple');
      }

      // Update user display name if available
      if (appleCredential.givenName != null || appleCredential.familyName != null) {
        final displayName = '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'.trim();
        if (displayName.isNotEmpty) {
          await user.updateDisplayName(displayName);
        }
      }
      
      return user;
    } catch (e) {
      throw Exception('Erreur lors de la connexion Apple: $e');
    }
  }

  @override
  Future<User> signInWithEmailPassword(String email, String password) async {
    try {
      final result = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = result.user;
      
      if (user == null) {
        throw Exception('Échec de la connexion email/mot de passe');
      }
      
      return user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('Aucun utilisateur trouvé avec cet email');
        case 'wrong-password':
          throw Exception('Mot de passe incorrect');
        case 'invalid-email':
          throw Exception('Email invalide');
        case 'user-disabled':
          throw Exception('Ce compte a été désactivé');
        default:
          throw Exception('Erreur de connexion: ${e.message}');
      }
    }
  }

  @override
  Future<User> signUpWithEmailPassword(String email, String password) async {
    try {
      final result = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = result.user;
      
      if (user == null) {
        throw Exception('Échec de la création du compte');
      }
      
      return user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          throw Exception('Le mot de passe est trop faible');
        case 'email-already-in-use':
          throw Exception('Un compte existe déjà avec cet email');
        case 'invalid-email':
          throw Exception('Email invalide');
        default:
          throw Exception('Erreur de création de compte: ${e.message}');
      }
    }
  }

  @override
  Future<User> linkWithGoogle() async {
    try {
      final currentUser = firebaseAuth.currentUser;
      if (currentUser == null) {
        throw Exception('Aucun utilisateur connecté');
      }

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('Connexion Google annulée');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Link the credential to the current user
      final result = await currentUser.linkWithCredential(credential);
      final user = result.user;
      
      if (user == null) {
        throw Exception('Échec de la liaison du compte Google');
      }
      
      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'credential-already-in-use') {
        throw Exception('Ce compte Google est déjà lié à un autre utilisateur');
      }
      throw Exception('Erreur lors de la liaison du compte Google: ${e.message}');
    }
  }

  @override
  Future<User> linkWithApple() async {
    try {
      final currentUser = firebaseAuth.currentUser;
      if (currentUser == null) {
        throw Exception('Aucun utilisateur connecté');
      }

      // Request credential for the currently signed in Apple account
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create an OAuthCredential from the credential returned by Apple
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Link the credential to the current user
      final result = await currentUser.linkWithCredential(oauthCredential);
      final user = result.user;
      
      if (user == null) {
        throw Exception('Échec de la liaison du compte Apple');
      }
      
      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'credential-already-in-use') {
        throw Exception('Ce compte Apple est déjà lié à un autre utilisateur');
      }
      throw Exception('Erreur lors de la liaison du compte Apple: ${e.message}');
    }
  }

  @override
  Future<User> linkWithEmailPassword(String email, String password) async {
    try {
      final currentUser = firebaseAuth.currentUser;
      if (currentUser == null) {
        throw Exception('Aucun utilisateur connecté');
      }

      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      final result = await currentUser.linkWithCredential(credential);
      final user = result.user;
      
      if (user == null) {
        throw Exception('Échec de la liaison du compte email/mot de passe');
      }
      
      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'credential-already-in-use') {
        throw Exception('Cet email est déjà lié à un autre utilisateur');
      }
      throw Exception('Erreur lors de la liaison du compte: ${e.message}');
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    return firebaseAuth.currentUser;
  }

  @override
  Future<void> signOut() async {
    await Future.wait([
      firebaseAuth.signOut(),
      googleSignIn.signOut(),
    ]);
  }

  @override
  Future<void> saveUserData(AppUser user) async {
    try {
      print('AuthRemoteDataSource: Saving user data for uid: ${user.id}');
      final userRef = firestore
          .collection(AppConstants.COLLECTION_USERS)
          .doc(user.id);
      
      // Manually construct the JSON to ensure nested objects are properly serialized
      final userData = {
        'id': user.id,
        'email': user.email,
        'userType': user.userType,
        'settings': user.settings.toJson(),
        'childProfiles': user.childProfiles.map((e) => e.toJson()).toList(),
        'progress': user.progress.toJson(),
        'preferences': user.preferences.toJson(),
        'isPremium': user.isPremium,
        'createdAt': user.createdAt?.toIso8601String(),
        'lastLoginAt': user.lastLoginAt?.toIso8601String(),
        'premiumExpiresAt': user.premiumExpiresAt?.toIso8601String(),
      };
      
      print('AuthRemoteDataSource: User data to save: $userData');
      
      await userRef.set(userData, SetOptions(merge: true));
      print('AuthRemoteDataSource: User data saved successfully');
    } catch (e) {
      print('AuthRemoteDataSource: Error saving user data: $e');
      print('AuthRemoteDataSource: Stack trace: ${StackTrace.current}');
      throw e;
    }
  }

  @override
  Future<AppUser?> getUserData(String uid) async {
    try {
      print('AuthRemoteDataSource: Getting user document for uid: $uid');
      final userDoc = await firestore
          .collection(AppConstants.COLLECTION_USERS)
          .doc(uid)
          .get();
      
      print('AuthRemoteDataSource: Document exists: ${userDoc.exists}');
      if (userDoc.exists && userDoc.data() != null) {
        print('AuthRemoteDataSource: Document data found, parsing...');
        final data = userDoc.data()!;
        
        // Convert date strings back to DateTime objects
        if (data['createdAt'] != null && data['createdAt'] is String) {
          data['createdAt'] = DateTime.parse(data['createdAt']);
        }
        if (data['lastLoginAt'] != null && data['lastLoginAt'] is String) {
          data['lastLoginAt'] = DateTime.parse(data['lastLoginAt']);
        }
        if (data['premiumExpiresAt'] != null && data['premiumExpiresAt'] is String) {
          data['premiumExpiresAt'] = DateTime.parse(data['premiumExpiresAt']);
        }
        
        return AppUser.fromJson(data);
      }
      print('AuthRemoteDataSource: No document data found');
      return null;
    } catch (e) {
      print('AuthRemoteDataSource: Error getting user data: $e');
      print('AuthRemoteDataSource: Stack trace: ${StackTrace.current}');
      return null;
    }
  }

  @override
  Future<void> updateUserData(AppUser user) async {
    await saveUserData(user);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('Aucun utilisateur trouvé avec cet email');
        case 'invalid-email':
          throw Exception('Email invalide');
        default:
          throw Exception('Erreur lors de l\'envoi de l\'email: ${e.message}');
      }
    }
  }

  @override
  Future<List<String>> getAuthProviders(String email) async {
    try {
      final methods = await firebaseAuth.fetchSignInMethodsForEmail(email);
      return methods;
    } catch (e) {
      return [];
    }
  }

  @override
  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();
}