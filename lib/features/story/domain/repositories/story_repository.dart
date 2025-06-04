import 'package:dartz/dartz.dart';
import 'package:kuma/core/error/failure.dart';
import 'package:kuma/shared/domain/entities/story.dart';

abstract class StoryRepository {
  /// Get all stories from Firestore
  Future<Either<Failure, List<Story>>> getAllStories();
  
  /// Get stories for a specific country
  Future<Either<Failure, List<Story>>> getStoriesByCountry(String country);
  
  /// Get a single story by ID
  Future<Either<Failure, Story?>> getStoryById(String storyId);
  
  /// Get stories by difficulty level
  Future<Either<Failure, List<Story>>> getStoriesByDifficulty(String difficulty);
  
  /// Search stories by tags
  Future<Either<Failure, List<Story>>> getStoriesByTags(List<String> tags);
  
  /// Get published stories only
  Future<Either<Failure, List<Story>>> getPublishedStories();
  
  /// Get user-specific story progress (completed, unlocked states)
  Future<Either<Failure, Map<String, dynamic>>> getUserStoryProgress(String userId);
  
  /// Update user story progress (mark as completed, etc.)
  Future<Either<Failure, void>> updateUserStoryProgress(
    String userId,
    String storyId,
    Map<String, dynamic> progress,
  );
  
  /// Cache management
  Future<Either<Failure, void>> cacheStories(List<Story> stories);
  Future<Either<Failure, List<Story>>> getCachedStories();
  Future<Either<Failure, void>> clearCache();
}