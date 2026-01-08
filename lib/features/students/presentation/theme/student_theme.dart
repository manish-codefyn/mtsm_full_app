import 'package:flutter/material.dart';

/// Design system for Student module matching Django template
class StudentTheme {
  // Primary Colors (matching backend gradient)
  static const Color primaryStart = Color(0xFF6366F1); // #6366f1
  static const Color primaryEnd = Color(0xFF4F46E5);   // #4f46e5
  static const Color success = Color(0xFF10B981);      // #10b981
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryStart, primaryEnd],
  );
  
  // Card Styles
  static BoxDecoration cardDecoration({Color? borderColor}) => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: borderColor ?? Colors.black.withOpacity(0.05),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 2),
      ),
    ],
  );
  
  static BoxDecoration hoverCardDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: primaryStart, width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 25,
        offset: const Offset(0, 10),
      ),
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 10,
        offset: const Offset(0, 8),
      ),
    ],
  );
  
  // Status Badge Styles
  static BoxDecoration statusBadge(Color color) => BoxDecoration(
    color: color.withOpacity(0.1),
    borderRadius: BorderRadius.circular(20),
  );
  
  // Animation Curves
  static const Curve cardHoverCurve = Curves.easeInOut;
  static const Duration cardHoverDuration = Duration(milliseconds: 300);
  
  // Text Styles
  static const TextStyle heroTitle = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  
  static const TextStyle heroSubtitle = TextStyle(
    fontSize: 18,
    color: Colors.white70,
  );
  
  static const TextStyle stepTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle stepStatus = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );
}

/// Step data model for onboarding UI
class UIOnboardingStep {
  final String id;
  final String title;
  final IconData icon;
  final String route;
  final bool isCompleted;
  final bool isOptional;
  
  const UIOnboardingStep({
    required this.id,
    required this.title,
    required this.icon,
    required this.route,
    this.isCompleted = false,
    this.isOptional = false,
  });
}
