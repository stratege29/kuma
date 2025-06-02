part of 'onboarding_bloc.dart';

@freezed
class OnboardingEvent with _$OnboardingEvent {
  const factory OnboardingEvent.nextPage() = _NextPage;
  const factory OnboardingEvent.previousPage() = _PreviousPage;
  const factory OnboardingEvent.goToPage(int page) = _GoToPage;
  const factory OnboardingEvent.selectUserType(String userType) = _SelectUserType;
  const factory OnboardingEvent.addChild(ChildProfile child) = _AddChild;
  const factory OnboardingEvent.removeChild(String childId) = _RemoveChild;
  const factory OnboardingEvent.updateChild(ChildProfile child) = _UpdateChild;
  const factory OnboardingEvent.selectGoal(String goal) = _SelectGoal;
  const factory OnboardingEvent.selectTime(String time) = _SelectTime;
  const factory OnboardingEvent.selectStartingCountry(String country) = _SelectStartingCountry;
  const factory OnboardingEvent.completeOnboarding() = _CompleteOnboarding;
  const factory OnboardingEvent.skipOnboarding() = _SkipOnboarding;
}