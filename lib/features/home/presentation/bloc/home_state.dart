part of 'home_bloc.dart';

@freezed
class HomeState with _$HomeState {
  const factory HomeState({
    @Default([]) List<Story> stories,
    @Default('') String currentCountry,
    @Default([]) List<String> unlockedCountries,
    @Default([]) List<String> completedCountries,
    @Default(false) bool isPremium,
    @Default(0) int caurisCount,
    @Default("Petit Griot") String currentLevel,
    Story? selectedStory,
    @Default(false) bool isLoading,
    String? error,
    DateTime? lastStoryUnlock,
  }) = _HomeState;
}