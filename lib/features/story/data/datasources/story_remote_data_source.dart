import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kuma/core/constants/app_constants.dart';
import 'package:kuma/shared/domain/entities/story.dart';

abstract class StoryRemoteDataSource {
  Future<List<Story>> getAllStories();
  Future<List<Story>> getStoriesByCountry(String country);
  Future<Story?> getStoryById(String storyId);
  Future<List<Story>> getStoriesByDifficulty(String difficulty);
  Future<List<Story>> getStoriesByTags(List<String> tags);
  Future<List<Story>> getPublishedStories();
}

class StoryRemoteDataSourceImpl implements StoryRemoteDataSource {
  final FirebaseFirestore firestore;

  StoryRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<Story>> getAllStories() async {
    try {
      print('StoryRemoteDataSource: Fetching all stories from Firestore...');
      final querySnapshot = await firestore
          .collection(AppConstants.COLLECTION_STORIES)
          .where('isPublished', isEqualTo: true)
          .get();

      print(
          'StoryRemoteDataSource: Found ${querySnapshot.docs.length} stories');
      final stories = _convertDocumentsToStories(querySnapshot.docs);

      // Sort locally to avoid composite index
      stories.sort((a, b) {
        final countryComparison = a.country.compareTo(b.country);
        if (countryComparison != 0) return countryComparison;

        // Extract order from metadata or use 0 as default
        final aOrder = _extractOrder(a);
        final bOrder = _extractOrder(b);
        return aOrder.compareTo(bOrder);
      });

      return stories;
    } catch (e) {
      print('StoryRemoteDataSource: Error fetching all stories: $e');
      throw Exception('Failed to fetch stories: $e');
    }
  }

  @override
  Future<List<Story>> getStoriesByCountry(String country) async {
    try {
      print('StoryRemoteDataSource: Fetching stories for country: $country');
      final querySnapshot = await firestore
          .collection(AppConstants.COLLECTION_STORIES)
          .where('country', isEqualTo: country)
          .where('isPublished', isEqualTo: true)
          .get();

      print(
          'StoryRemoteDataSource: Found ${querySnapshot.docs.length} stories for $country');
      final stories = _convertDocumentsToStories(querySnapshot.docs);

      // Sort locally by order
      stories.sort((a, b) {
        final aOrder = _extractOrder(a);
        final bOrder = _extractOrder(b);
        return aOrder.compareTo(bOrder);
      });

      return stories;
    } catch (e) {
      print('StoryRemoteDataSource: Error fetching stories for $country: $e');
      throw Exception('Failed to fetch stories for $country: $e');
    }
  }

  @override
  Future<Story?> getStoryById(String storyId) async {
    try {
      print('StoryRemoteDataSource: Fetching story with ID: $storyId');
      final docSnapshot = await firestore
          .collection(AppConstants.COLLECTION_STORIES)
          .doc(storyId)
          .get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        print('StoryRemoteDataSource: Found story: $storyId');
        return _convertDocumentToStory(docSnapshot);
      }

      print('StoryRemoteDataSource: Story not found: $storyId');
      return null;
    } catch (e) {
      print('StoryRemoteDataSource: Error fetching story $storyId: $e');
      throw Exception('Failed to fetch story $storyId: $e');
    }
  }

  @override
  Future<List<Story>> getStoriesByDifficulty(String difficulty) async {
    try {
      print(
          'StoryRemoteDataSource: Fetching stories with difficulty: $difficulty');
      final querySnapshot = await firestore
          .collection(AppConstants.COLLECTION_STORIES)
          .where('metadata.difficulty', isEqualTo: difficulty)
          .where('isPublished', isEqualTo: true)
          .get();

      print(
          'StoryRemoteDataSource: Found ${querySnapshot.docs.length} stories with difficulty $difficulty');
      final stories = _convertDocumentsToStories(querySnapshot.docs);

      // Sort locally
      stories.sort((a, b) {
        final countryComparison = a.country.compareTo(b.country);
        if (countryComparison != 0) return countryComparison;
        return _extractOrder(a).compareTo(_extractOrder(b));
      });

      return stories;
    } catch (e) {
      print(
          'StoryRemoteDataSource: Error fetching stories by difficulty $difficulty: $e');
      throw Exception('Failed to fetch stories by difficulty $difficulty: $e');
    }
  }

  @override
  Future<List<Story>> getStoriesByTags(List<String> tags) async {
    try {
      print('StoryRemoteDataSource: Fetching stories with tags: $tags');
      final querySnapshot = await firestore
          .collection(AppConstants.COLLECTION_STORIES)
          .where('tags', arrayContainsAny: tags)
          .where('isPublished', isEqualTo: true)
          .get();

      print(
          'StoryRemoteDataSource: Found ${querySnapshot.docs.length} stories with tags $tags');
      final stories = _convertDocumentsToStories(querySnapshot.docs);

      // Sort locally
      stories.sort((a, b) => a.country.compareTo(b.country));

      return stories;
    } catch (e) {
      print('StoryRemoteDataSource: Error fetching stories by tags $tags: $e');
      throw Exception('Failed to fetch stories by tags $tags: $e');
    }
  }

  @override
  Future<List<Story>> getPublishedStories() async {
    try {
      print('StoryRemoteDataSource: Fetching published stories...');
      final querySnapshot = await firestore
          .collection(AppConstants.COLLECTION_STORIES)
          .where('isPublished', isEqualTo: true)
          .get();

      print(
          'StoryRemoteDataSource: Found ${querySnapshot.docs.length} published stories');
      final stories = _convertDocumentsToStories(querySnapshot.docs);

      // Sort locally
      stories.sort((a, b) {
        final countryComparison = a.country.compareTo(b.country);
        if (countryComparison != 0) return countryComparison;
        return _extractOrder(a).compareTo(_extractOrder(b));
      });

      return stories;
    } catch (e) {
      print('StoryRemoteDataSource: Error fetching published stories: $e');
      throw Exception('Failed to fetch published stories: $e');
    }
  }

  List<Story> _convertDocumentsToStories(List<QueryDocumentSnapshot> docs) {
    return docs.map((doc) => _convertDocumentToStory(doc)).toList();
  }

  Story _convertDocumentToStory(DocumentSnapshot doc) {
    Map<String, dynamic>? data;
    try {
      data = doc.data() as Map<String, dynamic>;

      // Handle Firestore Timestamp conversion to String for JSON parsing
      if (data['metadata'] != null) {
        final metadata = data['metadata'] as Map<String, dynamic>;

        // Convert Firestore Timestamp to ISO String for JSON parsing
        if (metadata['createdAt'] != null) {
          if (metadata['createdAt'] is Timestamp) {
            metadata['createdAt'] =
                (metadata['createdAt'] as Timestamp).toDate().toIso8601String();
          } else if (metadata['createdAt'] is DateTime) {
            metadata['createdAt'] =
                (metadata['createdAt'] as DateTime).toIso8601String();
          }
          // If it's already a string, leave it as is
        }

        if (metadata['updatedAt'] != null) {
          if (metadata['updatedAt'] is Timestamp) {
            metadata['updatedAt'] =
                (metadata['updatedAt'] as Timestamp).toDate().toIso8601String();
          } else if (metadata['updatedAt'] is DateTime) {
            metadata['updatedAt'] =
                (metadata['updatedAt'] as DateTime).toIso8601String();
          }
          // If it's already a string, leave it as is
        }
      }

      // Handle any other potential Timestamp fields at root level
      if (data['completedAt'] != null) {
        if (data['completedAt'] is Timestamp) {
          data['completedAt'] =
              (data['completedAt'] as Timestamp).toDate().toIso8601String();
        } else if (data['completedAt'] is DateTime) {
          data['completedAt'] =
              (data['completedAt'] as DateTime).toIso8601String();
        }
      }

      // Handle null values for required numeric fields
      if (data['estimatedReadingTime'] == null) {
        data['estimatedReadingTime'] = 5; // Default 5 minutes
      }
      if (data['estimatedAudioDuration'] == null) {
        data['estimatedAudioDuration'] = 8; // Default 8 minutes
      }
      
      // Ensure required fields have defaults
      if (data['values'] == null) {
        data['values'] = <String>[];
      }
      if (data['quizQuestions'] == null) {
        data['quizQuestions'] = <Map<String, dynamic>>[];
      }
      if (data['content'] == null) {
        data['content'] = <String, String>{'fr': 'Contenu à venir...'};
      }
      if (data['imageUrl'] == null) {
        data['imageUrl'] = '';
      }
      if (data['audioUrl'] == null) {
        data['audioUrl'] = '';
      }

      // User-specific fields (these will be managed separately)
      data['isCompleted'] = false;
      data['isUnlocked'] = false;
      if (!data.containsKey('completedAt')) {
        data['completedAt'] = null;
      }

      print(
          'StoryRemoteDataSource: Converting document ${doc.id} with processed data...');
      return Story.fromJson(data);
    } catch (e, stackTrace) {
      print('StoryRemoteDataSource: Error converting document ${doc.id}: $e');
      print('StoryRemoteDataSource: Stack trace: $stackTrace');
      print('StoryRemoteDataSource: Raw document data: ${doc.data()}');
      print('StoryRemoteDataSource: Processed data: $data');

      // Try to identify the specific field causing issues
      if (e.toString().contains('DateTime') &&
          e.toString().contains('String')) {
        print('StoryRemoteDataSource: DateTime conversion error detected');
        if (data != null && data.containsKey('metadata')) {
          print('StoryRemoteDataSource: Metadata: ${data['metadata']}');
        }
      }
      
      if (e.toString().contains('Null') && e.toString().contains('num')) {
        print('StoryRemoteDataSource: Null to num conversion error detected');
        print('StoryRemoteDataSource: estimatedReadingTime: ${data?['estimatedReadingTime']}');
        print('StoryRemoteDataSource: estimatedAudioDuration: ${data?['estimatedAudioDuration']}');
      }

      throw Exception('Failed to convert story document ${doc.id}: $e');
    }
  }

  int _extractOrder(Story story) {
    // Try to get order from the story data, default to 0
    // You can access this from the story's metadata or a direct field
    return 0; // For now, return 0 as default - this can be enhanced later
  }
}
