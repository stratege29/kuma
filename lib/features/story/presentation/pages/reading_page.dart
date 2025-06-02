import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kuma/core/constants/app_constants.dart';
import 'package:kuma/shared/domain/entities/story.dart';

class ReadingPage extends StatefulWidget {
  final String storyId;

  const ReadingPage({
    super.key,
    required this.storyId,
  });

  @override
  State<ReadingPage> createState() => _ReadingPageState();
}

class _ReadingPageState extends State<ReadingPage> {
  final ScrollController _scrollController = ScrollController();
  double _fontSize = 16.0;
  bool _isDarkMode = false;
  bool _isLoading = true;
  Story? _story;

  @override
  void initState() {
    super.initState();
    _loadStory();
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
    // Mock story basée sur l'ID
    return Story(
      id: widget.storyId,
      title: 'Leuk le lièvre et Bouki l\'hyène',
      country: 'Senegal',
      countryCode: 'SEN',
      content: {
        'fr': '''Il était une fois, dans la savane sénégalaise, deux amis très différents : Leuk le lièvre, petit mais très malin, et Bouki l'hyène, grosse et forte mais pas très intelligente.

Un jour, les deux amis décidèrent de creuser un puits ensemble car la saison sèche approchait et l'eau se faisait rare. Ils travaillèrent dur sous le soleil brûlant, Bouki creusant avec sa force et Leuk l'encourageant avec ses mots.

Quand le puits fut terminé et qu'il était rempli d'eau fraîche et claire, Leuk eut une idée. "Mon ami Bouki, dit-il, nous devrions surveiller notre puits à tour de rôle pour que personne ne vienne voler notre eau."

Bouki, fatiguée par le travail, accepta immédiatement. "Bonne idée, Leuk ! Tu surveilleras la nuit et moi le jour."

Mais le lièvre malin avait un autre plan. Chaque nuit, au lieu de surveiller, il buvait l'eau du puits et se roulait dans la boue pour cacher les preuves. Le matin, quand Bouki arrivait, le niveau de l'eau avait baissé.

"Quelqu'un vient boire notre eau la nuit !" se plaignait Bouki.

"C'est terrible ! répondait Leuk avec un air innocent. Il faut attraper ce voleur !"

Bouki décida de rester éveillée une nuit pour attraper le voleur. Quand elle vit Leuk boire l'eau, elle fut très en colère.

"Leuk ! C'est toi le voleur ! Tu vas le payer !"

Mais le lièvre astucieux avait prévu cela aussi. "Mon amie, dit-il calmement, j'étais en train de goûter l'eau pour m'assurer qu'elle n'était pas empoisonnée par le vrai voleur."

Bouki, confuse, ne sut que répondre. Leuk continua : "D'ailleurs, le vrai voleur pourrait revenir. Cachons-nous et attendons."

Ils se cachèrent près du puits. Au bout d'un moment, Leuk dit : "Regarde ! Là-bas, dans les buissons !"

Bouki se précipita vers les buissons pendant que Leuk s'échappait silencieusement.

Quand Bouki réalisa qu'elle avait été dupée une fois de plus, elle décida de ne plus jamais faire confiance au lièvre sans réfléchir.

Depuis ce jour, dans les villages du Sénégal, on raconte cette histoire pour enseigner aux enfants qu'il faut toujours réfléchir avant d'agir et ne pas se laisser tromper par les belles paroles.

La ruse de Leuk nous rappelle que l'intelligence peut triompher de la force, mais aussi qu'il ne faut pas abuser de la confiance de ses amis. Bouki, elle, a appris à être plus méfiante et à réfléchir avant d'agir.

Cette histoire nous enseigne l'importance de la sagesse, de la prudence et du respect mutuel dans l'amitié.'''
      },
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = _isDarkMode ? ThemeData.dark() : Theme.of(context);
    
    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: _isDarkMode ? Colors.black : theme.colorScheme.background,
        appBar: AppBar(
          title: const Text('Lecture'),
          backgroundColor: _isDarkMode ? Colors.grey[900] : null,
          actions: [
            // Contrôles de lecture
            PopupMenuButton<String>(
              icon: const Icon(Icons.text_fields),
              onSelected: (value) {
                switch (value) {
                  case 'font_size':
                    _showFontSizeDialog();
                    break;
                  case 'dark_mode':
                    setState(() {
                      _isDarkMode = !_isDarkMode;
                    });
                    break;
                  case 'scroll_top':
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'font_size',
                  child: Row(
                    children: [
                      const Icon(Icons.format_size),
                      const SizedBox(width: 8),
                      Text('Taille de police'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'dark_mode',
                  child: Row(
                    children: [
                      Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
                      const SizedBox(width: 8),
                      Text(_isDarkMode ? 'Mode clair' : 'Mode sombre'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'scroll_top',
                  child: Row(
                    children: [
                      const Icon(Icons.vertical_align_top),
                      const SizedBox(width: 8),
                      Text('Retour en haut'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _story == null
                ? const Center(child: Text('Histoire non trouvée'))
                : SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Titre de l'histoire
                        Text(
                          _story!.title,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: _fontSize + 8,
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Métadonnées
                        Row(
                          children: [
                            Icon(
                              Icons.public,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _story!.country,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: _fontSize - 2,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.schedule,
                              size: 16,
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${_story!.estimatedReadingTime} min',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: _fontSize - 4,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Contenu de l'histoire
                        SelectableText(
                          _story!.content['fr'] ?? '',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontSize: _fontSize,
                            height: 1.8,
                            letterSpacing: 0.3,
                          ),
                        ),
                        
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
        bottomNavigationBar: _story != null
            ? Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Terminer la lecture et aller au quiz
                    context.go('${AppConstants.ROUTE_QUIZ}/${widget.storyId}');
                  },
                  icon: const Icon(Icons.quiz),
                  label: const Text('Terminer et passer au quiz'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              )
            : null,
      ),
    );
  }

  void _showFontSizeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Taille de police'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Taille actuelle: ${_fontSize.round()}'),
            Slider(
              value: _fontSize,
              min: 12.0,
              max: 24.0,
              divisions: 12,
              onChanged: (value) {
                setState(() {
                  _fontSize = value;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}