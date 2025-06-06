import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kuma/shared/domain/entities/story.dart';
import 'package:kuma/shared/domain/entities/user.dart';
import 'package:kuma/core/constants/countries.dart';
import 'package:kuma/core/storage/device_preferences.dart';
import 'package:kuma/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:kuma/features/story/domain/repositories/story_repository.dart';

part 'home_event.dart';
part 'home_state.dart';
part 'home_bloc.freezed.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final StoryRepository storyRepository;
  final AppUser user;

  HomeBloc({required this.storyRepository, required this.user})
      : super(const HomeState()) {
    on<_LoadStories>(_onLoadStories);
    on<_SelectStory>(_onSelectStory);
    on<_ClearSelection>(_onClearSelection);
    on<_UpdateProgress>(_onUpdateProgress);
  }

  void _onLoadStories(
    _LoadStories event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      print('HomeBloc: Loading stories from Firestore...');

      // Load stories from Firestore
      final result = await storyRepository.getAllStories();

      // Handle the result without using fold with async callbacks
      if (result.isLeft()) {
        // Handle failure case
        final failure = result.fold((l) => l, (r) => null)!;
        print('HomeBloc: Failed to load stories: ${failure.message}');

        // Fallback to mock stories if Firebase fails
        final stories = _generateMockStories();
        final startingCountry = await _getStartingCountry();
        final unlockedCountries = [startingCountry];

        if (!emit.isDone) {
          emit(state.copyWith(
            stories: stories,
            currentCountry: startingCountry,
            unlockedCountries: unlockedCountries,
            isLoading: false,
            error: 'Using offline stories: ${failure.message}',
          ));
        }
      } else {
        // Handle success case
        final stories = result.fold((l) => null, (r) => r)!;
        print(
            'HomeBloc: Successfully loaded ${stories.length} stories from Firestore');

        // Get the starting country from saved settings
        final startingCountry = await _getStartingCountry();
        final unlockedCountries = [startingCountry];

        if (!emit.isDone) {
          emit(state.copyWith(
            stories: stories,
            currentCountry: startingCountry,
            unlockedCountries: unlockedCountries,
            isLoading: false,
            error: null,
          ));
        }
      }
    } catch (e) {
      print('HomeBloc: Exception loading stories: $e');
      if (!emit.isDone) {
        emit(state.copyWith(
          isLoading: false,
          error: 'Erreur lors du chargement: ${e.toString()}',
        ));
      }
    }
  }

  void _onSelectStory(
    _SelectStory event,
    Emitter<HomeState> emit,
  ) {
    emit(state.copyWith(selectedStory: event.story));
  }

  void _onClearSelection(
    _ClearSelection event,
    Emitter<HomeState> emit,
  ) {
    emit(state.copyWith(selectedStory: null));
  }

  void _onUpdateProgress(
    _UpdateProgress event,
    Emitter<HomeState> emit,
  ) {
    // Marquer l'histoire comme complétée et débloquer le pays suivant
    final updatedStories = state.stories.map((story) {
      if (story.id == event.storyId) {
        return story.copyWith(isCompleted: true, completedAt: DateTime.now());
      }
      return story;
    }).toList();

    // Déterminer le prochain pays à débloquer
    final nextCountry = Countries.getNextCountry(state.currentCountry);
    final updatedUnlockedCountries = [...state.unlockedCountries];
    if (!updatedUnlockedCountries.contains(nextCountry)) {
      updatedUnlockedCountries.add(nextCountry);
    }

    emit(state.copyWith(
      stories: updatedStories,
      currentCountry: nextCountry,
      unlockedCountries: updatedUnlockedCountries,
    ));
  }

  List<Story> _generateMockStories() {
    return Countries.TEST_COUNTRIES.take(5).map((country) {
      return Story(
        id: '${country.toLowerCase()}_1',
        title: _getStoryTitle(country),
        country: country,
        countryCode: Countries.COUNTRY_ORDER[country] ?? '',
        content: {'fr': _getStoryContent(country)},
        imageUrl:
            'placeholder_${Countries.COUNTRY_ORDER[country]?.toLowerCase()}_1.jpg',
        audioUrl:
            'placeholder_${Countries.COUNTRY_ORDER[country]?.toLowerCase()}_1.mp3',
        estimatedReadingTime: 4,
        estimatedAudioDuration: 5,
        values: ['Courage', 'Sagesse'],
        quizQuestions: _generateQuizQuestions(country),
        metadata: StoryMetadata(
          author: 'Conte traditionnel',
          origin: country,
          moralLesson: 'La sagesse triomphe de la force',
          keywords: ['courage', 'sagesse', 'tradition'],
          ageGroup: '6-12 ans',
          difficulty: 'Facile',
        ),
        isUnlocked: false, // Will be set properly when stories are loaded
      );
    }).toList();
  }

  String _getStoryTitle(String country) {
    final titles = {
      'Senegal': 'Leuk le lièvre et Bouki l\'hyène',
      'Cote d\'Ivoire': 'Anansi et la sagesse du monde',
      'Ghana': 'Le tambour magique d\'Akan',
      'Nigeria': 'La tortue et l\'aigle royal',
      'Cameroon': 'Le chasseur et l\'esprit de la forêt',
    };
    return titles[country] ?? 'Conte de $country';
  }

  String _getStoryContent(String country) {
    return '''Il était une fois, dans le magnifique pays de $country, une histoire extraordinaire qui se transmettait de génération en génération.

Cette histoire raconte la sagesse de nos ancêtres et les valeurs importantes de notre culture africaine. Les personnages de ce conte nous enseignent que la ruse et l'intelligence peuvent triompher de la force brute.

À travers les aventures captivantes de nos héros, nous découvrons l'importance du respect, de la solidarité et de la persévérance. Ces valeurs sont au cœur de la tradition orale africaine.

Le conte se déroule dans un village paisible où la communauté vit en harmonie avec la nature. Les anciens transmettent leur sagesse aux plus jeunes à travers ces récits merveilleux.

Cette histoire nous rappelle que chaque défi peut être surmonté avec de la créativité et de la détermination. Les héros de nos contes africains nous inspirent à être courageux face aux difficultés.''';
  }

  List<QuizQuestion> _generateQuizQuestions(String country) {
    return [
      QuizQuestion(
        id: '${country}_q1',
        question: 'Quelle est la principale leçon de cette histoire ?',
        options: [
          'La force est la plus importante',
          'L\'intelligence triomphe de la force',
          'Il faut toujours fuir les problèmes',
          'L\'argent résout tout'
        ],
        correctAnswer: 1,
      ),
      QuizQuestion(
        id: '${country}_q2',
        question: 'Où se déroule cette histoire ?',
        options: [
          'Dans une grande ville',
          'Dans un village africain',
          'Dans la forêt',
          'Au bord de la mer'
        ],
        correctAnswer: 1,
      ),
      QuizQuestion(
        id: '${country}_q3',
        question: 'Quelle valeur est mise en avant dans ce conte ?',
        options: ['La paresse', 'L\'égoïsme', 'La sagesse', 'La colère'],
        correctAnswer: 2,
      ),
    ];
  }

  /// Get the starting country from user-specific sources only
  Future<String> _getStartingCountry() async {
    // Priority order for user-specific data only:
    // 1. User's saved settings (from Firebase)
    // 2. In-memory settings store (for current session)
    // 3. Error - user must complete onboarding

    // Check user's saved settings first
    if (user.settings.startingCountry.isNotEmpty) {
      print(
          'HomeBloc: Using starting country from user settings: ${user.settings.startingCountry}');
      return user.settings.startingCountry;
    }

    // Check device preferences
    final deviceCountry = await DevicePreferences.getStartingCountry();
    if (deviceCountry != null && deviceCountry.isNotEmpty) {
      print(
          'HomeBloc: Using starting country from device preferences: $deviceCountry');
      return deviceCountry;
    }

    // Check in-memory store (for current session)
    final memorySettings = UserSettingsStore.getSettings();
    if (memorySettings?.startingCountry != null &&
        memorySettings!.startingCountry.isNotEmpty) {
      print(
          'HomeBloc: Using starting country from memory store: ${memorySettings.startingCountry}');
      return memorySettings.startingCountry;
    }

    // No fallback - user must select a starting country through onboarding
    print(
        'HomeBloc: ERROR - No starting country found! User should complete onboarding.');
    throw Exception(
        'No starting country selected. Please complete onboarding.');
  }
}
