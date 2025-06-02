import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kuma/core/constants/app_constants.dart';
import 'package:kuma/features/onboarding/presentation/bloc/onboarding_bloc.dart';

class UserTypeSelectionPage extends StatelessWidget {
  const UserTypeSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          
          // Titre principal
          Text(
            'Qui êtes-vous ?',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Sous-titre
          Text(
            'Choisissez votre profil pour personnaliser votre expérience Kuma',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Options de type d'utilisateur
          Expanded(
            child: BlocBuilder<OnboardingBloc, OnboardingState>(
              builder: (context, state) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      _UserTypeOption(
                        icon: Icons.family_restroom,
                        title: 'Parent',
                        subtitle: 'Je lis avec mes enfants et gère leurs profils',
                        value: AppConstants.USER_TYPE_PARENT,
                        selectedValue: state.userType,
                        onTap: (value) {
                          context.read<OnboardingBloc>().add(
                            OnboardingEvent.selectUserType(value),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _UserTypeOption(
                        icon: Icons.school,
                        title: 'Enseignant(e)',
                        subtitle: 'J\'utilise Kuma dans ma classe ou pour l\'éducation',
                        value: AppConstants.USER_TYPE_TEACHER,
                        selectedValue: state.userType,
                        onTap: (value) {
                          context.read<OnboardingBloc>().add(
                            OnboardingEvent.selectUserType(value),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _UserTypeOption(
                        icon: Icons.child_care,
                        title: 'Enfant',
                        subtitle: 'Je veux découvrir les contes africains',
                        value: AppConstants.USER_TYPE_CHILD,
                        selectedValue: state.userType,
                        onTap: (value) {
                          context.read<OnboardingBloc>().add(
                            OnboardingEvent.selectUserType(value),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _UserTypeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String value;
  final String selectedValue;
  final Function(String) onTap;

  const _UserTypeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.selectedValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = value == selectedValue;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Card(
        elevation: isSelected ? 8 : 2,
        color: isSelected
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surface,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => onTap(value),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Icône
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected
                        ? Colors.white
                        : theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Texte
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? theme.colorScheme.onPrimaryContainer
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isSelected
                              ? theme.colorScheme.onPrimaryContainer.withOpacity(0.8)
                              : theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Indicateur de sélection
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}