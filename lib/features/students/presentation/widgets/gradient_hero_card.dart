import 'package:flutter/material.dart';
import '../theme/student_theme.dart';

/// Hero card with gradient background and pattern
class GradientHeroCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double progress;
  final Widget? actionButton;
  
  const GradientHeroCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.progress,
    this.actionButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: StudentTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: StudentTheme.primaryStart.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: CustomPaint(
                painter: DotPatternPainter(),
              ),
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: StudentTheme.heroTitle),
                const SizedBox(height: 8),
                Text(subtitle, style: StudentTheme.heroSubtitle),
                const SizedBox(height: 24),
                
                // Progress section
                Row(
                  children: [
                    const Text(
                      'Onboarding Progress',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${progress.toInt()}%',
                        style: const TextStyle(
                          color: StudentTheme.primaryStart,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Progress bar
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: ProgressPill(progress: progress),
                ),
                
                if (actionButton != null) ...[
                  const SizedBox(height: 24),
                  actionButton!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Progress pill widget
class ProgressPill extends StatelessWidget {
  final double progress;
  
  const ProgressPill({Key? key, required this.progress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 10,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress / 100,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

/// Dot pattern painter for background
class DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    const dotSize = 2.0;
    const spacing = 30.0;
    
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotSize, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
