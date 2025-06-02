import 'package:freezed_annotation/freezed_annotation.dart';

part 'story.freezed.dart';
part 'story.g.dart';

@freezed
class Story with _$Story {
  const factory Story({
    required String id,
    required String title,
    required String country,
    required String countryCode,
    required Map<String, String> content, // Contenu multilingue
    required String imageUrl,
    required String audioUrl,
    required int estimatedReadingTime, // en minutes
    required int estimatedAudioDuration, // en minutes
    required List<String> values, // Valeurs transmises
    required List<QuizQuestion> quizQuestions,
    required StoryMetadata metadata,
    @Default(false) bool isCompleted,
    @Default(false) bool isUnlocked,
    DateTime? completedAt,
  }) = _Story;

  factory Story.fromJson(Map<String, dynamic> json) => _$StoryFromJson(json);
}

@freezed
class QuizQuestion with _$QuizQuestion {
  const factory QuizQuestion({
    required String id,
    required String question,
    required List<String> options,
    required int correctAnswer, // Index de la bonne réponse
    String? explanation,
  }) = _QuizQuestion;

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => _$QuizQuestionFromJson(json);
}

@freezed
class StoryMetadata with _$StoryMetadata {
  const factory StoryMetadata({
    required String author,
    required String origin,
    required String moralLesson,
    required List<String> keywords,
    required String ageGroup,
    required String difficulty,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _StoryMetadata;

  factory StoryMetadata.fromJson(Map<String, dynamic> json) => _$StoryMetadataFromJson(json);
}

enum StoryStatus {
  locked,
  unlocked,
  completed,
}

enum StoryType {
  text,
  audio,
  interactive,
}