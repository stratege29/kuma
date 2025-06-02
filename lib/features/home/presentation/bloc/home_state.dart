part of 'home_bloc.dart';

@freezed
class HomeState with _$HomeState {
  const factory HomeState({
    @Default([]) List<Story> stories,
    @Default('') String currentCountry,
    @Default([]) List<String> unlockedCountries,
    Story? selectedStory,
    @Default(false) bool isLoading,
    String? error,
  }) = _HomeState;
}