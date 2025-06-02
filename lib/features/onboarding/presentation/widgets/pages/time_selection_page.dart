import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kuma/core/constants/app_constants.dart';
import 'package:kuma/features/onboarding/presentation/bloc/onboarding_bloc.dart';

class TimeSelectionPage extends StatelessWidget {
  const TimeSelectionPage({super.key});

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
            'Quand préférez-vous lire ?',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'Nous pourrons vous envoyer des rappels au bon moment',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          
          const SizedBox(height: 40),
          
          Expanded(
            child: BlocBuilder<OnboardingBloc, OnboardingState>(
              builder: (context, state) {
                return ListView.separated(
                  itemCount: AppConstants.READING_TIMES.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final time = AppConstants.READING_TIMES[index];
                    final isSelected = state.preferredTime == time;
                    
                    return Card(
                      elevation: isSelected ? 8 : 2,
                      color: isSelected
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.surface,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          context.read<OnboardingBloc>().add(
                            OnboardingEvent.selectTime(time),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                _getTimeIcon(index),
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  time,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    color: isSelected
                                        ? theme.colorScheme.onPrimaryContainer
                                        : theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color: theme.colorScheme.primary,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTimeIcon(int index) {
    switch (index) {
      case 0:
        return Icons.wb_sunny;
      case 1:
        return Icons.wb_sunny_outlined;
      case 2:
        return Icons.wb_twilight;
      case 3:
        return Icons.bedtime;
      default:
        return Icons.schedule;
    }
  }
}