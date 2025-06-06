import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kuma/features/auth/domain/repositories/auth_repository.dart';
import 'package:kuma/shared/domain/entities/user.dart';

part 'auth_event.dart';
part 'auth_state.dart';
part 'auth_bloc.freezed.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  StreamSubscription<User?>? _authStateSubscription;
  bool _isSigningUp = false;

  AuthBloc({required this.authRepository}) : super(const AuthState.initial()) {
    on<_CheckAuthStatus>(_onCheckAuthStatus);
    on<_RefreshUserData>(_onRefreshUserData);
    on<_SignInWithGoogle>(_onSignInWithGoogle);
    on<_SignInWithApple>(_onSignInWithApple);
    on<_SignInWithEmailPassword>(_onSignInWithEmailPassword);
    on<_SignUpWithEmailPassword>(_onSignUpWithEmailPassword);
    on<_LinkWithGoogle>(_onLinkWithGoogle);
    on<_LinkWithApple>(_onLinkWithApple);
    on<_LinkWithEmailPassword>(_onLinkWithEmailPassword);
    on<_SignOut>(_onSignOut);
    on<_UpdateUserData>(_onUpdateUserData);
    on<_SendPasswordResetEmail>(_onSendPasswordResetEmail);

    // Listen to auth state changes
    _authStateSubscription = authRepository.authStateChanges.listen((firebaseUser) {
      // Don't interfere if we're in the middle of a signup process
      if (_isSigningUp) return;
      
      // Only check auth status if we're not already in an authenticated state
      // This prevents infinite loops when the user is authenticated
      if (state is! Authenticated && state is! Loading) {
        // Add a small delay to allow sign-up processes to complete
        Future.delayed(const Duration(milliseconds: 500), () {
          // Don't interfere if we're in the middle of a signup process
          if (_isSigningUp) return;
          
          // Double check we're still not authenticated and not loading
          if (state is! Authenticated && state is! Loading) {
            add(const AuthEvent.checkAuthStatus());
          }
        });
      }
    });
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }

  Future<void> _onCheckAuthStatus(
    _CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    print('AuthBloc: Checking auth status...');
    
    // Don't proceed if we're in the middle of a signup process
    if (_isSigningUp) {
      print('AuthBloc: Skipping auth check - signup in progress');
      return;
    }
    
    // Don't emit loading state if we're already authenticated to prevent UI flicker
    if (state is! Authenticated) {
      emit(const AuthState.loading());
    }
    
    try {
      final result = await authRepository.getCurrentUser();
      print('AuthBloc: getCurrentUser result: $result');
      
      result.fold(
        (failure) {
          print('AuthBloc: Auth check failed: $failure');
          emit(AuthState.unauthenticated(message: failure.toString()));
        },
        (user) {
          if (user != null) {
            print('AuthBloc: User found: ${user.id}');
            // Only emit if we're not already authenticated with the same user
            if (state is! Authenticated || (state as Authenticated).user.id != user.id) {
              emit(AuthState.authenticated(user: user));
            } else {
              print('AuthBloc: Already authenticated with same user, skipping emit');
            }
          } else {
            print('AuthBloc: No user found');
            emit(const AuthState.unauthenticated());
          }
        },
      );
    } catch (e) {
      print('AuthBloc: Exception in checkAuthStatus: $e');
      emit(AuthState.error(message: e.toString()));
    }
  }

  Future<void> _onRefreshUserData(
    _RefreshUserData event,
    Emitter<AuthState> emit,
  ) async {
    print('AuthBloc: Refreshing user data...');
    
    // Only refresh if we're currently authenticated
    if (state is! Authenticated) {
      print('AuthBloc: Cannot refresh - not authenticated');
      return;
    }

    try {
      final result = await authRepository.getCurrentUser();
      print('AuthBloc: Refresh result: $result');
      
      result.fold(
        (failure) {
          print('AuthBloc: Refresh failed: $failure');
          // Don't change state on refresh failure, keep current auth state
        },
        (user) {
          if (user != null) {
            print('AuthBloc: User data refreshed successfully: ${user.id}');
            print('AuthBloc: Updated onboarding status: ${user.settings.isOnboardingCompleted}');
            print('AuthBloc: Updated starting country: ${user.settings.startingCountry}');
            emit(AuthState.authenticated(user: user));
          } else {
            print('AuthBloc: Refresh returned null user');
            // User no longer exists, sign out
            emit(const AuthState.unauthenticated());
          }
        },
      );
    } catch (e) {
      print('AuthBloc: Exception during refresh: $e');
      // Don't change state on error, keep current auth state
    }
  }

  Future<void> _onSignInWithGoogle(
    _SignInWithGoogle event,
    Emitter<AuthState> emit,
  ) async {
    _isSigningUp = true;
    emit(const AuthState.loading());
    
    final result = await authRepository.signInWithGoogle();
    
    result.fold(
      (failure) {
        _isSigningUp = false;
        emit(AuthState.error(message: failure.toString()));
      },
      (user) {
        emit(AuthState.authenticated(user: user));
        // Delay clearing the flag to prevent immediate auth state listener interference
        Future.delayed(const Duration(milliseconds: 1000), () {
          _isSigningUp = false;
        });
      },
    );
  }

  Future<void> _onSignInWithApple(
    _SignInWithApple event,
    Emitter<AuthState> emit,
  ) async {
    _isSigningUp = true;
    emit(const AuthState.loading());
    
    final result = await authRepository.signInWithApple();
    
    result.fold(
      (failure) {
        _isSigningUp = false;
        emit(AuthState.error(message: failure.toString()));
      },
      (user) {
        emit(AuthState.authenticated(user: user));
        // Delay clearing the flag to prevent immediate auth state listener interference
        Future.delayed(const Duration(milliseconds: 1000), () {
          _isSigningUp = false;
        });
      },
    );
  }

  Future<void> _onSignInWithEmailPassword(
    _SignInWithEmailPassword event,
    Emitter<AuthState> emit,
  ) async {
    _isSigningUp = true;
    emit(const AuthState.loading());
    
    final result = await authRepository.signInWithEmailPassword(
      event.email,
      event.password,
    );
    
    result.fold(
      (failure) {
        _isSigningUp = false;
        emit(AuthState.error(message: failure.toString()));
      },
      (user) {
        emit(AuthState.authenticated(user: user));
        // Delay clearing the flag to prevent immediate auth state listener interference
        Future.delayed(const Duration(milliseconds: 1000), () {
          _isSigningUp = false;
        });
      },
    );
  }

  Future<void> _onSignUpWithEmailPassword(
    _SignUpWithEmailPassword event,
    Emitter<AuthState> emit,
  ) async {
    print('AuthBloc: Starting sign-up with email/password...');
    _isSigningUp = true; // Set flag to prevent auth state listener interference
    emit(const AuthState.loading());
    
    try {
      final result = await authRepository.signUpWithEmailPassword(
        event.email,
        event.password,
      );
      
      print('AuthBloc: Sign-up result received: $result');
      
      result.fold(
        (failure) {
          print('AuthBloc: Sign-up failed: $failure');
          _isSigningUp = false; // Clear flag on failure
          emit(AuthState.error(message: failure.toString()));
        },
        (user) {
          print('AuthBloc: Sign-up successful, user: ${user.id}');
          emit(AuthState.authenticated(user: user));
          
          // Delay clearing the flag to prevent immediate auth state listener interference
          Future.delayed(const Duration(milliseconds: 1000), () {
            _isSigningUp = false; // Clear flag after a delay
          });
        },
      );
    } catch (e) {
      print('AuthBloc: Exception in sign-up: $e');
      _isSigningUp = false; // Clear flag on exception
      emit(AuthState.error(message: e.toString()));
    }
  }

  Future<void> _onLinkWithGoogle(
    _LinkWithGoogle event,
    Emitter<AuthState> emit,
  ) async {
    if (state is! Authenticated) return;
    
    emit(const AuthState.loading());
    
    final result = await authRepository.linkWithGoogle();
    
    result.fold(
      (failure) => emit(AuthState.error(message: failure.toString())),
      (user) => emit(AuthState.authenticated(user: user)),
    );
  }

  Future<void> _onLinkWithApple(
    _LinkWithApple event,
    Emitter<AuthState> emit,
  ) async {
    if (state is! Authenticated) return;
    
    emit(const AuthState.loading());
    
    final result = await authRepository.linkWithApple();
    
    result.fold(
      (failure) => emit(AuthState.error(message: failure.toString())),
      (user) => emit(AuthState.authenticated(user: user)),
    );
  }

  Future<void> _onLinkWithEmailPassword(
    _LinkWithEmailPassword event,
    Emitter<AuthState> emit,
  ) async {
    if (state is! Authenticated) return;
    
    emit(const AuthState.loading());
    
    final result = await authRepository.linkWithEmailPassword(
      event.email,
      event.password,
    );
    
    result.fold(
      (failure) => emit(AuthState.error(message: failure.toString())),
      (user) => emit(AuthState.authenticated(user: user)),
    );
  }

  Future<void> _onSignOut(
    _SignOut event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    
    final result = await authRepository.signOut();
    
    result.fold(
      (failure) => emit(AuthState.error(message: failure.toString())),
      (_) => emit(const AuthState.unauthenticated()),
    );
  }

  Future<void> _onUpdateUserData(
    _UpdateUserData event,
    Emitter<AuthState> emit,
  ) async {
    if (state is! Authenticated) return;
    
    emit(const AuthState.loading());
    
    final result = await authRepository.updateUserData(event.user);
    
    result.fold(
      (failure) => emit(AuthState.error(message: failure.toString())),
      (_) => emit(AuthState.authenticated(user: event.user)),
    );
  }

  Future<void> _onSendPasswordResetEmail(
    _SendPasswordResetEmail event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    
    final result = await authRepository.sendPasswordResetEmail(event.email);
    
    result.fold(
      (failure) => emit(AuthState.error(message: failure.toString())),
      (_) => emit(const AuthState.passwordResetEmailSent()),
    );
  }
}