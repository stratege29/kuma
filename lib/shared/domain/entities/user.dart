import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class AppUser with _$AppUser {
  const factory AppUser({
    required String id,
    required String email,
    required String userType,
    required UserSettings settings,
    required List<ChildProfile> childProfiles,
    required UserProgress progress,
    required UserPreferences preferences,
    @Default(false) bool isPremium,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    DateTime? premiumExpiresAt,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);
}

@freezed
class UserSettings with _$UserSettings {
  const factory UserSettings({
    required String startingCountry,
    required String primaryGoal,
    required String preferredReadingTime,
    required String language,
    @Default(false) bool isOnboardingCompleted,
    @Default(false) bool notificationsEnabled,
    @Default(false) bool soundEnabled,
    @Default(16.0) double fontSize,
    @Default(false) bool darkMode,
  }) = _UserSettings;

  factory UserSettings.fromJson(Map<String, dynamic> json) => _$UserSettingsFromJson(json);
}

@freezed
class ChildProfile with _$ChildProfile {
  const factory ChildProfile({
    required String id,
    required String name,
    required int age,
    required String avatar,
    required UserProgress progress,
    DateTime? createdAt,
  }) = _ChildProfile;

  factory ChildProfile.fromJson(Map<String, dynamic> json) => _$ChildProfileFromJson(json);
}

@freezed
class UserProgress with _$UserProgress {
  const factory UserProgress({
    required String currentCountry,
    required Map<String, List<String>> completedStories, // country -> list of story IDs
    required Map<String, QuizResult> quizResults, // story ID -> result
    required int totalStoriesRead,
    required int totalTimeSpent, // en minutes
    required List<String> unlockedCountries,
    required List<Achievement> achievements,
    @Default(0) int streak,
    DateTime? lastReadingDate,
  }) = _UserProgress;

  factory UserProgress.fromJson(Map<String, dynamic> json) => _$UserProgressFromJson(json);
}

@freezed
class QuizResult with _$QuizResult {
  const factory QuizResult({
    required String storyId,
    required int score,
    required int totalQuestions,
    required List<QuizAnswer> answers,
    required DateTime completedAt,
    @Default(1) int attempts,
  }) = _QuizResult;

  factory QuizResult.fromJson(Map<String, dynamic> json) => _$QuizResultFromJson(json);
}

@freezed
class QuizAnswer with _$QuizAnswer {
  const factory QuizAnswer({
    required String questionId,
    required int selectedAnswer,
    required bool isCorrect,
    required DateTime answeredAt,
  }) = _QuizAnswer;

  factory QuizAnswer.fromJson(Map<String, dynamic> json) => _$QuizAnswerFromJson(json);
}

@freezed
class Achievement with _$Achievement {
  const factory Achievement({
    required String id,
    required String title,
    required String description,
    required String iconUrl,
    required DateTime unlockedAt,
  }) = _Achievement;

  factory Achievement.fromJson(Map<String, dynamic> json) => _$AchievementFromJson(json);
}

@freezed
class UserPreferences with _$UserPreferences {
  const factory UserPreferences({
    @Default("fr") String language,
    @Default(true) bool autoPlay,
    @Default(1.0) double playbackSpeed,
    @Default(true) bool showSubtitles,
    @Default(false) bool parentalControlEnabled,
  }) = _UserPreferences;

  factory UserPreferences.fromJson(Map<String, dynamic> json) => _$UserPreferencesFromJson(json);
}