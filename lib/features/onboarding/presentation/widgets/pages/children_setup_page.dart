import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kuma/core/constants/app_constants.dart';
import 'package:kuma/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:kuma/shared/domain/entities/user.dart';

class ChildrenSetupPage extends StatelessWidget {
  const ChildrenSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        // Skip cette page si ce n'est pas un parent
        if (state.userType != AppConstants.USER_TYPE_PARENT) {
          return const Center(
            child: Text('Configuration automatique...'),
          );
        }
        
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              
              // Titre
              Text(
                'Ajoutez vos enfants',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 12),
              
              Text(
                'Créez jusqu\'à ${AppConstants.MAX_CHILDREN} profils pour personnaliser l\'expérience de chaque enfant',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Liste des enfants
              Expanded(
                child: Column(
                  children: [
                    // Enfants existants
                    ...state.children.map((child) => _ChildCard(
                      child: child,
                      onEdit: () => _showChildDialog(context, child),
                      onDelete: () {
                        context.read<OnboardingBloc>().add(
                          OnboardingEvent.removeChild(child.id),
                        );
                      },
                    )),
                    
                    const SizedBox(height: 16),
                    
                    // Bouton d'ajout
                    if (state.children.length < AppConstants.MAX_CHILDREN)
                      _AddChildButton(
                        onTap: () => _showChildDialog(context, null),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showChildDialog(BuildContext context, ChildProfile? existingChild) {
    showDialog(
      context: context,
      builder: (dialogContext) => _ChildDialog(
        existingChild: existingChild,
        onSave: (child) {
          if (existingChild == null) {
            context.read<OnboardingBloc>().add(
              OnboardingEvent.addChild(child),
            );
          } else {
            context.read<OnboardingBloc>().add(
              OnboardingEvent.updateChild(child),
            );
          }
        },
      ),
    );
  }
}

class _ChildCard extends StatelessWidget {
  final ChildProfile child;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ChildCard({
    required this.child,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(
            child.name.isNotEmpty ? child.name[0].toUpperCase() : '?',
            style: TextStyle(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(child.name),
        subtitle: Text('${child.age} ans'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _AddChildButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddChildButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Ajouter un enfant',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChildDialog extends StatefulWidget {
  final ChildProfile? existingChild;
  final Function(ChildProfile) onSave;

  const _ChildDialog({
    this.existingChild,
    required this.onSave,
  });

  @override
  State<_ChildDialog> createState() => _ChildDialogState();
}

class _ChildDialogState extends State<_ChildDialog> {
  late final TextEditingController _nameController;
  int _selectedAge = 5;
  String _selectedAvatar = AppConstants.AVATAR_OPTIONS.first;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.existingChild?.name ?? '',
    );
    _selectedAge = widget.existingChild?.age ?? 5;
    _selectedAvatar = widget.existingChild?.avatar ?? AppConstants.AVATAR_OPTIONS.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      title: Text(widget.existingChild == null ? 'Ajouter un enfant' : 'Modifier l\'enfant'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Nom
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nom de l\'enfant',
              border: OutlineInputBorder(),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Âge
          Row(
            children: [
              Text('Âge: $_selectedAge ans'),
              Expanded(
                child: Slider(
                  value: _selectedAge.toDouble(),
                  min: 3,
                  max: 12,
                  divisions: 9,
                  onChanged: (value) {
                    setState(() {
                      _selectedAge = value.round();
                    });
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Avatar (simplifié)
          Text('Avatar: $_selectedAvatar'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _nameController.text.isNotEmpty
              ? () {
                  final child = ChildProfile(
                    id: widget.existingChild?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                    name: _nameController.text,
                    age: _selectedAge,
                    avatar: _selectedAvatar,
                    progress: widget.existingChild?.progress ?? UserProgress(
                      currentCountry: '',
                      completedStories: {},
                      quizResults: {},
                      totalStoriesRead: 0,
                      totalTimeSpent: 0,
                      unlockedCountries: [],
                      achievements: [],
                    ),
                  );
                  widget.onSave(child);
                  Navigator.of(context).pop();
                }
              : null,
          child: const Text('Sauvegarder'),
        ),
      ],
    );
  }
}