import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kuma/core/constants/countries.dart';

part 'map_state.freezed.dart';

@freezed
class MapState with _$MapState {
  const factory MapState({
    required String currentCountry,
    required String startingCountry,
    required List<String> unlockedCountries,
    required List<String> completedCountries,
    required Map<String, String> storyStates, // country -> state
    required Offset currentMapOffset,
    @Default(false) bool isAnimating,
    @Default(false) bool isPremium,
    @Default(0) int totalStoryProgress,
    @Default(0) int caurisCount,
    @Default("Petit Griot") String currentLevel,
    DateTime? lastStoryUnlock,
  }) = _MapState;
}

@freezed
class StoryPosition with _$StoryPosition {
  const factory StoryPosition({
    required String countryCode,
    required String countryName,
    required double xPercent,
    required double yPercent,
    required int orderInPath,
    required String state, // invisible, visible_locked, unlocked, completed
  }) = _StoryPosition;

  const StoryPosition._();

  /// Convert percentage position to absolute coordinates
  Offset toAbsolute(Size mapSize) {
    return Offset(
      mapSize.width * xPercent,
      mapSize.height * yPercent,
    );
  }

  /// Check if story is accessible
  bool get isAccessible => state == Countries.STORY_STATE_UNLOCKED || state == Countries.STORY_STATE_COMPLETED;

  /// Check if story is completed
  bool get isCompleted => state == Countries.STORY_STATE_COMPLETED;

  /// Check if story is locked but visible
  bool get isVisibleLocked => state == Countries.STORY_STATE_VISIBLE_LOCKED;

  /// Check if story is invisible
  bool get isInvisible => state == Countries.STORY_STATE_INVISIBLE;
}

@freezed
class MapConfig with _$MapConfig {
  const factory MapConfig({
    @Default(2000.0) double mapWidth,
    @Default(2400.0) double mapHeight,
    @Default(1.0) double minScale,
    @Default(1.0) double maxScale,
    @Default(100.0) double boundaryMargin,
  }) = _MapConfig;
}

@freezed
class MapViewport with _$MapViewport {
  const factory MapViewport({
    required Offset offset,
    required Size size,
    required Size mapSize,
  }) = _MapViewport;

  const MapViewport._();

  /// Get visible rectangle in map coordinates
  Rect get visibleRect {
    return Rect.fromLTWH(
      -offset.dx,
      -offset.dy,
      size.width,
      size.height,
    );
  }

  /// Get normalized visible area (0.0 - 1.0)
  Rect get normalizedVisibleArea {
    final visible = visibleRect;
    return Rect.fromLTRB(
      visible.left / mapSize.width,
      visible.top / mapSize.height,
      visible.right / mapSize.width,
      visible.bottom / mapSize.height,
    );
  }
}

/// Progress levels based on completion percentage
class ProgressLevels {
  static const Map<int, String> LEVELS = {
    0: "Petit Griot",
    10: "Explorateur du Village",
    25: "Conteur des Terres",
    40: "Sage des Chemins",
    60: "Maître des Histoires",
    80: "Gardien des Traditions",
    100: "Légende d'Afrique",
  };

  static String getLevelForProgress(int progressPercentage) {
    int currentLevel = 0;
    for (int threshold in LEVELS.keys) {
      if (progressPercentage >= threshold) {
        currentLevel = threshold;
      }
    }
    return LEVELS[currentLevel] ?? "Petit Griot";
  }

  static int getProgressPercentage(int completedStories, int totalStories) {
    if (totalStories == 0) return 0;
    return ((completedStories / totalStories) * 100).round();
  }
}