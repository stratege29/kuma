import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kuma/core/constants/app_constants.dart';
import 'package:kuma/core/constants/countries.dart';

class QuizResultPage extends StatefulWidget {
  final String storyId;

  const QuizResultPage({
    super.key,
    required this.storyId,
  });

  @override
  State<QuizResultPage> createState() => _QuizResultPageState();
}

class _QuizResultPageState extends State<QuizResultPage>
    with TickerProviderStateMixin {
  late AnimationController _scaleAnimationController;
  late AnimationController _confettiAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;

  int _score = 0;
  int _total = 3;
  bool _passed = false;
  final String _currentCountry = 'Senegal';
  String _nextCountry = '';

  @override
  void initState() {
    super.initState();
    _parseQueryParameters();
    _initAnimations();
    _startAnimations();
  }

  void _parseQueryParameters() {
    final location = GoRouterState.of(context);
    final params = location.uri.queryParameters;

    _score = int.tryParse(params['score'] ?? '0') ?? 0;
    _total = int.tryParse(params['total'] ?? '3') ?? 3;
    _passed = params['passed'] == 'true';

    if (_passed) {
      _nextCountry = Countries.getNextCountry(_currentCountry);
    }
  }

  void _initAnimations() {
    _scaleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _confettiAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleAnimationController,
      curve: Curves.elasticOut,
    ));

    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleAnimationController,
      curve: Curves.bounceOut,
    ));
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 500), () {
      _scaleAnimationController.forward();

      if (_passed) {
        _confettiAnimationController.repeat();
      }
    });
  }

  @override
  void dispose() {
    _scaleAnimationController.dispose();
    _confettiAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultat du Quiz'),
        automaticallyImplyLeading: false,
        backgroundColor: _passed ? Colors.green : Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _passed
                ? [Colors.green.withOpacity(0.1), theme.colorScheme.surface]
                : [Colors.orange.withOpacity(0.1), theme.colorScheme.surface],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animation du résultat
                      AnimatedBuilder(
                        animation: _scaleAnimationController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scaleAnimation.value,
                            child: _ResultAnimation(
                              passed: _passed,
                              theme: theme,
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 32),

                      // Score
                      AnimatedBuilder(
                        animation: _scaleAnimationController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _bounceAnimation.value,
                            child: Column(
                              children: [
                                Text(
                                  _passed ? 'Félicitations !' : 'Pas mal !',
                                  style:
                                      theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        _passed ? Colors.green : Colors.orange,
                                  ),
                                  textAlign: TextAlign.center,
                                ),

                                const SizedBox(height: 16),

                                Text(
                                  'Votre score : $_score/$_total',
                                  style:
                                      theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                // Barre de progression du score
                                Container(
                                  width: 200,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.outline
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: _score / _total,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: _passed
                                            ? Colors.green
                                            : Colors.orange,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 32),

                      // Message selon le résultat
                      AnimatedBuilder(
                        animation: _scaleAnimationController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _bounceAnimation.value,
                            child: _ResultMessage(
                              passed: _passed,
                              nextCountry: _nextCountry,
                              theme: theme,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Boutons d'action
                AnimatedBuilder(
                  animation: _scaleAnimationController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _bounceAnimation.value,
                      child: _ActionButtons(
                        passed: _passed,
                        storyId: widget.storyId,
                        onContinue: () => _handleContinue(),
                        onRetry: () => _handleRetry(),
                        onReread: () => _handleReread(),
                      ),
                    );
                  },
                ),

                // Effets de confettis si réussi
                if (_passed)
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _confettiAnimationController,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: ConfettiPainter(
                              _confettiAnimationController.value),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleContinue() {
    // Marquer l'histoire comme terminée et débloquer le pays suivant
    // Ici on simule la mise à jour du progrès
    context.go(AppConstants.ROUTE_HOME);
  }

  void _handleRetry() {
    context.go('${AppConstants.ROUTE_QUIZ}/${widget.storyId}');
  }

  void _handleReread() {
    context.go('${AppConstants.ROUTE_READING}/${widget.storyId}');
  }
}

class _ResultAnimation extends StatelessWidget {
  final bool passed;
  final ThemeData theme;

  const _ResultAnimation({
    required this.passed,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: passed ? Colors.green : Colors.orange,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (passed ? Colors.green : Colors.orange).withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Icon(
        passed ? Icons.check : Icons.lightbulb,
        color: Colors.white,
        size: 60,
      ),
    );
  }
}

class _ResultMessage extends StatelessWidget {
  final bool passed;
  final String nextCountry;
  final ThemeData theme;

  const _ResultMessage({
    required this.passed,
    required this.nextCountry,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            passed ? Icons.celebration : Icons.auto_stories,
            color: passed ? Colors.green : Colors.orange,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            passed
                ? 'Excellent ! Vous avez débloqué $nextCountry !'
                : 'Vous pouvez réessayer ou relire l\'histoire pour mieux comprendre.',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            passed
                ? 'Votre voyage à travers l\'Afrique continue. Prêt pour de nouvelles aventures ?'
                : 'Chaque histoire contient de précieux enseignements. Prenez le temps de bien les découvrir !',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final bool passed;
  final String storyId;
  final VoidCallback onContinue;
  final VoidCallback onRetry;
  final VoidCallback onReread;

  const _ActionButtons({
    required this.passed,
    required this.storyId,
    required this.onContinue,
    required this.onRetry,
    required this.onReread,
  });

  @override
  Widget build(BuildContext context) {
    if (passed) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onContinue,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Continuer l\'aventure'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onReread,
            child: const Text('Relire l\'histoire'),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Réessayer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onReread,
                  icon: const Icon(Icons.menu_book),
                  label: const Text('Relire'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onContinue,
            child: const Text('Retour à la carte'),
          ),
        ],
      );
    }
  }
}

class ConfettiPainter extends CustomPainter {
  final double animationValue;

  ConfettiPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple
    ];

    for (int i = 0; i < 50; i++) {
      paint.color = colors[i % colors.length];

      final x =
          (size.width * (i % 10) / 10) + (animationValue * 100) % size.width;
      final y = (size.height * animationValue + i * 10) % size.height;

      canvas.drawCircle(Offset(x, y), 3, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
