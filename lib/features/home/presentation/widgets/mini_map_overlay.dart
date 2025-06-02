import 'package:flutter/material.dart';
import 'package:kuma/core/constants/countries.dart';

class MiniMapOverlay extends StatelessWidget {
  final Rect visibleArea;
  final String currentCountry;
  final List<String> unlockedCountries;
  final Function(String) onMapTap;

  const MiniMapOverlay({
    super.key,
    required this.visibleArea,
    required this.currentCountry,
    required this.unlockedCountries,
    required this.onMapTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: 120,
      height: 150,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            // Mini map background
            Container(
              width: 120,
              height: 150,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF87CEEB),
                    Color(0xFFF0E68C),
                    Color(0xFFDEB887),
                  ],
                ),
              ),
            ),
            
            // Simplified Africa shape
            CustomPaint(
              size: const Size(120, 150),
              painter: MiniAfricaPainter(),
            ),
            
            // Story points
            ...Countries.TEST_COUNTRIES.map((countryName) {
              final position = Countries.COUNTRY_POSITIONS[countryName];
              if (position == null) return const SizedBox.shrink();
              
              final isUnlocked = unlockedCountries.contains(countryName);
              final isCurrent = currentCountry == countryName;
              
              return Positioned(
                left: position['x']! * 120 - 3,
                top: position['y']! * 150 - 3,
                child: GestureDetector(
                  onTap: () => onMapTap(countryName),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? theme.colorScheme.error
                          : isUnlocked
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline,
                      shape: BoxShape.circle,
                      border: isCurrent
                          ? Border.all(color: Colors.white, width: 1)
                          : null,
                    ),
                  ),
                ),
              );
            }),
            
            // Visible area indicator
            Positioned(
              left: visibleArea.left * 120,
              top: visibleArea.top * 150,
              child: Container(
                width: visibleArea.width * 120,
                height: visibleArea.height * 150,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: theme.colorScheme.secondary,
                    width: 1.5,
                  ),
                  color: theme.colorScheme.secondary.withOpacity(0.1),
                ),
              ),
            ),
            
            // Mini map header
            Positioned(
              top: 4,
              left: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Afrique',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            
            // Progress indicator
            Positioned(
              bottom: 4,
              left: 4,
              right: 4,
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: unlockedCountries.length / Countries.TEST_COUNTRIES.length,
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MiniAfricaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF8B4513).withOpacity(0.8)
      ..style = PaintingStyle.fill;

    // Simplified Africa outline for mini map
    final path = Path();
    
    // More simplified version for mini map
    path.moveTo(size.width * 0.5, size.height * 0.12); // North
    path.lineTo(size.width * 0.75, size.height * 0.35); // East
    path.lineTo(size.width * 0.85, size.height * 0.65); // Southeast
    path.lineTo(size.width * 0.6, size.height * 0.88); // South
    path.lineTo(size.width * 0.4, size.height * 0.88); // South
    path.lineTo(size.width * 0.15, size.height * 0.65); // Southwest
    path.lineTo(size.width * 0.1, size.height * 0.35); // West
    path.lineTo(size.width * 0.25, size.height * 0.15); // Northwest
    path.close();

    canvas.drawPath(path, paint);
    
    // Add subtle border
    final borderPaint = Paint()
      ..color = const Color(0xFF654321)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
      
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MiniMapLegend extends StatelessWidget {
  const MiniMapLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLegendItem(
            theme,
            theme.colorScheme.error,
            'Position actuelle',
          ),
          const SizedBox(height: 4),
          _buildLegendItem(
            theme,
            theme.colorScheme.primary,
            'Pays débloqués',
          ),
          const SizedBox(height: 4),
          _buildLegendItem(
            theme,
            theme.colorScheme.outline,
            'Pays verrouillés',
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(ThemeData theme, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 10,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}