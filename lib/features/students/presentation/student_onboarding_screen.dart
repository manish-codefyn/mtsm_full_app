import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/student_repository.dart';
import '../domain/onboarding_status.dart';
import 'theme/student_theme.dart';
import 'widgets/gradient_hero_card.dart';
import 'widgets/step_card.dart';

final studentOnboardingStatusProvider = FutureProvider.family.autoDispose<OnboardingStatus, String>((ref, studentId) async {
  return ref.watch(studentRepositoryProvider).getOnboardingStatus(studentId);
});

class StudentOnboardingScreen extends ConsumerWidget {
  final String studentId;

  const StudentOnboardingScreen({Key? key, required this.studentId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingAsync = ref.watch(studentOnboardingStatusProvider(studentId));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Student Onboarding'),
        actions: [
          TextButton.icon(
            onPressed: () => context.go('/students'),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            label: const Text('Back to List', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: onboardingAsync.when(
        data: (status) => _buildOnboardingContent(context, status),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(studentOnboardingStatusProvider(studentId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOnboardingContent(BuildContext context, OnboardingStatus status) {
    final isComplete = status.isReadyForReview; // Use isReadyForReview instead of isComplete
    final progress = status.progress;

    // Helper function to check if a step is completed
    bool isStepCompleted(String stepId) {
      return status.steps.any((s) => s.id == stepId && s.isCompleted);
    }

    // Define all 9 steps using UIOnboardingStep
    final steps = [
      UIOnboardingStep(
        id: 'basic',
        title: 'Basic Information',
        icon: Icons.person,
        route: '/students/add',
        isCompleted: isStepCompleted('basic_info'),
      ),
      UIOnboardingStep(
        id: 'guardian',
        title: 'Guardian Details',
        icon: Icons.family_restroom,
        route: '/students/add',
        isCompleted: isStepCompleted('guardians'),
      ),
      UIOnboardingStep(
        id: 'address',
        title: 'Address Information',
        icon: Icons.home,
        route: '/students/add',
        isCompleted: isStepCompleted('addresses'),
      ),
      UIOnboardingStep(
        id: 'medical',
        title: 'Medical Information',
        icon: Icons.medical_services,
        route: '/students/add',
        isCompleted: isStepCompleted('medical_info'),
      ),
      UIOnboardingStep(
        id: 'transport',
        title: 'Transport Details',
        icon: Icons.directions_bus,
        route: '/students/add',
        isCompleted: false,
        isOptional: true,
      ),
      UIOnboardingStep(
        id: 'hostel',
        title: 'Hostel Allocation',
        icon: Icons.hotel,
        route: '/students/add',
        isCompleted: false,
        isOptional: true,
      ),
      UIOnboardingStep(
        id: 'history',
        title: 'Academic History',
        icon: Icons.history_edu,
        route: '/students/add',
        isCompleted: false,
        isOptional: true,
      ),
      UIOnboardingStep(
        id: 'identification',
        title: 'Identification',
        icon: Icons.badge,
        route: '/students/add',
        isCompleted: isStepCompleted('identification'),
      ),
      UIOnboardingStep(
        id: 'documents',
        title: 'Document Upload',
        icon: Icons.upload_file,
        route: '/students/$studentId/documents',
        isCompleted: isStepCompleted('documents'),
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Section
          GradientHeroCard(
            title: 'Welcome, ${status.firstName}! 👋',
            subtitle: 'Let\'s complete your student profile to get you started.',
            progress: progress,
            actionButton: isComplete
                ? ElevatedButton.icon(
                    onPressed: () => context.go('/students'),
                    icon: const Icon(Icons.check_circle),
                    label: const Text('View Full Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: StudentTheme.primaryStart,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  )
                : null,
          ),
          
          const SizedBox(height: 32),
          
          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'REQUIRED STEPS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                  letterSpacing: 1.2,
                ),
              ),
              if (isComplete)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: StudentTheme.statusBadge(StudentTheme.success),
                  child: Row(
                    children: const [
                      Icon(Icons.check_circle, size: 16, color: StudentTheme.success),
                      SizedBox(width: 4),
                      Text(
                        'All Set!',
                        style: TextStyle(
                          color: StudentTheme.success,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Steps Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 1200 ? 4 : (constraints.maxWidth > 800 ? 3 : 2);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.9,
                ),
                itemCount: steps.length,
                itemBuilder: (context, index) {
                  final step = steps[index];
                  return StepCard(
                    title: step.title,
                    icon: step.icon,
                    isCompleted: step.isCompleted,
                    isOptional: step.isOptional,
                    animationDelay: index,
                    onTap: () => context.go(step.route),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
