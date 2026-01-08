import 'package:flutter/material.dart';
import '../theme/student_theme.dart';

/// Animated step card for onboarding
class StepCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final bool isCompleted;
  final bool isOptional;
  final VoidCallback onTap;
  final int animationDelay;
  
  const StepCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.isCompleted,
    required this.onTap,
    this.isOptional = false,
    this.animationDelay = 0,
  }) : super(key: key);

  @override
  State<StepCard> createState() => _StepCardState();
}

class _StepCardState extends State<StepCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    
    // Start animation with delay
    Future.delayed(Duration(milliseconds: widget.animationDelay * 100), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color iconColor = widget.isCompleted 
        ? StudentTheme.success 
        : StudentTheme.primaryStart;
    
    final Color iconBgColor = widget.isCompleted
        ? StudentTheme.success.withOpacity(0.1)
        : StudentTheme.primaryStart.withOpacity(0.1);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: GestureDetector(
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: StudentTheme.cardHoverDuration,
              curve: StudentTheme.cardHoverCurve,
              transform: Matrix4.translationValues(0, _isHovered ? -5 : 0, 0),
              decoration: _isHovered 
                  ? StudentTheme.hoverCardDecoration() 
                  : StudentTheme.cardDecoration(),
              child: Card(
                elevation: 0,
                color: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon
                      AnimatedContainer(
                        duration: StudentTheme.cardHoverDuration,
                        transform: Matrix4.identity()
                          ..scale(_isHovered ? 1.1 : 1.0)
                          ..rotateZ(_isHovered ? 0.05 : 0),
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: iconBgColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(widget.icon, size: 28, color: iconColor),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Title
                      Text(
                        widget.title,
                        style: StudentTheme.stepTitle,
                        textAlign: TextAlign.center,
                      ),
                      
                      // Optional badge
                      if (widget.isOptional) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: StudentTheme.statusBadge(Colors.grey),
                          child: const Text(
                            'Optional',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      
                      // Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            widget.isCompleted 
                                ? Icons.check_circle 
                                : (widget.isOptional ? Icons.add_circle_outline : Icons.radio_button_checked),
                            size: 16,
                            color: widget.isCompleted ? StudentTheme.success : StudentTheme.primaryStart,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.isCompleted 
                                ? 'Completed' 
                                : (widget.isOptional ? 'Add Details' : 'Pending'),
                            style: StudentTheme.stepStatus.copyWith(
                              color: widget.isCompleted ? StudentTheme.success : StudentTheme.primaryStart,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
