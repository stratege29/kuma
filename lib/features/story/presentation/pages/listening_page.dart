import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kuma/core/constants/app_constants.dart';
import 'package:kuma/shared/domain/entities/story.dart';

class ListeningPage extends StatefulWidget {
  final String storyId;

  const ListeningPage({
    super.key,
    required this.storyId,
  });

  @override
  State<ListeningPage> createState() => _ListeningPageState();
}

class _ListeningPageState extends State<ListeningPage>
    with TickerProviderStateMixin {
  late AnimationController _waveAnimationController;
  late AnimationController _progressAnimationController;
  
  bool _isPlaying = false;
  bool _isLoading = true;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = const Duration(minutes: 5); // Mock duration
  Story? _story;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadStory();
  }

  void _initAnimations() {
    _waveAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _progressAnimationController = AnimationController(
      duration: _totalDuration,
      vsync: this,
    );
  }

  void _loadStory() {
    // Simuler le chargement de l'histoire
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _story = _getMockStory();
        _isLoading = false;
      });
    });
  }

  Story _getMockStory() {
    return Story(
      id: widget.storyId,
      title: 'Leuk le lièvre et Bouki l\'hyène',
      country: 'Senegal',
      countryCode: 'SEN',
      content: {'fr': 'Contenu de l\'histoire...'},
      imageUrl: 'placeholder_sen_1.jpg',
      audioUrl: 'placeholder_sen_1.mp3',
      estimatedReadingTime: 4,
      estimatedAudioDuration: 5,
      values: ['Sagesse', 'Prudence', 'Amitié'],
      quizQuestions: [],
      metadata: StoryMetadata(
        author: 'Conte traditionnel sénégalais',
        origin: 'Senegal',
        moralLesson: 'La ruse ne doit pas nuire à l\'amitié',
        keywords: ['lièvre', 'hyène', 'sagesse'],
        ageGroup: '6-12 ans',
        difficulty: 'Facile',
      ),
      isUnlocked: true,
    );
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });

    if (_isPlaying) {
      _waveAnimationController.repeat();
      _progressAnimationController.forward();
      _startProgressSimulation();
    } else {
      _waveAnimationController.stop();
      _progressAnimationController.stop();
    }
  }

  void _startProgressSimulation() {
    // Simulation de la progression audio
    if (_isPlaying) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_isPlaying && mounted) {
          setState(() {
            _currentPosition = _currentPosition + const Duration(milliseconds: 100);
            
            // Auto-finish when audio ends
            if (_currentPosition >= _totalDuration) {
              _onAudioComplete();
            } else {
              _startProgressSimulation();
            }
          });
        }
      });
    }
  }

  void _onAudioComplete() {
    setState(() {
      _isPlaying = false;
      _currentPosition = _totalDuration;
    });
    
    _waveAnimationController.stop();
    _progressAnimationController.stop();
    
    // Navigation automatique vers le quiz
    _showCompletionDialog();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Écoute terminée !'),
        content: const Text('Félicitations ! Vous avez écouté toute l\'histoire. Êtes-vous prêt pour le quiz ?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Possibilité de réécouter
            },
            child: const Text('Réécouter'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('${AppConstants.ROUTE_QUIZ}/${widget.storyId}');
            },
            child: const Text('Passer au quiz'),
          ),
        ],
      ),
    );
  }

  void _seekTo(double value) {
    final newPosition = Duration(
      milliseconds: (value * _totalDuration.inMilliseconds).round(),
    );
    setState(() {
      _currentPosition = newPosition;
    });
    
    _progressAnimationController.value = value;
  }

  @override
  void dispose() {
    _waveAnimationController.dispose();
    _progressAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Écoute'),
        actions: [
          IconButton(
            icon: const Icon(Icons.screen_lock_portrait),
            onPressed: () {
              // Activer le mode verrouillage écran
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Mode verrouillage écran activé'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _story == null
              ? const Center(child: Text('Histoire non trouvée'))
              : Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        theme.colorScheme.primary.withOpacity(0.1),
                        theme.colorScheme.secondary.withOpacity(0.1),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const Spacer(),
                          
                          // Image d'illustration
                          Container(
                            width: 250,
                            height: 250,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.secondary,
                                ],
                              ),
                            ),
                            child: Stack(
                              children: [
                                const Center(
                                  child: Icon(
                                    Icons.headphones,
                                    size: 80,
                                    color: Colors.white,
                                  ),
                                ),
                                
                                // Animation des ondes sonores
                                if (_isPlaying)
                                  Positioned.fill(
                                    child: AnimatedBuilder(
                                      animation: _waveAnimationController,
                                      builder: (context, child) {
                                        return CustomPaint(
                                          painter: SoundWavePainter(
                                            _waveAnimationController.value,
                                            theme.colorScheme.tertiary,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 40),
                          
                          // Titre de l'histoire
                          Text(
                            _story!.title,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Pays d'origine
                          Text(
                            _story!.country,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          
                          const Spacer(),
                          
                          // Barre de progression
                          Column(
                            children: [
                              Slider(
                                value: _currentPosition.inMilliseconds / _totalDuration.inMilliseconds,
                                onChanged: _seekTo,
                                activeColor: theme.colorScheme.primary,
                              ),
                              
                              // Temps actuel / temps total
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _formatDuration(_currentPosition),
                                      style: theme.textTheme.bodySmall,
                                    ),
                                    Text(
                                      _formatDuration(_totalDuration),
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Contrôles audio
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Bouton reculer 15s
                              IconButton(
                                onPressed: () {
                                  final newPosition = Duration(
                                    milliseconds: (_currentPosition.inMilliseconds - 15000).clamp(0, _totalDuration.inMilliseconds),
                                  );
                                  _seekTo(newPosition.inMilliseconds / _totalDuration.inMilliseconds);
                                },
                                icon: const Icon(Icons.replay_10),
                                iconSize: 32,
                              ),
                              
                              const SizedBox(width: 20),
                              
                              // Bouton Play/Pause principal
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.colorScheme.primary.withOpacity(0.3),
                                      blurRadius: 15,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  onPressed: _togglePlayPause,
                                  icon: Icon(
                                    _isPlaying ? Icons.pause : Icons.play_arrow,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                              ),
                              
                              const SizedBox(width: 20),
                              
                              // Bouton avancer 15s
                              IconButton(
                                onPressed: () {
                                  final newPosition = Duration(
                                    milliseconds: (_currentPosition.inMilliseconds + 15000).clamp(0, _totalDuration.inMilliseconds),
                                  );
                                  _seekTo(newPosition.inMilliseconds / _totalDuration.inMilliseconds);
                                },
                                icon: const Icon(Icons.forward_10),
                                iconSize: 32,
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Bouton pour passer directement au quiz
                          TextButton(
                            onPressed: () {
                              context.go('${AppConstants.ROUTE_QUIZ}/${widget.storyId}');
                            },
                            child: const Text('Passer au quiz'),
                          ),
                          
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class SoundWavePainter extends CustomPainter {
  final double animationValue;
  final Color color;

  SoundWavePainter(this.animationValue, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);
    
    // Dessiner des cercles concentriques animés
    for (int i = 1; i <= 3; i++) {
      final radius = (size.width / 6) * i * (1 + animationValue * 0.5);
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}