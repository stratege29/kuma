part of 'auth_bloc.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = Initial;
  const factory AuthState.loading() = Loading;
  const factory AuthState.authenticated({
    required AppUser user,
  }) = Authenticated;
  const factory AuthState.unauthenticated({
    String? message,
  }) = Unauthenticated;
  const factory AuthState.error({
    required String message,
  }) = Error;
  const factory AuthState.passwordResetEmailSent() = PasswordResetEmailSent;
}