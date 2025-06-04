import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kuma/core/di/injection_container.dart';
import 'package:kuma/features/home/presentation/bloc/home_bloc.dart';
import 'package:kuma/features/home/presentation/widgets/enhanced_africa_map_widget.dart';
import 'package:kuma/features/home/presentation/widgets/story_bottom_sheet.dart';
import 'package:kuma/shared/domain/entities/story.dart';
import 'package:kuma/shared/domain/entities/user.dart';

class HomePage extends StatelessWidget {
  final AppUser user;

  const HomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(storyRepository: sl(), user: user)
        ..add(const HomeEvent.loadStories()),
      child: HomeView(user: user),
    );
  }
}

class HomeView extends StatefulWidget {
  final AppUser user;

  const HomeView({super.key, required this.user});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          BlocConsumer<HomeBloc, HomeState>(
            listener: (context, state) {
              if (state.selectedStory != null) {
                _showStoryBottomSheet(context, state.selectedStory!);
              }
            },
            builder: (context, state) {
              return EnhancedAfricaMapWidget(user: widget.user);
            },
          ),
          const Center(child: Text('Catalogue - À implémenter')),
          const Center(child: Text('Profil - À implémenter')),
        ],
      ),
      extendBody: true,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(bottom: 20, left: 60, right: 60),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withOpacity(0.9),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: NavigationBar(
            selectedIndex: _currentIndex,
            backgroundColor: Colors.transparent,
            elevation: 0,
            indicatorColor: theme.colorScheme.primary.withOpacity(0.2),
            height: 60,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.map),
                label: 'Carte',
              ),
              NavigationDestination(
                icon: Icon(Icons.library_books),
                label: 'Catalogue',
              ),
              NavigationDestination(
                icon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStoryBottomSheet(BuildContext context, Story story) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StoryBottomSheet(story: story),
    ).then((_) {
      // Clear la sélection quand le bottom sheet se ferme
      context.read<HomeBloc>().add(const HomeEvent.clearSelection());
    });
  }
}
