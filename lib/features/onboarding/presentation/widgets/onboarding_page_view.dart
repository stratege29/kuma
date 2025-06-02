import 'package:flutter/material.dart';
import 'package:kuma/features/onboarding/presentation/widgets/pages/user_type_selection_page.dart';
import 'package:kuma/features/onboarding/presentation/widgets/pages/children_setup_page.dart';
import 'package:kuma/features/onboarding/presentation/widgets/pages/goal_selection_page.dart';
import 'package:kuma/features/onboarding/presentation/widgets/pages/time_selection_page.dart';
import 'package:kuma/features/onboarding/presentation/widgets/pages/country_selection_page.dart';
import 'package:kuma/features/onboarding/presentation/widgets/pages/summary_page.dart';
import 'package:kuma/features/onboarding/presentation/widgets/pages/completion_page.dart';

class OnboardingPageView extends StatelessWidget {
  final PageController pageController;
  final Function(int) onPageChanged;

  const OnboardingPageView({
    super.key,
    required this.pageController,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: pageController,
      onPageChanged: onPageChanged,
      physics: const NeverScrollableScrollPhysics(), // Désactive le swipe
      children: const [
        UserTypeSelectionPage(),
        ChildrenSetupPage(),
        GoalSelectionPage(),
        TimeSelectionPage(),
        CountrySelectionPage(),
        SummaryPage(),
        CompletionPage(),
      ],
    );
  }
}