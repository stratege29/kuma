import 'package:flutter/material.dart';
import 'package:kuma/core/constants/countries.dart';
import 'package:kuma/shared/domain/entities/story.dart';

class StoryCardWidget extends StatefulWidget {
  final Story story;
  final String state; // invisible, visible_locked, unlocked, completed
  final VoidCallback onTap;

  const StoryCardWidget({
    super.key,
    required this.story,
    required this.state,
    required this.onTap,
  });

  @override
  State<StoryCardWidget> createState() => _StoryCardWidgetState();
}

class _StoryCardWidgetState extends State<StoryCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    
    // Start pulse animation for unlocked stories
    if (widget.state == Countries.STORY_STATE_UNLOCKED) {
      _animationController.repeat(reverse: true);
    }
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(StoryCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update animation based on state
    if (widget.state == Countries.STORY_STATE_UNLOCKED) {
      _animationController.repeat(reverse: true);
    } else {
      _animationController.stop();
      _animationController.reset();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Don't render invisible stories
    if (widget.state == Countries.STORY_STATE_INVISIBLE) {
      return const SizedBox.shrink();
    }
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.state == Countries.STORY_STATE_UNLOCKED ? _pulseAnimation.value : 1.0,
          child: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getCardColor(theme),
                border: Border.all(
                  color: _getBorderColor(theme),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _getCardColor(theme).withOpacity(0.3),
                    blurRadius: widget.state == Countries.STORY_STATE_UNLOCKED ? 15 : 8,
                    spreadRadius: widget.state == Countries.STORY_STATE_UNLOCKED ? 3 : 1,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Main icon
                  Center(
                    child: Icon(
                      _getCardIcon(),
                      color: _getIconColor(theme),
                      size: 32,
                    ),
                  ),
                  
                  // Completion badge
                  if (widget.state == Countries.STORY_STATE_COMPLETED)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  
                  // Lock overlay for locked stories
                  if (widget.state == Countries.STORY_STATE_VISIBLE_LOCKED)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.lock,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),

                  // Country flag emoji (if available)
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Text(
                      _getCountryEmoji(),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getCardColor(ThemeData theme) {
    switch (widget.state) {
      case Countries.STORY_STATE_VISIBLE_LOCKED:
        return theme.colorScheme.surface;
      case Countries.STORY_STATE_UNLOCKED:
        return theme.colorScheme.primary;
      case Countries.STORY_STATE_COMPLETED:
        return theme.colorScheme.secondary;
      default:
        return Colors.transparent;
    }
  }

  Color _getBorderColor(ThemeData theme) {
    switch (widget.state) {
      case Countries.STORY_STATE_VISIBLE_LOCKED:
        return theme.colorScheme.outline;
      case Countries.STORY_STATE_UNLOCKED:
        return theme.colorScheme.primary;
      case Countries.STORY_STATE_COMPLETED:
        return theme.colorScheme.secondary;
      default:
        return Colors.transparent;
    }
  }

  Color _getIconColor(ThemeData theme) {
    switch (widget.state) {
      case Countries.STORY_STATE_VISIBLE_LOCKED:
        return theme.colorScheme.onSurface.withOpacity(0.5);
      case Countries.STORY_STATE_UNLOCKED:
        return Colors.white;
      case Countries.STORY_STATE_COMPLETED:
        return Colors.white;
      default:
        return Colors.transparent;
    }
  }

  IconData _getCardIcon() {
    switch (widget.state) {
      case Countries.STORY_STATE_VISIBLE_LOCKED:
        return Icons.auto_stories_outlined;
      case Countries.STORY_STATE_UNLOCKED:
        return Icons.auto_stories;
      case Countries.STORY_STATE_COMPLETED:
        return Icons.auto_stories;
      default:
        return Icons.circle;
    }
  }

  String _getCountryEmoji() {
    // Simple mapping of some countries to their flag emojis
    const countryFlags = {
      'Cote d\'Ivoire': '🇨🇮',
      'Ghana': '🇬🇭',
      'Nigeria': '🇳🇬',
      'Cameroon': '🇨🇲',
      'Kenya': '🇰🇪',
      'Ethiopia': '🇪🇹',
      'Egypt': '🇪🇬',
      'Morocco': '🇲🇦',
      'Senegal': '🇸🇳',
      'South Africa': '🇿🇦',
    };
    
    return countryFlags[widget.story.country] ?? '🌍';
  }
}

/// Placeholder widget for "coming soon" stories
class ComingSoonStoryCard extends StatelessWidget {
  final VoidCallback? onTap;

  const ComingSoonStoryCard({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.surface.withOpacity(0.3),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.schedule,
              color: theme.colorScheme.onSurface.withOpacity(0.4),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              'Bientôt',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.4),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}