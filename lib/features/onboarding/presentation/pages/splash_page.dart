import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kuma/core/constants/app_constants.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // Citations inspirantes africaines
  final List<String> _inspirationalQuotes = [
    "\"Si tu veux aller vite, va seul. Si tu veux aller loin, va avec les autres.\" - Proverbe africain",
    "\"La patience est un arbre dont la racine est amère et les fruits très doux.\" - Proverbe africain",
    "\"Quand les racines d'un arbre commencent à pourrir, il étend ses branches.\" - Proverbe africain",
    "\"Un seul bracelet ne fait pas de bruit.\" - Proverbe africain",
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _navigateToNext();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    _animationController.forward();
  }

  void _navigateToNext() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.go(AppConstants.ROUTE_ONBOARDING);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final randomQuote = _inspirationalQuotes[
        DateTime.now().millisecond % _inspirationalQuotes.length];

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
              theme.colorScheme.tertiary,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                
                // Logo et nom de l'app
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            // Icône Kuma (placeholder)
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.auto_stories,
                                size: 60,
                                color: Color(0xFFFF6B35),
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            // Nom de l'app
                            Text(
                              'KUMA',
                              style: theme.textTheme.headlineLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 4,
                              ),
                            ),
                            const SizedBox(height: 8),
                            
                            // Sous-titre
                            Text(
                              'Contes Africains',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                
                const Spacer(flex: 3),
                
                // Citation inspirante
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          randomQuote,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontStyle: FontStyle.italic,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),
                
                const Spacer(),
                
                // Indicateur de chargement
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}