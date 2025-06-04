import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kuma/core/constants/countries.dart';
import 'package:kuma/features/home/domain/entities/map_state.dart';
import 'package:kuma/features/home/presentation/bloc/home_bloc.dart';
import 'package:kuma/features/home/presentation/widgets/story_card_widget.dart';
import 'package:kuma/features/home/presentation/widgets/mini_map_overlay.dart';
import 'package:kuma/features/home/presentation/widgets/progress_header.dart';
import 'package:kuma/features/home/presentation/widgets/map_entry_animation.dart';
import 'package:kuma/features/home/presentation/widgets/user_profile_widget.dart';
import 'package:kuma/shared/domain/entities/story.dart';
import 'package:kuma/shared/domain/entities/user.dart';

class EnhancedAfricaMapWidget extends StatefulWidget {
  final AppUser user;
  
  const EnhancedAfricaMapWidget({super.key, required this.user});

  @override
  State<EnhancedAfricaMapWidget> createState() => _EnhancedAfricaMapWidgetState();
}

class _EnhancedAfricaMapWidgetState extends State<EnhancedAfricaMapWidget>
    with TickerProviderStateMixin {
  late final TransformationController _transformationController;
  late final AnimationController _entryAnimationController;
  late final AnimationController _routeAnimationController;
  
  final MapConfig _mapConfig = const MapConfig();
  bool _showEntryAnimation = true;
  Timer? _safetyTimer;
  
  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    
    _entryAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _routeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Listen for animation completion
    _entryAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _showEntryAnimation = false;
        });
      }
    });

    // Add a safety timeout to prevent getting stuck
    _safetyTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _showEntryAnimation) {
        setState(() {
          _showEntryAnimation = false;
        });
      }
    });

    // Start entry animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playEntryAnimation();
    });
  }

  @override
  void dispose() {
    _safetyTimer?.cancel();
    _transformationController.dispose();
    _entryAnimationController.dispose();
    _routeAnimationController.dispose();
    super.dispose();
  }

  void _playEntryAnimation() {
    final homeBloc = context.read<HomeBloc>();
    final currentCountry = homeBloc.state.currentCountry;
    
    // Only show entry animation if we have a valid country
    if (currentCountry.isNotEmpty) {
      _animateToCountry(currentCountry, showWelcomeMessage: true);
      _entryAnimationController.forward();
    } else {
      // If no country, hide the animation immediately
      setState(() {
        _showEntryAnimation = false;
      });
    }
    
    _routeAnimationController.repeat();
  }

  void _animateToCountry(String countryName, {bool showWelcomeMessage = false}) {
    final position = Countries.COUNTRY_POSITIONS[countryName];
    if (position == null) return;

    // Calculate target offset to center the country
    final screenSize = MediaQuery.of(context).size;
    final targetX = -(position['x']! * _mapConfig.mapWidth - screenSize.width / 2);
    final targetY = -(position['y']! * _mapConfig.mapHeight - screenSize.height / 2);

    final targetTransform = Matrix4.identity()
      ..translate(targetX, targetY);

    _transformationController.value = targetTransform;

    if (showWelcomeMessage) {
      _showWelcomeMessage(countryName);
    }
  }

  void _showWelcomeMessage(String countryName) {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.explore, color: Colors.white),
                const SizedBox(width: 8),
                Text('En route pour $countryName !'),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      listener: (context, state) {
        // If currentCountry changes and we don't have an initial country yet, play the animation
        if (state.currentCountry.isNotEmpty && !_showEntryAnimation && _entryAnimationController.status == AnimationStatus.dismissed) {
          setState(() {
            _showEntryAnimation = true;
          });
          _animateToCountry(state.currentCountry, showWelcomeMessage: true);
          _entryAnimationController.forward();
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: Stack(
            children: [
              // Main map view - full screen
              _buildMapView(state),
              
              // Minimal floating UI elements
              SafeArea(
                child: Column(
                  children: [
                    // Top row with minimal stats and user profile
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          // Progress pill on the left
                          _buildMinimalProgress(state),
                          const Spacer(),
                          // User profile widget
                          UserProfileWidget(user: widget.user),
                          const SizedBox(width: 8),
                          // Cauris counter
                          _buildMinimalCauris(state),
                        ],
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              
              // Mini map overlay - bottom left
              Positioned(
                bottom: 100,
                left: 16,
                child: MiniMapOverlay(
                  visibleArea: _getCurrentVisibleArea(),
                  currentCountry: state.currentCountry.isNotEmpty ? state.currentCountry : 'Senegal',
                  unlockedCountries: state.unlockedCountries,
                  onMapTap: _animateToCountry,
                ),
              ),
              
              // Entry animation overlay
              if (_showEntryAnimation && state.currentCountry.isNotEmpty)
                MapEntryAnimation(
                  targetCountry: state.currentCountry,
                  animationController: _entryAnimationController,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMapView(HomeState state) {
    return InteractiveViewer(
      transformationController: _transformationController,
      boundaryMargin: EdgeInsets.all(_mapConfig.boundaryMargin),
      minScale: _mapConfig.minScale,
      maxScale: _mapConfig.maxScale,
      constrained: false,
      child: Container(
        width: _mapConfig.mapWidth,
        height: _mapConfig.mapHeight,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF87CEEB), // Sky blue
              Color(0xFFF0E68C), // Khaki
              Color(0xFFDEB887), // Burlywood
            ],
          ),
        ),
        child: Stack(
          children: [
            // Map background
            _buildMapBackground(),
            
            // Routes layer
            _buildRoutesLayer(state),
            
            // Story cards layer
            _buildStoryCardsLayer(state),
          ],
        ),
      ),
    );
  }

  Widget _buildMapBackground() {
    return Container(
      width: _mapConfig.mapWidth,
      height: _mapConfig.mapHeight,
      child: CustomPaint(
        painter: AfricaMapPainter(),
      ),
    );
  }

  Widget _buildRoutesLayer(HomeState state) {
    return AnimatedBuilder(
      animation: _routeAnimationController,
      builder: (context, child) {
        return CustomPaint(
          size: Size(_mapConfig.mapWidth, _mapConfig.mapHeight),
          painter: RoutesPainter(
            unlockedCountries: state.unlockedCountries,
            animationValue: _routeAnimationController.value,
            mapSize: Size(_mapConfig.mapWidth, _mapConfig.mapHeight),
          ),
        );
      },
    );
  }

  Widget _buildStoryCardsLayer(HomeState state) {
    return Stack(
      children: Countries.TEST_COUNTRIES.map((countryName) {
        final position = Countries.COUNTRY_POSITIONS[countryName];
        if (position == null) return const SizedBox.shrink();

        final story = state.stories.firstWhere(
          (s) => s.country == countryName,
          orElse: () => Story.placeholder(countryName),
        );

        final storyState = _getStoryState(countryName, state);
        
        return Positioned(
          left: position['x']! * _mapConfig.mapWidth - 40,
          top: position['y']! * _mapConfig.mapHeight - 40,
          child: StoryCardWidget(
            story: story,
            state: storyState,
            onTap: () => _handleStoryTap(story, storyState),
          ),
        );
      }).toList(),
    );
  }

  String _getStoryState(String countryName, HomeState state) {
    if (state.completedCountries.contains(countryName)) {
      return Countries.STORY_STATE_COMPLETED;
    }
    
    if (state.unlockedCountries.contains(countryName)) {
      return Countries.STORY_STATE_UNLOCKED;
    }
    
    // Check if this is the user's starting country (should always be unlocked)
    if (countryName == state.currentCountry && state.currentCountry.isNotEmpty) {
      return Countries.STORY_STATE_UNLOCKED;
    }
    
    // Check if should be visible (based on progression and premium status)
    final countryIndex = Countries.TEST_COUNTRIES.indexOf(countryName);
    final unlockedCount = state.unlockedCountries.length;
    
    // First story in the order is always visible (fallback if no starting country set)
    if (countryIndex == 0 && state.currentCountry.isEmpty) {
      return Countries.STORY_STATE_UNLOCKED;
    }
    
    // Calculate how many stories should be visible based on time and premium status
    final daysSinceStart = _getDaysSinceStart(state);
    final isPremium = state.isPremium;
    
    int maxVisibleStories;
    if (isPremium) {
      maxVisibleStories = 1 + daysSinceStart; // 1 per day + initial
    } else {
      maxVisibleStories = 1 + (daysSinceStart ~/ 7); // 1 per week + initial
    }
    
    if (countryIndex < maxVisibleStories) {
      return Countries.STORY_STATE_VISIBLE_LOCKED;
    }
    
    return Countries.STORY_STATE_INVISIBLE;
  }

  int _getDaysSinceStart(HomeState state) {
    // Mock implementation - replace with actual user start date
    return DateTime.now().difference(DateTime.now().subtract(const Duration(days: 10))).inDays;
  }

  void _handleStoryTap(Story story, String storyState) {
    context.read<HomeBloc>().add(HomeEvent.selectStory(story));
  }

  Widget _buildMinimalProgress(HomeState state) {
    final theme = Theme.of(context);
    final totalStories = 54;
    final completedStories = state.completedCountries.length;
    final progressPercentage = (completedStories / totalStories * 100).round();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Circular progress indicator
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              value: progressPercentage / 100,
              strokeWidth: 3,
              backgroundColor: theme.colorScheme.outline.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$progressPercentage%',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalCauris(HomeState state) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '🐚',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 6),
          Text(
            '${state.caurisCount}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Rect _getCurrentVisibleArea() {
    final matrix = _transformationController.value;
    final screenSize = MediaQuery.of(context).size;
    
    return Rect.fromLTWH(
      -matrix.getTranslation().x / _mapConfig.mapWidth,
      -matrix.getTranslation().y / _mapConfig.mapHeight,
      screenSize.width / _mapConfig.mapWidth,
      screenSize.height / _mapConfig.mapHeight,
    );
  }
}

class AfricaMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF8B4513) // Brown for landmass
      ..style = PaintingStyle.fill;

    // Draw simplified Africa shape
    final path = Path();
    
    // Simplified Africa outline
    path.moveTo(size.width * 0.5, size.height * 0.1); // North (Mediterranean)
    path.lineTo(size.width * 0.8, size.height * 0.4); // East (Horn of Africa)
    path.lineTo(size.width * 0.9, size.height * 0.7); // Southeast
    path.lineTo(size.width * 0.6, size.height * 0.95); // South
    path.lineTo(size.width * 0.4, size.height * 0.95); // South
    path.lineTo(size.width * 0.1, size.height * 0.7); // Southwest
    path.lineTo(size.width * 0.05, size.height * 0.4); // West
    path.lineTo(size.width * 0.2, size.height * 0.15); // Northwest
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RoutesPainter extends CustomPainter {
  final List<String> unlockedCountries;
  final double animationValue;
  final Size mapSize;

  RoutesPainter({
    required this.unlockedCountries,
    required this.animationValue,
    required this.mapSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (unlockedCountries.length < 2) return;

    final paint = Paint()
      ..color = const Color(0xFFFFD700) // Gold route
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < unlockedCountries.length - 1; i++) {
      final fromPos = Countries.COUNTRY_POSITIONS[unlockedCountries[i]];
      final toPos = Countries.COUNTRY_POSITIONS[unlockedCountries[i + 1]];
      
      if (fromPos != null && toPos != null) {
        final from = Offset(fromPos['x']! * size.width, fromPos['y']! * size.height);
        final to = Offset(toPos['x']! * size.width, toPos['y']! * size.height);
        
        _drawAnimatedDottedLine(canvas, from, to, paint);
      }
    }
  }

  void _drawAnimatedDottedLine(Canvas canvas, Offset from, Offset to, Paint paint) {
    const dashLength = 10.0;
    const gapLength = 5.0;
    
    final distance = (to - from).distance;
    final direction = (to - from) / distance;
    
    double currentDistance = 0;
    while (currentDistance < distance) {
      final dashEnd = currentDistance + dashLength;
      final actualDashEnd = dashEnd > distance ? distance : dashEnd;
      
      final dashStart = from + direction * currentDistance;
      final dashEndPoint = from + direction * actualDashEnd;
      
      // Animate the dash appearance
      final progress = (animationValue + currentDistance / distance) % 1.0;
      paint.color = Color.lerp(
        const Color(0xFFFFD700),
        const Color(0xFFFF6B35),
        progress,
      )!;
      
      canvas.drawLine(dashStart, dashEndPoint, paint);
      
      currentDistance += dashLength + gapLength;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}