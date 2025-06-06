import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kuma/core/constants/app_constants.dart';
import 'package:kuma/core/di/injection_container.dart';
import 'package:kuma/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:kuma/features/onboarding/presentation/widgets/onboarding_page_view.dart';
import 'package:kuma/features/onboarding/presentation/widgets/page_indicator.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OnboardingBloc(authRepository: sl()),
      child: const OnboardingView(),
    );
  }
}

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: BlocConsumer<OnboardingBloc, OnboardingState>(
        listener: (context, state) {
          // Navigation vers la page suivante
          if (state.currentPage != _pageController.page?.round()) {
            _pageController.animateToPage(
              state.currentPage,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }

          // Navigation vers l'app après completion
          if (state.currentPage > 6) {
            context.go(
              AppConstants.ROUTE_HOME,
              extra: state.startingCountry.isNotEmpty ? state.startingCountry : null,
            );
          if (state.currentPage > 7) {
            print(
                'OnboardingPage: Onboarding completed, navigating to splash (currentPage: ${state.currentPage})');
            
            // Navigate to splash (AuthWrapper) which will re-evaluate auth state with fresh data
            context.go(AppConstants.ROUTE_SPLASH);
          }

          // Affichage des erreurs
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Column(
              children: [
                // En-tête avec skip button
                _buildHeader(context, state),

                // Indicateur de progression
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: PageIndicator(
                    currentPage: state.currentPage,
                    totalPages: 8,
                  ),
                ),

                // Contenu principal
                Expanded(
                  child: OnboardingPageView(
                    pageController: _pageController,
                    onPageChanged: (page) {
                      context.read<OnboardingBloc>().add(
                            OnboardingEvent.goToPage(page),
                          );
                    },
                  ),
                ),

                // Navigation buttons
                _buildNavigationButtons(context, state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, OnboardingState state) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo Kuma
          Row(
            children: [
              Icon(
                Icons.auto_stories,
                color: theme.colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                'KUMA',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // Skip button removed - all users must complete onboarding
          const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context, OnboardingState state) {
    final theme = Theme.of(context);
    final bloc = context.read<OnboardingBloc>();

    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // Bouton Précédent
          if (state.currentPage > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => bloc.add(const OnboardingEvent.previousPage()),
                child: const Text('Précédent'),
              ),
            ),

          if (state.currentPage > 0) const SizedBox(width: 16),

          // Bouton Suivant/Terminer
          Expanded(
            flex: state.currentPage == 0 ? 1 : 2,
            child: ElevatedButton(
              onPressed: _canProceed(state)
                  ? () {
                      print(
                          'OnboardingPage: Button pressed on page ${state.currentPage}');
                      if (state.currentPage == 7) {
                        print('OnboardingPage: Completing onboarding...');
                        bloc.add(const OnboardingEvent.completeOnboarding());
                        // Navigation will be handled by state listener after completion
                      } else {
                        print('OnboardingPage: Going to next page...');
                        bloc.add(const OnboardingEvent.nextPage());
                      }
                    }
                  : null,
              child: state.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(state.currentPage == 7 ? 'Commencer' : 'Suivant'),
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed(OnboardingState state) {
    bool canProceed = false;
    switch (state.currentPage) {
      case 0: // Page de bienvenue
        canProceed = true;
        break;
      case 1: // Type d'utilisateur
        canProceed = state.userType.isNotEmpty;
        if (!canProceed)
          print('OnboardingPage: Cannot proceed - userType is empty');
        break;
      case 2: // Configuration enfants
        canProceed = state.userType != 'parent' || state.children.isNotEmpty;
        if (!canProceed)
          print(
              'OnboardingPage: Cannot proceed - parent with no children: userType=${state.userType}, children=${state.children.length}');
        break;
      case 3: // Objectif
        canProceed = state.primaryGoal.isNotEmpty;
        if (!canProceed)
          print('OnboardingPage: Cannot proceed - primaryGoal is empty');
        break;
      case 4: // Heure de lecture
        canProceed = state.preferredTime.isNotEmpty;
        if (!canProceed)
          print('OnboardingPage: Cannot proceed - preferredTime is empty');
        break;
      case 5: // Pays de départ
        canProceed = state.startingCountry.isNotEmpty;
        if (!canProceed)
          print('OnboardingPage: Cannot proceed - startingCountry is empty');
        break;
      case 6: // Récapitulatif
        canProceed = true;
        break;
      case 7: // Complet
        canProceed = !state.isLoading;
        if (!canProceed)
          print('OnboardingPage: Cannot proceed - still loading');
        break;
      default:
        canProceed = false;
        print(
            'OnboardingPage: Cannot proceed - invalid page ${state.currentPage}');
    }

    print('OnboardingPage: Page ${state.currentPage} canProceed: $canProceed');
    print(
        'OnboardingPage: State - userType: "${state.userType}", children: ${state.children.length}, goal: "${state.primaryGoal}", time: "${state.preferredTime}", country: "${state.startingCountry}"');

    return canProceed;
  }
}
