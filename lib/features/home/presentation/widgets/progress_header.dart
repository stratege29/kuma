import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kuma/features/home/presentation/bloc/home_bloc.dart';
import 'package:kuma/features/home/domain/entities/map_state.dart';

class ProgressHeader extends StatelessWidget {
  const ProgressHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final totalStories = 54; // Total number of African countries
        final completedStories = state.completedCountries.length;
        final progressPercentage = ProgressLevels.getProgressPercentage(completedStories, totalStories);
        final currentLevel = ProgressLevels.getLevelForProgress(progressPercentage);
        
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top row: Title and Cauris
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Voyage à travers l\'Afrique',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currentLevel,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Cauris counter
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '🐚', // Cauri shell emoji
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${state.caurisCount}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Progress bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$progressPercentage% complété',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        Text(
                          '$completedStories/$totalStories pays',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Animated progress bar
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeInOut,
                      tween: Tween(begin: 0, end: progressPercentage / 100),
                      builder: (context, value, child) {
                        return Stack(
                          children: [
                            Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.outline.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            Container(
                              height: 8,
                              width: MediaQuery.of(context).size.width * 0.7 * value,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    theme.colorScheme.primary,
                                    theme.colorScheme.secondary,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
                
                // Next level preview (if not at max level)
                if (progressPercentage < 100) ...[
                  const SizedBox(height: 12),
                  _buildNextLevelPreview(theme, progressPercentage),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNextLevelPreview(ThemeData theme, int currentProgress) {
    // Find next level threshold
    int nextThreshold = 100;
    for (int threshold in ProgressLevels.LEVELS.keys) {
      if (threshold > currentProgress) {
        nextThreshold = threshold;
        break;
      }
    }
    
    final nextLevel = ProgressLevels.LEVELS[nextThreshold] ?? "Légende d'Afrique";
    final storiesNeeded = ((nextThreshold - currentProgress) * 54 / 100).ceil();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.star_outline,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Plus que $storiesNeeded histoires pour devenir "$nextLevel"',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedCauriCounter extends StatefulWidget {
  final int count;
  final Duration duration;

  const AnimatedCauriCounter({
    super.key,
    required this.count,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  State<AnimatedCauriCounter> createState() => _AnimatedCauriCounterState();
}

class _AnimatedCauriCounterState extends State<AnimatedCauriCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _displayedCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(begin: 0, end: widget.count.toDouble())
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    
    _animation.addListener(() {
      setState(() {
        _displayedCount = _animation.value.round();
      });
    });
    
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCauriCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.count != widget.count) {
      _animation = Tween<double>(
        begin: _displayedCount.toDouble(),
        end: widget.count.toDouble(),
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '$_displayedCount',
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    );
  }
}