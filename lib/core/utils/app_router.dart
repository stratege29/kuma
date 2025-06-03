import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kuma/core/constants/app_constants.dart';

// Import pages as we create them
import 'package:kuma/features/auth/presentation/widgets/auth_wrapper.dart';
import 'package:kuma/features/onboarding/presentation/pages/splash_page.dart';
import 'package:kuma/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:kuma/features/home/presentation/pages/home_page.dart';
import 'package:kuma/features/story/presentation/pages/reading_page.dart';
import 'package:kuma/features/story/presentation/pages/listening_page.dart';
import 'package:kuma/features/quiz/presentation/pages/quiz_page.dart';
import 'package:kuma/features/quiz/presentation/pages/quiz_result_page.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  
  static GoRouter get router => _router;
  
  static final _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppConstants.ROUTE_SPLASH,
    routes: [
      GoRoute(
        path: AppConstants.ROUTE_SPLASH,
        name: 'splash',
        builder: (context, state) => const AuthWrapper(),
      ),
      GoRoute(
        path: AppConstants.ROUTE_ONBOARDING,
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppConstants.ROUTE_HOME,
        name: 'home',
        builder: (context, state) {
          final startingCountry = state.extra as String?;
          return HomePage(startingCountry: startingCountry);
        },
      ),
      GoRoute(
        path: '${AppConstants.ROUTE_READING}/:storyId',
        name: 'reading',
        builder: (context, state) {
          final storyId = state.pathParameters['storyId']!;
          return ReadingPage(storyId: storyId);
        },
      ),
      GoRoute(
        path: '${AppConstants.ROUTE_LISTENING}/:storyId',
        name: 'listening',
        builder: (context, state) {
          final storyId = state.pathParameters['storyId']!;
          return ListeningPage(storyId: storyId);
        },
      ),
      GoRoute(
        path: '${AppConstants.ROUTE_QUIZ}/:storyId',
        name: 'quiz',
        builder: (context, state) {
          final storyId = state.pathParameters['storyId']!;
          return QuizPage(storyId: storyId);
        },
      ),
      GoRoute(
        path: '${AppConstants.ROUTE_QUIZ_RESULT}/:storyId',
        name: 'quiz-result',
        builder: (context, state) {
          final storyId = state.pathParameters['storyId']!;
          return QuizResultPage(storyId: storyId);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64),
            const SizedBox(height: 16),
            Text('Page non trouvée: ${state.uri}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppConstants.ROUTE_HOME),
              child: const Text('Retour à l\'accueil'),
            ),
          ],
        ),
      ),
    ),
  );
}