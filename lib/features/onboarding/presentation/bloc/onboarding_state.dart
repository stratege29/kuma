part of 'onboarding_bloc.dart';

@freezed
class OnboardingState with _$OnboardingState {
  const factory OnboardingState({
    @Default(0) int currentPage,
    @Default('') String userType,
    @Default([]) List<ChildProfile> children,
    @Default('') String primaryGoal,
    @Default('') String preferredTime,
    @Default('') String startingCountry,
    @Default(false) bool isLoading,
    String? error,
  }) = _OnboardingState;
}