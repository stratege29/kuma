part of 'auth_bloc.dart';

@freezed
class AuthEvent with _$AuthEvent {
  const factory AuthEvent.checkAuthStatus() = _CheckAuthStatus;
  const factory AuthEvent.signInAnonymously() = _SignInAnonymously;
  const factory AuthEvent.signInWithGoogle() = _SignInWithGoogle;
  const factory AuthEvent.signInWithApple() = _SignInWithApple;
  const factory AuthEvent.signInWithEmailPassword({
    required String email,
    required String password,
  }) = _SignInWithEmailPassword;
  const factory AuthEvent.signUpWithEmailPassword({
    required String email,
    required String password,
  }) = _SignUpWithEmailPassword;
  const factory AuthEvent.linkWithGoogle() = _LinkWithGoogle;
  const factory AuthEvent.linkWithApple() = _LinkWithApple;
  const factory AuthEvent.linkWithEmailPassword({
    required String email,
    required String password,
  }) = _LinkWithEmailPassword;
  const factory AuthEvent.signOut() = _SignOut;
  const factory AuthEvent.updateUserData({
    required AppUser user,
  }) = _UpdateUserData;
  const factory AuthEvent.sendPasswordResetEmail({
    required String email,
  }) = _SendPasswordResetEmail;
}