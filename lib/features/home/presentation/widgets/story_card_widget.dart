import 'package:flutter/material.dart';
import 'package:kuma/shared/domain/entities/story.dart';

enum StoryCardState {
  invisible,
  locked,
  unlocked,
  completed,
}

class StoryCardWidget extends StatefulWidget {
  final Story story;
  final bool isUnlocked;
  final VoidCallback onTap;

  const StoryCardWidget({
    super.key,
    required this.story,
    required this.isUnlocked,
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
    
    // Démarrer l'animation de pulsation si c'est la carte active
    if (widget.isUnlocked && !widget.story.isCompleted) {
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
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(StoryCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Mettre à jour l'animation selon l'état
    if (widget.isUnlocked && !widget.story.isCompleted) {
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

  StoryCardState get _cardState {
    if (!widget.isUnlocked) {
      return StoryCardState.locked;
    } else if (widget.story.isCompleted) {
      return StoryCardState.completed;
    } else {
      return StoryCardState.unlocked;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = _cardState;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: state == StoryCardState.unlocked ? _pulseAnimation.value : 1.0,
          child: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getCardColor(state, theme),
                border: Border.all(
                  color: _getBorderColor(state, theme),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _getCardColor(state, theme).withOpacity(0.3),
                    blurRadius: state == StoryCardState.unlocked ? 15 : 8,
                    spreadRadius: state == StoryCardState.unlocked ? 3 : 1,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Icône principale
                  Center(
                    child: Icon(
                      _getCardIcon(state),
                      color: _getIconColor(state, theme),
                      size: 24,
                    ),
                  ),
                  
                  // Badge de completion
                  if (state == StoryCardState.completed)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                  
                  // Icône de verrouillage
                  if (state == StoryCardState.locked)
                    Positioned(
                      bottom: -2,
                      right: -2,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.lock,
                          color: Colors.white,
                          size: 12,
                        ),
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

  Color _getCardColor(StoryCardState state, ThemeData theme) {
    switch (state) {
      case StoryCardState.invisible:
        return Colors.transparent;
      case StoryCardState.locked:
        return theme.colorScheme.surface;
      case StoryCardState.unlocked:
        return theme.colorScheme.primary;
      case StoryCardState.completed:
        return theme.colorScheme.secondary;
    }
  }

  Color _getBorderColor(StoryCardState state, ThemeData theme) {
    switch (state) {
      case StoryCardState.invisible:
        return Colors.transparent;
      case StoryCardState.locked:
        return theme.colorScheme.outline;
      case StoryCardState.unlocked:
        return theme.colorScheme.primary;
      case StoryCardState.completed:
        return theme.colorScheme.secondary;
    }
  }

  Color _getIconColor(StoryCardState state, ThemeData theme) {
    switch (state) {
      case StoryCardState.invisible:
        return Colors.transparent;
      case StoryCardState.locked:
        return theme.colorScheme.onSurface.withOpacity(0.5);
      case StoryCardState.unlocked:
        return Colors.white;
      case StoryCardState.completed:
        return Colors.white;
    }
  }

  IconData _getCardIcon(StoryCardState state) {
    switch (state) {
      case StoryCardState.invisible:
        return Icons.circle;
      case StoryCardState.locked:
        return Icons.auto_stories_outlined;
      case StoryCardState.unlocked:
        return Icons.auto_stories;
      case StoryCardState.completed:
        return Icons.auto_stories;
    }
  }
}