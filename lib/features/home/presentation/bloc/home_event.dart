part of 'home_bloc.dart';

@freezed
class HomeEvent with _$HomeEvent {
  const factory HomeEvent.loadStories() = _LoadStories;
  const factory HomeEvent.selectStory(Story story) = _SelectStory;
  const factory HomeEvent.clearSelection() = _ClearSelection;
  const factory HomeEvent.updateProgress(String storyId) = _UpdateProgress;
}