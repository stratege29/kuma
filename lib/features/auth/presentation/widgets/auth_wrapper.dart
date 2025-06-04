import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kuma/core/di/injection_container.dart';
import 'package:kuma/core/storage/device_preferences.dart';
import 'package:kuma/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kuma/features/auth/presentation/pages/login_page.dart';
import 'package:kuma/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:kuma/features/home/presentation/pages/home_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AuthBloc>()..add(const AuthEvent.checkAuthStatus()),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          print('AuthWrapper state change: $state');
          // Remove automatic retry to prevent Firebase rate limiting
        },
        builder: (context, state) {
          print('AuthWrapper building with state: $state');
          return state.when(
            initial: () {
              print('AuthWrapper: Initial state');
              return const _LoadingScreen();
            },
            loading: () {
              print('AuthWrapper: Loading state');
              return const _LoadingScreen();
            },
            authenticated: (user) {
              print('AuthWrapper: Authenticated with user: ${user.id}');
              // Check device preferences for onboarding completion
              return FutureBuilder<bool>(
                future: DevicePreferences.getOnboardingCompleted(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const _LoadingScreen();
                  }
                  
                  final deviceOnboardingCompleted = snapshot.data ?? false;
                  final userOnboardingCompleted = user.settings.isOnboardingCompleted;
                  
                  // Use device preferences OR user settings (in case of migration)
                  final isOnboardingCompleted = deviceOnboardingCompleted || userOnboardingCompleted;
                  
                  if (isOnboardingCompleted) {
                    print('AuthWrapper: Onboarding completed, navigating to HomePage');
                    return HomePage(user: user);
                  } else {
                    print('AuthWrapper: Onboarding not completed, navigating to OnboardingPage');
                    return const OnboardingPage();
                  }
                },
              );
            },
            unauthenticated: (message) {
              print('AuthWrapper: Unauthenticated, showing login screen: $message');
              // Show login screen instead of auto anonymous sign-in
              return const LoginPage();
            },
            error: (message) {
              print('AuthWrapper: Error state: $message');
              // Check if it's a rate limiting error
              if (message.contains('too-many-requests')) {
                return _RateLimitScreen(
                  onContinue: () {
                    // Navigate to login page instead of retrying
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                );
              }
              return _ErrorScreen(
                message: message,
                onRetry: () {
                  print('AuthWrapper: Retrying auth check');
                  context.read<AuthBloc>().add(const AuthEvent.checkAuthStatus());
                },
              );
            },
            passwordResetEmailSent: () {
              print('AuthWrapper: Password reset email sent');
              return const _LoadingScreen();
            },
          );
        },
      ),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_stories,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'KUMA',
              style: theme.textTheme.headlineLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Contes Africains',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 32),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
            const SizedBox(height: 16),
            Text(
              'Chargement...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorScreen({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                'Erreur de connexion',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RateLimitScreen extends StatelessWidget {
  final VoidCallback onContinue;

  const _RateLimitScreen({
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.hourglass_empty,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Trop de tentatives',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Firebase a temporairement bloqué les connexions pour éviter la surcharge. Vous pouvez continuer avec un compte utilisateur.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onContinue,
                icon: const Icon(Icons.login),
                label: const Text('Se connecter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}