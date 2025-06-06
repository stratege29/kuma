import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kuma/core/constants/app_constants.dart';
import 'package:kuma/core/di/injection_container.dart';
import 'package:kuma/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kuma/features/auth/presentation/widgets/auth_button.dart';
import 'package:kuma/features/auth/presentation/widgets/email_password_form.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AuthBloc>(),
      child: const LoginView(),
    );
  }
}

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool _showEmailForm = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            // Navigate based on onboarding completion
            if (state.user.settings.isOnboardingCompleted) {
              context.go(AppConstants.ROUTE_HOME);
            } else {
              context.go(AppConstants.ROUTE_ONBOARDING);
            }
          } else if (state is Error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is Loading;
          
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - 
                            MediaQuery.of(context).padding.top - 
                            MediaQuery.of(context).padding.bottom - 48,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const Spacer(),
                      
                      // Logo and title
                      _buildHeader(theme),
                      
                      const SizedBox(height: 48),
                      
                      // Authentication options
                      if (!_showEmailForm) ...[
                        _buildSocialSignInButtons(context, isLoading),
                        const SizedBox(height: 24),
                        _buildEmailSignInOption(context),
                      ] else ...[
                        EmailPasswordForm(
                          onSignIn: (email, password) {
                            context.read<AuthBloc>().add(
                              AuthEvent.signInWithEmailPassword(
                                email: email,
                                password: password,
                              ),
                            );
                          },
                          onSignUp: (email, password) {
                            context.read<AuthBloc>().add(
                              AuthEvent.signUpWithEmailPassword(
                                email: email,
                                password: password,
                              ),
                            );
                          },
                          onBack: () => setState(() => _showEmailForm = false),
                          isLoading: isLoading,
                        ),
                      ],
                      
                      const SizedBox(height: 32),
                      
                      const Spacer(),
                      
                      // Terms and privacy
                      _buildTermsAndPrivacy(theme),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.auto_stories,
            size: 40,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'KUMA',
          style: theme.textTheme.headlineLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Contes Africains',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Connectez-vous pour synchroniser\nvos données sur tous vos appareils',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSocialSignInButtons(BuildContext context, bool isLoading) {
    return Column(
      children: [
        // Google Sign-In
        AuthButton(
          onPressed: isLoading
              ? null
              : () {
                  context.read<AuthBloc>().add(const AuthEvent.signInWithGoogle());
                },
          icon: Icons.g_mobiledata,
          label: 'Continuer avec Google',
          backgroundColor: Colors.white,
          textColor: Colors.black87,
          borderColor: Colors.grey.shade300,
        ),
        
        const SizedBox(height: 12),
        
        // Apple Sign-In (only show on iOS)
        if (Theme.of(context).platform == TargetPlatform.iOS)
          AuthButton(
            onPressed: isLoading
                ? null
                : () {
                    context.read<AuthBloc>().add(const AuthEvent.signInWithApple());
                  },
            icon: Icons.apple,
            label: 'Continuer avec Apple',
            backgroundColor: Colors.black,
            textColor: Colors.white,
          ),
      ],
    );
  }

  Widget _buildEmailSignInOption(BuildContext context) {
    return AuthButton(
      onPressed: () => setState(() => _showEmailForm = true),
      icon: Icons.email_outlined,
      label: 'Continuer avec un email',
      backgroundColor: Theme.of(context).colorScheme.primary,
      textColor: Theme.of(context).colorScheme.onPrimary,
    );
  }


  Widget _buildTermsAndPrivacy(ThemeData theme) {
    return Text(
      'En continuant, vous acceptez nos\nConditions d\'utilisation et Politique de confidentialité',
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurface.withOpacity(0.5),
      ),
      textAlign: TextAlign.center,
    );
  }
}