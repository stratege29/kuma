import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kuma/core/constants/app_constants.dart';
import 'package:kuma/shared/domain/entities/story.dart';

class StoryBottomSheet extends StatelessWidget {
  final Story story;

  const StoryBottomSheet({
    super.key,
    required this.story,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    
    return Container(
      height: mediaQuery.size.height * 0.8,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle indicator
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image placeholder
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.image,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Titre et pays
                  Text(
                    story.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Row(
                    children: [
                      Icon(
                        Icons.public,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        story.country,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Métadonnées
                  _MetadataRow(
                    icon: Icons.schedule,
                    label: 'Lecture',
                    value: '${story.estimatedReadingTime} min',
                  ),
                  
                  const SizedBox(height: 8),
                  
                  _MetadataRow(
                    icon: Icons.headphones,
                    label: 'Audio',
                    value: '${story.estimatedAudioDuration} min',
                  ),
                  
                  const SizedBox(height: 8),
                  
                  _MetadataRow(
                    icon: Icons.child_care,
                    label: 'Âge',
                    value: story.metadata.ageGroup,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Valeurs transmises
                  Text(
                    'Valeurs transmises',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: story.values.map((value) => Chip(
                      label: Text(value),
                      backgroundColor: theme.colorScheme.primaryContainer,
                      labelStyle: TextStyle(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontSize: 12,
                      ),
                    )).toList(),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Description/leçon morale
                  Text(
                    'Leçon morale',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      story.metadata.moralLesson,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          
          // Boutons d'action
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
            ),
            child: story.isUnlocked 
                ? _ActionButtons(story: story)
                : _LockedMessage(theme: theme),
          ),
        ],
      ),
    );
  }
}

class _MetadataRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetadataRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final Story story;

  const _ActionButtons({required this.story});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  context.pop();
                  context.push('${AppConstants.ROUTE_READING}/${story.id}');
                },
                icon: const Icon(Icons.menu_book),
                label: const Text('Lire'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  context.pop();
                  context.push('${AppConstants.ROUTE_LISTENING}/${story.id}');
                },
                icon: const Icon(Icons.headphones),
                label: const Text('Écouter'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Bouton secondaire pour fermer
        TextButton(
          onPressed: () => context.pop(),
          child: const Text('Fermer'),
        ),
      ],
    );
  }
}

class _LockedMessage extends StatelessWidget {
  final ThemeData theme;

  const _LockedMessage({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.lock,
                color: theme.colorScheme.onErrorContainer,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Cette histoire sera débloquée après avoir terminé l\'histoire précédente.',
                  style: TextStyle(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        TextButton(
          onPressed: () => context.pop(),
          child: const Text('Fermer'),
        ),
      ],
    );
  }
}