import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kuma/core/constants/app_constants.dart';
import 'package:kuma/core/di/injection_container.dart';
import 'package:kuma/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kuma/features/auth/presentation/pages/account_link_page.dart';
import 'package:kuma/shared/domain/entities/user.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AuthBloc>()..add(const AuthEvent.checkAuthStatus()),
      child: const ProfileView(),
    );
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Mon Profil'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Unauthenticated) {
            context.go(AppConstants.ROUTE_SPLASH);
          }
        },
        builder: (context, state) {
          if (state is Loading || state is Initial) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is! Authenticated) {
            return const Center(
              child: Text('Erreur de chargement du profil'),
            );
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // User info section
                _buildUserInfo(theme, state.user),
                
                const SizedBox(height: 32),
                
                // Account section
                _buildAccountSection(context, theme, state.user),
                
                const SizedBox(height: 24),
                
                // Settings section
                _buildSettingsSection(context, theme, state.user),
                
                const SizedBox(height: 24),
                
                // Sign out section
                _buildSignOutSection(context, theme),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserInfo(ThemeData theme, AppUser user) {
    final isAnonymous = user.email.isEmpty;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 40,
              backgroundColor: theme.colorScheme.primary,
              child: Text(
                isAnonymous 
                    ? '👤' 
                    : user.email.isNotEmpty 
                        ? user.email[0].toUpperCase()
                        : '?',
                style: TextStyle(
                  fontSize: isAnonymous ? 32 : 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // User info
            Text(
              isAnonymous ? 'Utilisateur anonyme' : user.email,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Type: ${_getUserTypeLabel(user.userType)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            
            const SizedBox(height: 4),
            
            Text(
              'Membre depuis ${_formatDate(user.createdAt)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context, ThemeData theme, AppUser user) {
    final isAnonymous = user.email.isEmpty;
    
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Compte',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          if (isAnonymous) ...[
            _buildListTile(
              context: context,
              icon: Icons.link,
              title: 'Lier votre compte',
              subtitle: 'Sauvegardez vos données sur tous vos appareils',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AccountLinkPage(),
                  ),
                );
              },
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Recommandé',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ] else ...[
            _buildListTile(
              context: context,
              icon: Icons.email,
              title: 'Email',
              subtitle: user.email,
              onTap: null,
            ),
            
            _buildListTile(
              context: context,
              icon: Icons.security,
              title: 'Changer le mot de passe',
              subtitle: 'Modifier votre mot de passe',
              onTap: () {
                // TODO: Implement password change
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fonctionnalité bientôt disponible'),
                  ),
                );
              },
            ),
          ],
          
          _buildListTile(
            context: context,
            icon: Icons.family_restroom,
            title: 'Profils enfants',
            subtitle: '${user.childProfiles.length} enfant(s) configuré(s)',
            onTap: () {
              // TODO: Navigate to children management
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Gestion des enfants bientôt disponible'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, ThemeData theme, AppUser user) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Paramètres',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          _buildListTile(
            context: context,
            icon: Icons.public,
            title: 'Pays de départ',
            subtitle: user.settings.startingCountry.isNotEmpty 
                ? user.settings.startingCountry 
                : 'Non défini',
            onTap: () {
              // TODO: Navigate to country selection
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Modification du pays bientôt disponible'),
                ),
              );
            },
          ),
          
          _buildListTile(
            context: context,
            icon: Icons.language,
            title: 'Langue',
            subtitle: 'Français',
            onTap: () {
              // TODO: Navigate to language selection
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sélection de langue bientôt disponible'),
                ),
              );
            },
          ),
          
          _buildListTile(
            context: context,
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: user.settings.notificationsEnabled ? 'Activées' : 'Désactivées',
            onTap: () {
              // TODO: Navigate to notification settings
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Paramètres de notification bientôt disponibles'),
                ),
              );
            },
          ),
          
          _buildListTile(
            context: context,
            icon: Icons.dark_mode,
            title: 'Mode sombre',
            subtitle: user.settings.darkMode ? 'Activé' : 'Désactivé',
            onTap: () {
              // TODO: Toggle dark mode
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Mode sombre bientôt disponible'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSignOutSection(BuildContext context, ThemeData theme) {
    return Card(
      child: _buildListTile(
        context: context,
        icon: Icons.logout,
        title: 'Se déconnecter',
        subtitle: 'Retourner à l\'écran de connexion',
        onTap: () {
          _showSignOutDialog(context);
        },
        textColor: theme.colorScheme.error,
      ),
    );
  }

  Widget _buildListTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    Widget? trailing,
    Color? textColor,
  }) {
    final theme = Theme.of(context);
    
    return ListTile(
      leading: Icon(icon, color: textColor ?? theme.colorScheme.onSurface),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? theme.colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: (textColor ?? theme.colorScheme.onSurface).withOpacity(0.7),
        ),
      ),
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: onTap,
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Se déconnecter'),
        content: const Text(
          'Êtes-vous sûr de vouloir vous déconnecter ? Vos données locales seront conservées.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthBloc>().add(const AuthEvent.signOut());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
  }

  String _getUserTypeLabel(String userType) {
    switch (userType) {
      case 'parent':
        return 'Parent';
      case 'teacher':
        return 'Enseignant(e)';
      case 'child':
        return 'Enfant';
      default:
        return 'Utilisateur';
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Inconnue';
    
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays < 1) {
      return 'Aujourd\'hui';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} jour(s)';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} semaine(s)';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} mois';
    } else {
      return '${(difference.inDays / 365).floor()} an(s)';
    }
  }
}