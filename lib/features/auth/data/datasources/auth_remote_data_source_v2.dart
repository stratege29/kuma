import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:kuma/core/constants/app_constants.dart';
import 'package:kuma/shared/domain/entities/user.dart';

abstract class AuthRemoteDataSourceV2 {
  // Authentication methods
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
        
        try {
          // Print raw data for debugging
          print('AuthRemoteDataSource: Raw document keys: ${data.keys.toList()}');
          
          // Convert Firestore Timestamps to DateTime objects if needed
          print('AuthRemoteDataSource: Converting timestamp fields...');
          _convertTimestampToDateTime(data, 'createdAt');
          _convertTimestampToDateTime(data, 'lastLoginAt');
          _convertTimestampToDateTime(data, 'premiumExpiresAt');
          
          // Handle nested DateTime fields in progress
          if (data['progress'] != null && data['progress'] is Map<String, dynamic>) {
            print('AuthRemoteDataSource: Converting progress timestamps...');
            _convertTimestampToDateTime(data['progress'], 'lastReadingDate');
          }
          
          // Handle DateTime fields in child profiles
          if (data['childProfiles'] != null && data['childProfiles'] is List) {
            print('AuthRemoteDataSource: Converting child profile timestamps...');
            for (var profile in data['childProfiles']) {
              if (profile is Map<String, dynamic>) {
                _convertTimestampToDateTime(profile, 'createdAt');
                // Handle nested progress in child profiles
                if (profile['progress'] != null && profile['progress'] is Map<String, dynamic>) {
                  _convertTimestampToDateTime(profile['progress'], 'lastReadingDate');
                }
              }
            }
          }
          
          print('AuthRemoteDataSource: Validating required fields...');
          _validateRequiredFields(data);
          
          print('AuthRemoteDataSource: Normalizing data types...');
          _normalizeDataTypes(data);
          
          print('AuthRemoteDataSource: Attempting to parse AppUser from JSON...');
          final user = AppUser.fromJson(data);
          print('AuthRemoteDataSource: Successfully parsed user: ${user.id}');
          return user;
        } catch (parseError) {
          print('AuthRemoteDataSource: Error during JSON parsing: $parseError');
          print('AuthRemoteDataSource: Parse error stack trace: ${StackTrace.current}');
          throw parseError; // Re-throw to see the exact error
        }
      }
      print('AuthRemoteDataSource: No document data found');
      return null;
    } catch (e) {
      print('AuthRemoteDataSource: Error getting user data: $e');
      print('AuthRemoteDataSource: Stack trace: ${StackTrace.current}');
      return null;
    }
  }

  /// Normalize data types to ensure compatibility with JSON parsing
  void _normalizeDataTypes(Map<String, dynamic> data) {
    // Ensure isPremium is a boolean
    if (data.containsKey('isPremium')) {
      final value = data['isPremium'];
      if (value is String) {
        data['isPremium'] = value.toLowerCase() == 'true';
      } else if (value is! bool) {
        data['isPremium'] = false; // Default to false if not boolean
      }
    } else {
      data['isPremium'] = false; // Set default if missing
    }
    
    // Normalize nested boolean fields in settings
    if (data['settings'] is Map<String, dynamic>) {
      final settings = data['settings'] as Map<String, dynamic>;
      _normalizeBooleanField(settings, 'isOnboardingCompleted');
      _normalizeBooleanField(settings, 'notificationsEnabled');
      _normalizeBooleanField(settings, 'soundEnabled');
      _normalizeBooleanField(settings, 'darkMode');
    }
    
    // Normalize nested boolean fields in preferences
    if (data['preferences'] is Map<String, dynamic>) {
      final preferences = data['preferences'] as Map<String, dynamic>;
      _normalizeBooleanField(preferences, 'autoPlay');
      _normalizeBooleanField(preferences, 'showSubtitles');
      _normalizeBooleanField(preferences, 'parentalControlEnabled');
    }
    
    print('AuthRemoteDataSource: Data types normalized successfully');
  }
  
  void _normalizeBooleanField(Map<String, dynamic> data, String key) {
    if (data.containsKey(key)) {
      final value = data[key];
      if (value is String) {
        data[key] = value.toLowerCase() == 'true';
      } else if (value is! bool) {
        data[key] = false; // Default to false if not boolean
      }
    }
  }

  /// Validate that all required fields are present and have correct structure
  void _validateRequiredFields(Map<String, dynamic> data) {
    final requiredFields = ['id', 'email', 'userType', 'settings', 'childProfiles', 'progress', 'preferences'];
    
    for (final field in requiredFields) {
      if (!data.containsKey(field)) {
        throw Exception('Missing required field: $field');
      }
      if (data[field] == null) {
        throw Exception('Required field is null: $field');
      }
    }
    
    // Validate nested objects
    if (data['settings'] is! Map<String, dynamic>) {
      throw Exception('settings field must be a Map, got: ${data['settings'].runtimeType}');
    }
    if (data['progress'] is! Map<String, dynamic>) {
      throw Exception('progress field must be a Map, got: ${data['progress'].runtimeType}');
    }
    if (data['preferences'] is! Map<String, dynamic>) {
      throw Exception('preferences field must be a Map, got: ${data['preferences'].runtimeType}');
    }
    if (data['childProfiles'] is! List) {
      throw Exception('childProfiles field must be a List, got: ${data['childProfiles'].runtimeType}');
    }
    
    print('AuthRemoteDataSource: All required fields validated successfully');
  }

  /// Helper method to convert Firestore Timestamps to DateTime objects
  void _convertTimestampToDateTime(Map<String, dynamic> data, String key) {
    if (data[key] != null) {
      try {
        final value = data[key];
        print('AuthRemoteDataSource: Converting $key (type: ${value.runtimeType}) = $value');
        
        if (value is String) {
          data[key] = DateTime.parse(value);
          print('AuthRemoteDataSource: Converted $key from String to DateTime');
        } else if (value is Timestamp) {
          data[key] = value.toDate();
          print('AuthRemoteDataSource: Converted $key from Timestamp to DateTime');
        } else if (value is DateTime) {
          print('AuthRemoteDataSource: $key is already DateTime, no conversion needed');
        } else {
          print('AuthRemoteDataSource: WARNING - $key has unexpected type: ${value.runtimeType}');
        }
      } catch (e) {
        print('AuthRemoteDataSource: Error converting $key: $e');
        // Don't modify the value if conversion fails
      }
    } else {
      print('AuthRemoteDataSource: $key is null, skipping conversion');
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