import 'package:dartz/dartz.dart';
import 'package:kuma/core/error/failure.dart';
import 'package:kuma/features/story/data/datasources/story_local_data_source.dart';
import 'package:kuma/features/story/data/datasources/story_remote_data_source.dart';
import 'package:kuma/features/story/domain/repositories/story_repository.dart';
import 'package:kuma/shared/domain/entities/story.dart';

class StoryRepositoryImpl implements StoryRepository {
  final StoryRemoteDataSource remoteDataSource;
  final StoryLocalDataSource localDataSource;

  StoryRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<Story>>> getAllStories() async {
    try {
      print('StoryRepository: Getting all stories...');
      
      // Temporarily disable cache to always fetch fresh stories from Firebase
      // TODO: Re-enable caching once Hive serialization is fixed
      // if (await (localDataSource as StoryLocalDataSourceImpl).isCacheValid()) {
      //   print('StoryRepository: Using cached stories');
      //   final cachedStories = await localDataSource.getCachedStories();
      //   if (cachedStories.isNotEmpty) {
      //     return Right(cachedStories);
      //   }
      // }
      
      // Fetch from remote if cache is invalid or empty
      print('StoryRepository: Fetching from remote source...');
      final stories = await remoteDataSource.getAllStories();
      
      // Cache the fetched stories (non-blocking)
      await localDataSource.cacheStories(stories);
      
      print('StoryRepository: Successfully retrieved ${stories.length} stories');
      return Right(stories);
    } catch (e) {
      print('StoryRepository: Error getting all stories: $e');
      
      // Fallback to cached stories even if expired
      try {
        final cachedStories = await localDataSource.getCachedStories();
        if (cachedStories.isNotEmpty) {
          print('StoryRepository: Using expired cache as fallback');
          return Right(cachedStories);
        }
      } catch (cacheError) {
        print('StoryRepository: Cache fallback also failed: $cacheError');
      }
      
      return Left(NetworkFailure(
        message: 'Failed to fetch stories: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<Failure, List<Story>>> getStoriesByCountry(String country) async {
    try {
      print('StoryRepository: Getting stories for country: $country');
      
      // Try cache first
      if (await (localDataSource as StoryLocalDataSourceImpl).isCacheValid()) {
        final cachedStories = await localDataSource.getCachedStoriesByCountry(country);
        if (cachedStories.isNotEmpty) {
          print('StoryRepository: Using cached stories for $country');
          return Right(cachedStories);
        }
      }
      
      // Fetch from remote
      final stories = await remoteDataSource.getStoriesByCountry(country);
      
      print('StoryRepository: Retrieved ${stories.length} stories for $country');
      return Right(stories);
    } catch (e) {
      print('StoryRepository: Error getting stories for $country: $e');
      
      // Fallback to cache
      try {
        final cachedStories = await localDataSource.getCachedStoriesByCountry(country);
        if (cachedStories.isNotEmpty) {
          return Right(cachedStories);
        }
      } catch (cacheError) {
        print('StoryRepository: Cache fallback failed: $cacheError');
      }
      
      return Left(NetworkFailure(
        message: 'Failed to fetch stories for $country: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<Failure, Story?>> getStoryById(String storyId) async {
    try {
      print('StoryRepository: Getting story by ID: $storyId');
      
      // Try cache first
      final cachedStory = await localDataSource.getCachedStoryById(storyId);
      if (cachedStory != null) {
        print('StoryRepository: Using cached story: $storyId');
        return Right(cachedStory);
      }
      
      // Fetch from remote
      final story = await remoteDataSource.getStoryById(storyId);
      
      print('StoryRepository: ${story != null ? 'Found' : 'Not found'} story: $storyId');
      return Right(story);
    } catch (e) {
      print('StoryRepository: Error getting story $storyId: $e');
      return Left(NetworkFailure(
        message: 'Failed to fetch story $storyId: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<Failure, List<Story>>> getStoriesByDifficulty(String difficulty) async {
    try {
      print('StoryRepository: Getting stories by difficulty: $difficulty');
      
      final stories = await remoteDataSource.getStoriesByDifficulty(difficulty);
      
      print('StoryRepository: Retrieved ${stories.length} stories with difficulty $difficulty');
      return Right(stories);
    } catch (e) {
      print('StoryRepository: Error getting stories by difficulty $difficulty: $e');
      return Left(NetworkFailure(
        message: 'Failed to fetch stories by difficulty $difficulty: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<Failure, List<Story>>> getStoriesByTags(List<String> tags) async {
    try {
      print('StoryRepository: Getting stories by tags: $tags');
      
      final stories = await remoteDataSource.getStoriesByTags(tags);
      
      print('StoryRepository: Retrieved ${stories.length} stories with tags $tags');
      return Right(stories);
    } catch (e) {
      print('StoryRepository: Error getting stories by tags $tags: $e');
      return Left(NetworkFailure(
        message: 'Failed to fetch stories by tags $tags: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<Failure, List<Story>>> getPublishedStories() async {
    try {
      print('StoryRepository: Getting published stories...');
      
      final stories = await remoteDataSource.getPublishedStories();
      
      print('StoryRepository: Retrieved ${stories.length} published stories');
      return Right(stories);
    } catch (e) {
      print('StoryRepository: Error getting published stories: $e');
      return Left(NetworkFailure(
        message: 'Failed to fetch published stories: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getUserStoryProgress(String userId) async {
    try {
      print('StoryRepository: Getting user story progress for: $userId');
      
      // This would fetch from user's document in Firestore
      // For now, return empty progress
      return const Right(<String, dynamic>{});
    } catch (e) {
      print('StoryRepository: Error getting user progress: $e');
      return Left(NetworkFailure(
        message: 'Failed to fetch user story progress: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserStoryProgress(
    String userId,
    String storyId,
    Map<String, dynamic> progress,
  ) async {
    try {
      print('StoryRepository: Updating user story progress for user: $userId, story: $storyId');
      
      // This would update user's document in Firestore
      // For now, just log
      print('StoryRepository: Progress update: $progress');
      
      return const Right(null);
    } catch (e) {
      print('StoryRepository: Error updating user progress: $e');
      return Left(NetworkFailure(
        message: 'Failed to update user story progress: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> cacheStories(List<Story> stories) async {
    try {
      await localDataSource.cacheStories(stories);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to cache stories: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<Failure, List<Story>>> getCachedStories() async {
    try {
      final stories = await localDataSource.getCachedStories();
      return Right(stories);
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to get cached stories: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> clearCache() async {
    try {
      await localDataSource.clearCache();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to clear stories cache: ${e.toString()}',
      ));
    }
  }
}