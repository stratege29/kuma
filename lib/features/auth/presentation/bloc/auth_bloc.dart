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

  AuthBloc({required this.authRepository}) : super(const AuthState.initial()) {
    on<_CheckAuthStatus>(_onCheckAuthStatus);
    on<_SignInAnonymously>(_onSignInAnonymously);
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
      add(const AuthEvent.checkAuthStatus());
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
    emit(const AuthState.loading());
    
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
            emit(AuthState.authenticated(user: user));
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

  Future<void> _onSignInAnonymously(
    _SignInAnonymously event,
    Emitter<AuthState> emit,
  ) async {
    print('AuthBloc: Starting anonymous sign-in...');
    emit(const AuthState.loading());
    
    try {
      final result = await authRepository.signInAnonymously();
      print('AuthBloc: Anonymous sign-in result: $result');
      
      result.fold(
        (failure) {
          print('AuthBloc: Anonymous sign-in failed: $failure');
          emit(AuthState.error(message: failure.toString()));
        },
        (user) {
          print('AuthBloc: Anonymous sign-in successful: ${user.id}');
          emit(AuthState.authenticated(user: user));
        },
      );
    } catch (e) {
      print('AuthBloc: Exception in signInAnonymously: $e');
      emit(AuthState.error(message: e.toString()));
    }
  }

  Future<void> _onSignInWithGoogle(
    _SignInWithGoogle event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    
    final result = await authRepository.signInWithGoogle();
    
    result.fold(
      (failure) => emit(AuthState.error(message: failure.toString())),
      (user) => emit(AuthState.authenticated(user: user)),
    );
  }

  Future<void> _onSignInWithApple(
    _SignInWithApple event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    
    final result = await authRepository.signInWithApple();
    
    result.fold(
      (failure) => emit(AuthState.error(message: failure.toString())),
      (user) => emit(AuthState.authenticated(user: user)),
    );
  }

  Future<void> _onSignInWithEmailPassword(
    _SignInWithEmailPassword event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    
    final result = await authRepository.signInWithEmailPassword(
      event.email,
      event.password,
    );
    
    result.fold(
      (failure) => emit(AuthState.error(message: failure.toString())),
      (user) => emit(AuthState.authenticated(user: user)),
    );
  }

  Future<void> _onSignUpWithEmailPassword(
    _SignUpWithEmailPassword event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    
    final result = await authRepository.signUpWithEmailPassword(
      event.email,
      event.password,
    );
    
    result.fold(
      (failure) => emit(AuthState.error(message: failure.toString())),
      (user) => emit(AuthState.authenticated(user: user)),
    );
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