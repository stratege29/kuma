import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kuma/shared/domain/entities/user.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';
part 'onboarding_bloc.freezed.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc() : super(const OnboardingState()) {
    on<_NextPage>(_onNextPage);
    on<_PreviousPage>(_onPreviousPage);
    on<_GoToPage>(_onGoToPage);
    on<_SelectUserType>(_onSelectUserType);
    on<_AddChild>(_onAddChild);
    on<_RemoveChild>(_onRemoveChild);
    on<_UpdateChild>(_onUpdateChild);
    on<_SelectGoal>(_onSelectGoal);
    on<_SelectTime>(_onSelectTime);
    on<_SelectStartingCountry>(_onSelectStartingCountry);
    on<_CompleteOnboarding>(_onCompleteOnboarding);
    on<_SkipOnboarding>(_onSkipOnboarding);
  }

  void _onNextPage(
    _NextPage event,
    Emitter<OnboardingState> emit,
  ) {
    if (state.currentPage < 7) {
      emit(state.copyWith(currentPage: state.currentPage + 1));
    }
  }

  void _onPreviousPage(
    _PreviousPage event,
    Emitter<OnboardingState> emit,
  ) {
    if (state.currentPage > 0) {
      emit(state.copyWith(currentPage: state.currentPage - 1));
    }
  }

  void _onGoToPage(
    _GoToPage event,
    Emitter<OnboardingState> emit,
  ) {
    if (event.page >= 0 && event.page <= 7) {
      emit(state.copyWith(currentPage: event.page));
    }
  }

  void _onSelectUserType(
    _SelectUserType event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(userType: event.userType));
  }

  void _onAddChild(
    _AddChild event,
    Emitter<OnboardingState> emit,
  ) {
    if (state.children.length < 5) {
      final updatedChildren = [...state.children, event.child];
      emit(state.copyWith(children: updatedChildren));
    }
  }

  void _onRemoveChild(
    _RemoveChild event,
    Emitter<OnboardingState> emit,
  ) {
    final updatedChildren = state.children
        .where((child) => child.id != event.childId)
        .toList();
    emit(state.copyWith(children: updatedChildren));
  }

  void _onUpdateChild(
    _UpdateChild event,
    Emitter<OnboardingState> emit,
  ) {
    final updatedChildren = state.children.map((child) {
      return child.id == event.child.id ? event.child : child;
    }).toList();
    emit(state.copyWith(children: updatedChildren));
  }

  void _onSelectGoal(
    _SelectGoal event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(primaryGoal: event.goal));
  }

  void _onSelectTime(
    _SelectTime event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(preferredTime: event.time));
  }

  void _onSelectStartingCountry(
    _SelectStartingCountry event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(startingCountry: event.country));
  }

  void _onCompleteOnboarding(
    _CompleteOnboarding event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    
    try {
      // Ici on sauvegarderait les données utilisateur
      // await _saveUserSettings();
      
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Erreur lors de la sauvegarde: ${e.toString()}',
      ));
    }
  }

  void _onSkipOnboarding(
    _SkipOnboarding event,
    Emitter<OnboardingState> emit,
  ) {
    // Configuration par défaut pour skip
    emit(state.copyWith(
      userType: 'parent',
      primaryGoal: 'Découvrir de nouvelles histoires',
      preferredTime: 'Soir (18h-21h)',
      startingCountry: 'Senegal',
    ));
  }
}