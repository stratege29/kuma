import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kuma/core/constants/app_constants.dart';
import 'package:kuma/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:kuma/shared/domain/entities/user.dart';

class ChildrenSetupPage extends StatefulWidget {
  const ChildrenSetupPage({super.key});

  @override
  State<ChildrenSetupPage> createState() => _ChildrenSetupPageState();
}

class _ChildrenSetupPageState extends State<ChildrenSetupPage> {
  final TextEditingController _nameController = TextEditingController();
  int _selectedAge = 5;
  String _selectedAvatar = AppConstants.ANIMAL_AVATARS.first['id'];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

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

        final maxChildren = state.isPremium 
            ? AppConstants.MAX_PREMIUM_CHILDREN 
            : AppConstants.MAX_FREE_CHILDREN;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // En-tête avec badge premium
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Créez vos profils enfants',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Jusqu\'à $maxChildren profil${maxChildren > 1 ? 's' : ''} ${!state.isPremium ? '(Gratuit)' : '(Premium)'}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!state.isPremium)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Premium',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 32),

              // Enfants existants
              if (state.children.isNotEmpty) ...[
                Text(
                  'Profils existants',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                ...state.children.map((child) => _ChildCard(
                  child: child,
                  onEdit: () => _editChild(context, child),
                  onDelete: () {
                    context.read<OnboardingBloc>().add(
                          OnboardingEvent.removeChild(child.id),
                        );
                    _clearForm();
                  },
                )),
                const SizedBox(height: 24),
              ],

              // Formulaire d'ajout (toujours visible)
              if (state.children.length < maxChildren) ...[
                Text(
                  state.children.isEmpty ? 'Créer le premier profil' : 'Ajouter un autre profil',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                _AddChildForm(
                  nameController: _nameController,
                  selectedAge: _selectedAge,
                  selectedAvatar: _selectedAvatar,
                  onAgeChanged: (age) => setState(() => _selectedAge = age),
                  onAvatarChanged: (avatar) => setState(() => _selectedAvatar = avatar),
                  onSave: () => _saveChild(context, state),
                ),
              ],

              // Message Premium si limite atteinte
              if (!state.isPremium && state.children.length >= AppConstants.MAX_FREE_CHILDREN) ...[
                const SizedBox(height: 24),
                _PremiumUpgradeCard(),
              ],

              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  void _saveChild(BuildContext context, OnboardingState state) {
    if (_nameController.text.isNotEmpty) {
      final child = ChildProfile(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        age: _selectedAge,
        avatar: _selectedAvatar,
        progress: const UserProgress(
          currentCountry: '',
          completedStories: {},
          quizResults: {},
          totalStoriesRead: 0,
          totalTimeSpent: 0,
          unlockedCountries: [],
          achievements: [],
        ),
      );

      context.read<OnboardingBloc>().add(
            OnboardingEvent.addChild(child),
          );

      _clearForm();
    }
  }

  void _editChild(BuildContext context, ChildProfile child) {
    setState(() {
      _nameController.text = child.name;
      _selectedAge = child.age;
      _selectedAvatar = child.avatar;
    });

    // Supprimer l'ancien et ajouter le nouveau
    context.read<OnboardingBloc>().add(
          OnboardingEvent.removeChild(child.id),
        );
  }

  void _clearForm() {
    setState(() {
      _nameController.clear();
      _selectedAge = 5;
      _selectedAvatar = AppConstants.ANIMAL_AVATARS.first['id'];
    });
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
    final avatar = AppConstants.ANIMAL_AVATARS.firstWhere(
      (a) => a['id'] == child.avatar,
      orElse: () => AppConstants.ANIMAL_AVATARS.first,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              avatar['emoji'],
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        title: Text(
          child.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text('${child.age} ans'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: theme.colorScheme.primary),
              onPressed: onEdit,
            ),
            IconButton(
              icon: Icon(Icons.delete, color: theme.colorScheme.error),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _AddChildForm extends StatefulWidget {
  final TextEditingController nameController;
  final int selectedAge;
  final String selectedAvatar;
  final Function(int) onAgeChanged;
  final Function(String) onAvatarChanged;
  final VoidCallback onSave;

  const _AddChildForm({
    required this.nameController,
    required this.selectedAge,
    required this.selectedAvatar,
    required this.onAgeChanged,
    required this.onAvatarChanged,
    required this.onSave,
  });

  @override
  State<_AddChildForm> createState() => _AddChildFormState();
}

class _AddChildFormState extends State<_AddChildForm> {
  bool get _hasName => widget.nameController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    widget.nameController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nom
          TextField(
            controller: widget.nameController,
            decoration: InputDecoration(
              labelText: 'Nom de l\'enfant',
              hintText: 'Ex: Amina, Kofi...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.person),
            ),
          ),

          const SizedBox(height: 20),

          // Âge
          Text(
            'Âge: ${widget.selectedAge} ans',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: widget.selectedAge.toDouble(),
            min: 3,
            max: 12,
            divisions: 9,
            label: '${widget.selectedAge} ans',
            onChanged: (value) => widget.onAgeChanged(value.round()),
          ),

          const SizedBox(height: 20),

          // Avatar
          Text(
            'Choisir un animal favori',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            child: GridView.builder(
              scrollDirection: Axis.horizontal,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
              ),
              itemCount: AppConstants.ANIMAL_AVATARS.length,
              itemBuilder: (context, index) {
                final avatar = AppConstants.ANIMAL_AVATARS[index];
                final isSelected = avatar['id'] == widget.selectedAvatar;
                
                return GestureDetector(
                  onTap: () => widget.onAvatarChanged(avatar['id']),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected 
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline.withOpacity(0.2),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        avatar['emoji'],
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Bouton d'ajout
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _hasName ? widget.onSave : null,
              icon: const Icon(Icons.add),
              label: const Text('Ajouter ce profil'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumUpgradeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.1),
            theme.colorScheme.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.star,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Passez à Premium',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Créez jusqu\'à ${AppConstants.MAX_PREMIUM_CHILDREN} profils enfants et débloquez toutes les fonctionnalités de Kuma !',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // TODO: Implémenter plus tard
                  },
                  child: const Text('Plus tard'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implémenter l'upgrade premium
                  },
                  child: const Text('Upgrader'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}