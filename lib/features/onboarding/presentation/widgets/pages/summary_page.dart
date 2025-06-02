import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kuma/features/onboarding/presentation/bloc/onboarding_bloc.dart';

class SummaryPage extends StatelessWidget {
  const SummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          
          Text(
            'Récapitulatif',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'Voici un résumé de votre configuration',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          
          const SizedBox(height: 32),
          
          Expanded(
            child: BlocBuilder<OnboardingBloc, OnboardingState>(
              builder: (context, state) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      _SummaryCard(
                        icon: Icons.person,
                        title: 'Type d\'utilisateur',
                        value: _getUserTypeLabel(state.userType),
                      ),
                      
                      if (state.children.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _SummaryCard(
                          icon: Icons.child_care,
                          title: 'Enfants (${state.children.length})',
                          value: state.children.map((c) => '${c.name} (${c.age} ans)').join(', '),
                        ),
                      ],
                      
                      const SizedBox(height: 16),
                      _SummaryCard(
                        icon: Icons.flag,
                        title: 'Objectif principal',
                        value: state.primaryGoal,
                      ),
                      
                      const SizedBox(height: 16),
                      _SummaryCard(
                        icon: Icons.schedule,
                        title: 'Heure préférée',
                        value: state.preferredTime,
                      ),
                      
                      const SizedBox(height: 16),
                      _SummaryCard(
                        icon: Icons.public,
                        title: 'Pays de départ',
                        value: state.startingCountry,
                        isHighlighted: true,
                      ),
                      
                      const SizedBox(height: 32),
                      
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Votre voyage commencera par ${state.startingCountry} et vous découvrirez ensuite tous les autres pays d\'Afrique !',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
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

  String _getUserTypeLabel(String userType) {
    switch (userType) {
      case 'parent':
        return 'Parent';
      case 'teacher':
        return 'Enseignant(e)';
      case 'child':
        return 'Enfant';
      default:
        return userType;
    }
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool isHighlighted;

  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.value,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: isHighlighted ? 4 : 2,
      color: isHighlighted 
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              icon,
              color: isHighlighted
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: isHighlighted
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isHighlighted
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}