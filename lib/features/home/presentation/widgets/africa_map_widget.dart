import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kuma/core/constants/countries.dart';
import 'package:kuma/features/home/presentation/bloc/home_bloc.dart';
import 'package:kuma/features/home/presentation/widgets/story_card_widget.dart';

class AfricaMapWidget extends StatefulWidget {
  const AfricaMapWidget({super.key});

  @override
  State<AfricaMapWidget> createState() => _AfricaMapWidgetState();
}

class _AfricaMapWidgetState extends State<AfricaMapWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  final TransformationController _transformationController = TransformationController();

  @override
  void initState() {
    super.initState();
    _initAnimations();
    
    // Animation d'entrée sur le pays de départ après un petit délai
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _animateToStartingCountry();
      });
    });
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  void _animateToStartingCountry() {
    // Coordonnées du Sénégal pour l'animation d'entrée
    final senegalPosition = Countries.COUNTRY_POSITIONS['Senegal'];
    if (senegalPosition != null) {
      final screenSize = MediaQuery.of(context).size;
      
      // Calculer la transformation pour centrer sur le Sénégal avec zoom
      final targetX = -(senegalPosition['x']! * screenSize.width * 1.5) + screenSize.width / 2;
      final targetY = -(senegalPosition['y']! * screenSize.height * 1.5) + screenSize.height / 2;
      
      final matrix = Matrix4.identity()
        ..translate(targetX, targetY)
        ..scale(1.5);
      
      _transformationController.value = matrix;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (state.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64),
                const SizedBox(height: 16),
                Text(state.error!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    final bloc = context.read<HomeBloc>();
                    context.read<HomeBloc>().add(
                          HomeEvent.loadStories(
                              startingCountry: bloc.state.currentCountry.isNotEmpty
                                  ? bloc.state.currentCountry
                                  : null),
                        );
                  },
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }
        
        return InteractiveViewer(
          transformationController: _transformationController,
          panEnabled: true,
          scaleEnabled: false, // Désactiver le zoom manuel
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue.shade50,
                  Colors.blue.shade100,
                ],
              ),
            ),
            child: Stack(
              children: [
                // Carte de l'Afrique (placeholder)
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 1.2,
                    height: MediaQuery.of(context).size.height * 1.4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'AFRIQUE',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Story Cards positionnées sur la carte
                ...state.stories.map((story) {
                  final position = Countries.COUNTRY_POSITIONS[story.country];
                  if (position == null) return const SizedBox.shrink();
                  
                  return Positioned(
                    left: position['x']! * MediaQuery.of(context).size.width * 1.2,
                    top: position['y']! * MediaQuery.of(context).size.height * 1.4,
                    child: StoryCardWidget(
                      story: story,
                      isUnlocked: state.unlockedCountries.contains(story.country),
                      onTap: () {
                        if (state.unlockedCountries.contains(story.country)) {
                          context.read<HomeBloc>().add(HomeEvent.selectStory(story));
                        }
                      },
                    ),
                  );
                }),
                
                // Routes animées entre pays débloqués (simple placeholder)
                ...state.unlockedCountries.asMap().entries.map((entry) {
                  final index = entry.key;
                  final country = entry.value;
                  
                  if (index == 0) return const SizedBox.shrink();
                  
                  final prevCountry = state.unlockedCountries[index - 1];
                  final currentPos = Countries.COUNTRY_POSITIONS[country];
                  final prevPos = Countries.COUNTRY_POSITIONS[prevCountry];
                  
                  if (currentPos == null || prevPos == null) {
                    return const SizedBox.shrink();
                  }
                  
                  return Positioned(
                    left: prevPos['x']! * MediaQuery.of(context).size.width * 1.2,
                    top: prevPos['y']! * MediaQuery.of(context).size.height * 1.4,
                    child: CustomPaint(
                      size: Size(
                        (currentPos['x']! - prevPos['x']!) * MediaQuery.of(context).size.width * 1.2,
                        (currentPos['y']! - prevPos['y']!) * MediaQuery.of(context).size.height * 1.4,
                      ),
                      painter: RoutePainter(theme.colorScheme.primary),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}

class RoutePainter extends CustomPainter {
  final Color color;

  RoutePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.6)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, 0);
    path.quadraticBezierTo(size.width / 2, size.height / 2, size.width, size.height);
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}