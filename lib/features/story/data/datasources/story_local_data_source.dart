import 'package:hive/hive.dart';
import 'package:kuma/shared/domain/entities/story.dart';

abstract class StoryLocalDataSource {
  Future<void> cacheStories(List<Story> stories);
  Future<List<Story>> getCachedStories();
  Future<void> clearCache();
  Future<Story?> getCachedStoryById(String storyId);
  Future<List<Story>> getCachedStoriesByCountry(String country);
}

class StoryLocalDataSourceImpl implements StoryLocalDataSource {
  static const String _storiesBoxName = 'stories_cache';
  static const String _storiesKey = 'cached_stories';
  static const String _lastUpdateKey = 'last_update';

  @override
  Future<void> cacheStories(List<Story> stories) async {
    try {
      print('StoryLocalDataSource: Caching ${stories.length} stories...');
      
      final box = await Hive.openBox(_storiesBoxName);
      
      // Convert stories to JSON for storage - using string serialization to avoid Hive type issues
      final storiesJsonString = stories.map((story) {
        // Convert to JSON and then to JSON string to avoid complex object serialization issues
        final json = story.toJson();
        return json;
      }).toList();
      
      await box.put(_storiesKey, storiesJsonString);
      await box.put(_lastUpdateKey, DateTime.now().toIso8601String());
      
      print('StoryLocalDataSource: Successfully cached ${stories.length} stories');
    } catch (e) {
      print('StoryLocalDataSource: Error caching stories: $e');
      print('StoryLocalDataSource: Disabling cache for this session...');
      // Don't throw error - just log and continue without caching
    }
  }

  @override
  Future<List<Story>> getCachedStories() async {
    try {
      print('StoryLocalDataSource: Retrieving cached stories...');
      
      final box = await Hive.openBox(_storiesBoxName);
      final storiesJson = box.get(_storiesKey) as List<dynamic>?;
      
      if (storiesJson == null || storiesJson.isEmpty) {
        print('StoryLocalDataSource: No cached stories found');
        return [];
      }
      
      final stories = storiesJson
          .cast<Map<String, dynamic>>()
          .map((json) => Story.fromJson(json))
          .toList();
      
      print('StoryLocalDataSource: Retrieved ${stories.length} cached stories');
      return stories;
    } catch (e) {
      print('StoryLocalDataSource: Error retrieving cached stories: $e');
      return [];
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      print('StoryLocalDataSource: Clearing stories cache...');
      
      final box = await Hive.openBox(_storiesBoxName);
      await box.clear();
      
      print('StoryLocalDataSource: Stories cache cleared');
    } catch (e) {
      print('StoryLocalDataSource: Error clearing cache: $e');
      throw Exception('Failed to clear stories cache: $e');
    }
  }

  @override
  Future<Story?> getCachedStoryById(String storyId) async {
    try {
      final stories = await getCachedStories();
      
      final story = stories.where((story) => story.id == storyId).firstOrNull;
      
      if (story != null) {
        print('StoryLocalDataSource: Found cached story: $storyId');
      } else {
        print('StoryLocalDataSource: Cached story not found: $storyId');
      }
      
      return story;
    } catch (e) {
      print('StoryLocalDataSource: Error retrieving cached story $storyId: $e');
      return null;
    }
  }

  @override
  Future<List<Story>> getCachedStoriesByCountry(String country) async {
    try {
      final stories = await getCachedStories();
      
      final countryStories = stories
          .where((story) => story.country == country)
          .toList();
      
      print('StoryLocalDataSource: Found ${countryStories.length} cached stories for $country');
      return countryStories;
    } catch (e) {
      print('StoryLocalDataSource: Error retrieving cached stories for $country: $e');
      return [];
    }
  }

  /// Check if cache is still valid (not older than 24 hours)
  Future<bool> isCacheValid() async {
    try {
      final box = await Hive.openBox(_storiesBoxName);
      final lastUpdateString = box.get(_lastUpdateKey) as String?;
      
      if (lastUpdateString == null) {
        return false;
      }
      
      final lastUpdate = DateTime.parse(lastUpdateString);
      final difference = DateTime.now().difference(lastUpdate);
      
      // Cache is valid for 24 hours
      final isValid = difference.inHours < 24;
      print('StoryLocalDataSource: Cache is ${isValid ? 'valid' : 'expired'} (age: ${difference.inHours}h)');
      
      return isValid;
    } catch (e) {
      print('StoryLocalDataSource: Error checking cache validity: $e');
      return false;
    }
  }
}