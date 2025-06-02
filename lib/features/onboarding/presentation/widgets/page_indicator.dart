import 'package:flutter/material.dart';

class PageIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const PageIndicator({
    super.key,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (index) {
        final isActive = index == currentPage;
        final isCompleted = index < currentPage;
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: isActive ? 24 : 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isActive || isCompleted
                ? theme.colorScheme.primary
                : theme.colorScheme.primary.withOpacity(0.2),
          ),
        );
      }),
    );
  }
}