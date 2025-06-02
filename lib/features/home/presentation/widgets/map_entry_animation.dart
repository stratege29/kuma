import 'package:flutter/material.dart';

class MapEntryAnimation extends StatefulWidget {
  final String targetCountry;
  final AnimationController animationController;

  const MapEntryAnimation({
    super.key,
    required this.targetCountry,
    required this.animationController,
  });

  @override
  State<MapEntryAnimation> createState() => _MapEntryAnimationState();
}

class _MapEntryAnimationState extends State<MapEntryAnimation> {
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: widget.animationController,
      curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: widget.animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: widget.animationController,
      curve: const Interval(0.2, 0.7, curve: Curves.easeOutBack),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: widget.animationController,
      builder: (context, child) {
        return Container(
          width: screenSize.width,
          height: screenSize.height,
          color: theme.colorScheme.surface.withOpacity(
            _fadeAnimation.value * 0.95,
          ),
          child: Center(
            child: SlideTransition(
              position: _slideAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildWelcomeCard(theme),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeCard(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated flag or country emoji
          AnimatedBuilder(
            animation: widget.animationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _scaleAnimation.value * 0.1,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.explore,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Welcome message
          Text(
            'En route pour',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Country name with animation
          AnimatedBuilder(
            animation: widget.animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_scaleAnimation.value * 0.1),
                child: Text(
                  widget.targetCountry,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Subtitle
          Text(
            'Découvrez les merveilleux contes de ce pays !',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Loading indicator
          AnimatedBuilder(
            animation: widget.animationController,
            builder: (context, child) {
              return SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  value: widget.animationController.value,
                  strokeWidth: 3,
                  backgroundColor: theme.colorScheme.outline.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class CountryIntroAnimation extends StatefulWidget {
  final String countryName;
  final String countryFlag;
  final VoidCallback onComplete;

  const CountryIntroAnimation({
    super.key,
    required this.countryName,
    required this.countryFlag,
    required this.onComplete,
  });

  @override
  State<CountryIntroAnimation> createState() => _CountryIntroAnimationState();
}

class _CountryIntroAnimationState extends State<CountryIntroAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flagScaleAnimation;
  late Animation<double> _textSlideAnimation;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _flagScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
      ),
    );

    _textSlideAnimation = Tween<double>(begin: 100.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
      ),
    );

    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        widget.onComplete();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.colorScheme.primary.withOpacity(_backgroundAnimation.value * 0.9),
                theme.colorScheme.secondary.withOpacity(_backgroundAnimation.value * 0.8),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Flag animation
                Transform.scale(
                  scale: _flagScaleAnimation.value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        widget.countryFlag,
                        style: const TextStyle(fontSize: 60),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Text animation
                Transform.translate(
                  offset: Offset(0, _textSlideAnimation.value),
                  child: Opacity(
                    opacity: _controller.value,
                    child: Column(
                      children: [
                        Text(
                          'Bienvenue en',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.countryName,
                          style: theme.textTheme.headlineLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}