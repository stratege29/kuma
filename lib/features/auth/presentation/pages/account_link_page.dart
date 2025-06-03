import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kuma/core/di/injection_container.dart';
import 'package:kuma/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kuma/features/auth/presentation/widgets/auth_button.dart';
import 'package:kuma/features/auth/presentation/widgets/email_password_form.dart';

class AccountLinkPage extends StatelessWidget {
  const AccountLinkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AuthBloc>(),
      child: const AccountLinkView(),
    );
  }
}

class AccountLinkView extends StatefulWidget {
  const AccountLinkView({super.key});

  @override
  State<AccountLinkView> createState() => _AccountLinkViewState();
}

class _AccountLinkViewState extends State<AccountLinkView> {
  bool _showEmailForm = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Lier votre compte'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Compte lié avec succès !'),
                backgroundColor: theme.colorScheme.primary,
              ),
            );
            context.pop();
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
          
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Header with benefits
                _buildHeader(theme),
                
                const SizedBox(height: 32),
                
                // Link options
                if (!_showEmailForm) ...[
                  _buildLinkingOptions(context, isLoading),
                ] else ...[
                  EmailPasswordForm(
                    onSignIn: (email, password) {
                      context.read<AuthBloc>().add(
                        AuthEvent.linkWithEmailPassword(
                          email: email,
                          password: password,
                        ),
                      );
                    },
                    onSignUp: (email, password) {
                      context.read<AuthBloc>().add(
                        AuthEvent.linkWithEmailPassword(
                          email: email,
                          password: password,
                        ),
                      );
                    },
                    onBack: () => setState(() => _showEmailForm = false),
                    isLoading: isLoading,
                  ),
                ],
                
                const Spacer(),
                
                // Skip for now option
                _buildSkipOption(context),
              ],
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
            color: theme.colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.link,
            size: 40,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Sauvegardez vos données',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Liez votre compte pour synchroniser vos progrès sur tous vos appareils et ne jamais les perdre.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        
        // Benefits list
        _buildBenefitsList(theme),
      ],
    );
  }

  Widget _buildBenefitsList(ThemeData theme) {
    final benefits = [
      {'icon': Icons.cloud_sync, 'text': 'Synchronisation sur tous vos appareils'},
      {'icon': Icons.backup, 'text': 'Sauvegarde automatique de vos progrès'},
      {'icon': Icons.family_restroom, 'text': 'Partage avec la famille'},
      {'icon': Icons.security, 'text': 'Données sécurisées'},
    ];

    return Column(
      children: benefits.map((benefit) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(
                benefit['icon'] as IconData,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  benefit['text'] as String,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLinkingOptions(BuildContext context, bool isLoading) {
    return Column(
      children: [
        // Google Link
        AuthButton(
          onPressed: isLoading
              ? null
              : () {
                  context.read<AuthBloc>().add(const AuthEvent.linkWithGoogle());
                },
          icon: Icons.g_mobiledata,
          label: 'Lier avec Google',
          backgroundColor: Colors.white,
          textColor: Colors.black87,
          borderColor: Colors.grey.shade300,
        ),
        
        const SizedBox(height: 12),
        
        // Apple Link (only show on iOS)
        if (Theme.of(context).platform == TargetPlatform.iOS) ...[
          AuthButton(
            onPressed: isLoading
                ? null
                : () {
                    context.read<AuthBloc>().add(const AuthEvent.linkWithApple());
                  },
            icon: Icons.apple,
            label: 'Lier avec Apple',
            backgroundColor: Colors.black,
            textColor: Colors.white,
          ),
          const SizedBox(height: 12),
        ],
        
        // Email Link
        AuthButton(
          onPressed: isLoading
              ? null
              : () => setState(() => _showEmailForm = true),
          icon: Icons.email_outlined,
          label: 'Lier avec un email',
          backgroundColor: Theme.of(context).colorScheme.primary,
          textColor: Theme.of(context).colorScheme.onPrimary,
        ),
      ],
    );
  }

  Widget _buildSkipOption(BuildContext context) {
    return Column(
      children: [
        Text(
          'Vous pourrez toujours lier votre compte plus tard dans les paramètres.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => context.pop(),
          child: Text(
            'Plus tard',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}