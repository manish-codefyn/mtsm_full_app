import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? borderColor; // Rocker Style: Left Border Color
  final LinearGradient? gradient; // Keep for backward compatibility/custom overrides
  final VoidCallback? onTap;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.borderColor,
    this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // If gradient is provided, fallback to old style (or mapped to new style if needed)
    // But Rocker default is White Card + Left Border + Icon Circle.
    
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveBorderColor = borderColor ?? AppTheme.primaryBlue;

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: theme.dividerColor), // Uniform thin border
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            border: Border(
              left: BorderSide(color: effectiveBorderColor, width: 5),
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.grey[400] : const Color(0xFF6c757d), // text-secondary
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    value,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: effectiveBorderColor, // Text color matches border in Rocker (text-info, text-danger etc)
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                   shape: BoxShape.circle,
                   gradient: LinearGradient(
                     colors: [
                       effectiveBorderColor,
                       effectiveBorderColor.withOpacity(0.7),
                     ],
                     begin: Alignment.topLeft,
                     end: Alignment.bottomRight,
                   ),
                   boxShadow: [
                     BoxShadow(
                       color: effectiveBorderColor.withOpacity(0.3),
                       blurRadius: 5,
                       offset: const Offset(0, 3)
                     )
                   ]
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
