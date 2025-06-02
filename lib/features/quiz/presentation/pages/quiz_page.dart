import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kuma/core/constants/app_constants.dart';
import 'package:kuma/shared/domain/entities/story.dart';

class QuizPage extends StatefulWidget {
  final String storyId;

  const QuizPage({
    super.key,
    required this.storyId,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage>
    with TickerProviderStateMixin {
  late AnimationController _questionAnimationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  bool _isLoading = true;
  Story? _story;
  int _currentQuestionIndex = 0;
  List<int> _selectedAnswers = [];
  List<bool> _questionResults = [];
  bool _showResult = false;
  bool _isAnswerSelected = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadStory();
  }

  void _initAnimations() {
    _questionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _questionAnimationController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _questionAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  void _loadStory() {
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _story = _getMockStoryWithQuiz();
        _selectedAnswers = List.filled(_story!.quizQuestions.length, -1);
        _questionResults = List.filled(_story!.quizQuestions.length, false);
        _isLoading = false;
      });
      _questionAnimationController.forward();
    });
  }

  Story _getMockStoryWithQuiz() {
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
      quizQuestions: [
        QuizQuestion(
          id: 'q1',
          question: 'Qui sont les deux personnages principaux de l\'histoire ?',
          options: [
            'Un lion et un éléphant',
            'Leuk le lièvre et Bouki l\'hyène',
            'Un singe et un oiseau',
            'Un chien et un chat'
          ],
          correctAnswer: 1,
          explanation: 'Les héros de cette histoire sont bien Leuk le lièvre, malin et astucieux, et Bouki l\'hyène, forte mais naïve.',
        ),
        QuizQuestion(
          id: 'q2',
          question: 'Que décident de faire ensemble Leuk et Bouki ?',
          options: [
            'Construire une maison',
            'Creuser un puits',
            'Planter un jardin',
            'Chasser dans la forêt'
          ],
          correctAnswer: 1,
          explanation: 'Ils décident de creuser un puits ensemble car la saison sèche approche et l\'eau se fait rare.',
        ),
        QuizQuestion(
          id: 'q3',
          question: 'Quelle est la principale leçon de cette histoire ?',
          options: [
            'Il faut toujours être le plus fort',
            'La ruse peut triompher mais ne doit pas nuire à l\'amitié',
            'Il ne faut jamais partager',
            'Les animaux ne peuvent pas être amis'
          ],
          correctAnswer: 1,
          explanation: 'Cette histoire nous enseigne que même si l\'intelligence peut l\'emporter, il ne faut pas abuser de la confiance de ses amis.',
        ),
      ],
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

  void _selectAnswer(int answerIndex) {
    if (_isAnswerSelected) return;

    setState(() {
      _selectedAnswers[_currentQuestionIndex] = answerIndex;
      _isAnswerSelected = true;
    });

    // Vérifier la réponse
    final isCorrect = answerIndex == _story!.quizQuestions[_currentQuestionIndex].correctAnswer;
    _questionResults[_currentQuestionIndex] = isCorrect;

    // Attendre un peu avant de passer à la question suivante
    Future.delayed(const Duration(seconds: 2), () {
      if (_currentQuestionIndex < _story!.quizQuestions.length - 1) {
        _nextQuestion();
      } else {
        _finishQuiz();
      }
    });
  }

  void _nextQuestion() {
    _questionAnimationController.reverse().then((_) {
      setState(() {
        _currentQuestionIndex++;
        _isAnswerSelected = false;
      });
      _questionAnimationController.forward();
    });
  }

  void _finishQuiz() {
    final score = _questionResults.where((result) => result).length;
    final passed = score >= AppConstants.QUIZ_PASSING_SCORE;
    
    context.go(
      '${AppConstants.ROUTE_QUIZ_RESULT}/${widget.storyId}?score=$score&total=${_story!.quizQuestions.length}&passed=$passed'
    );
  }

  @override
  void dispose() {
    _questionAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
        automaticallyImplyLeading: false, // Empêcher le retour en arrière
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _story == null
              ? const Center(child: Text('Quiz non trouvé'))
              : Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        theme.colorScheme.primary.withOpacity(0.1),
                        theme.colorScheme.background,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Indicateur de progression
                          _ProgressIndicator(
                            currentQuestion: _currentQuestionIndex + 1,
                            totalQuestions: _story!.quizQuestions.length,
                            theme: theme,
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Question
                          Expanded(
                            child: AnimatedBuilder(
                              animation: _questionAnimationController,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(
                                    _slideAnimation.value * MediaQuery.of(context).size.width,
                                    0,
                                  ),
                                  child: Opacity(
                                    opacity: _fadeAnimation.value,
                                    child: _QuestionCard(
                                      question: _story!.quizQuestions[_currentQuestionIndex],
                                      selectedAnswer: _selectedAnswers[_currentQuestionIndex],
                                      onAnswerSelected: _selectAnswer,
                                      showResult: _isAnswerSelected,
                                      theme: theme,
                                    ),
                                  ),
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
}

class _ProgressIndicator extends StatelessWidget {
  final int currentQuestion;
  final int totalQuestions;
  final ThemeData theme;

  const _ProgressIndicator({
    required this.currentQuestion,
    required this.totalQuestions,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Question $currentQuestion sur $totalQuestions',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Icon(
              Icons.quiz,
              color: theme.colorScheme.primary,
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        LinearProgressIndicator(
          value: currentQuestion / totalQuestions,
          backgroundColor: theme.colorScheme.outline.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
        ),
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final QuizQuestion question;
  final int selectedAnswer;
  final Function(int) onAnswerSelected;
  final bool showResult;
  final ThemeData theme;

  const _QuestionCard({
    required this.question,
    required this.selectedAnswer,
    required this.onAnswerSelected,
    required this.showResult,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question
            Text(
              question.question,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Options de réponse
            Expanded(
              child: ListView.separated(
                itemCount: question.options.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final isSelected = selectedAnswer == index;
                  final isCorrect = index == question.correctAnswer;
                  final showCorrectAnswer = showResult && isCorrect;
                  final showWrongAnswer = showResult && isSelected && !isCorrect;
                  
                  Color? backgroundColor;
                  Color? borderColor;
                  
                  if (showResult) {
                    if (showCorrectAnswer) {
                      backgroundColor = Colors.green.withOpacity(0.1);
                      borderColor = Colors.green;
                    } else if (showWrongAnswer) {
                      backgroundColor = Colors.red.withOpacity(0.1);
                      borderColor = Colors.red;
                    }
                  } else if (isSelected) {
                    backgroundColor = theme.colorScheme.primaryContainer;
                    borderColor = theme.colorScheme.primary;
                  }
                  
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    child: Card(
                      elevation: isSelected ? 4 : 1,
                      color: backgroundColor,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: showResult ? null : () => onAnswerSelected(index),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: borderColor != null
                                ? Border.all(color: borderColor, width: 2)
                                : null,
                          ),
                          child: Row(
                            children: [
                              // Lettre de l'option
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: borderColor ?? theme.colorScheme.outline.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    String.fromCharCode(65 + index), // A, B, C, D
                                    style: TextStyle(
                                      color: borderColor != null ? Colors.white : theme.colorScheme.onSurface,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(width: 16),
                              
                              // Texte de l'option
                              Expanded(
                                child: Text(
                                  question.options[index],
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                              ),
                              
                              // Icône de résultat
                              if (showResult)
                                Icon(
                                  showCorrectAnswer ? Icons.check_circle : 
                                  showWrongAnswer ? Icons.cancel : null,
                                  color: showCorrectAnswer ? Colors.green : Colors.red,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Explication après sélection
            if (showResult && question.explanation != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lightbulb,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        question.explanation!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}