class OnboardingStatus {
  final String studentId;
  final String admissionNumber;
  final String firstName;
  final String lastName;
  final List<OnboardingStep> steps;
  final double progress;
  final bool isReadyForReview;

  OnboardingStatus({
    required this.studentId,
    required this.admissionNumber,
    required this.firstName,
    required this.lastName,
    required this.steps,
    required this.progress,
    required this.isReadyForReview,
  });

  factory OnboardingStatus.fromJson(Map<String, dynamic> json) {
    return OnboardingStatus(
      studentId: json['student_id'] ?? '',
      admissionNumber: json['admission_number'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      steps: (json['steps'] as List?)
              ?.map((e) => OnboardingStep.fromJson(e))
              .toList() ??
          [],
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      isReadyForReview: json['is_ready_for_review'] ?? false,
    );
  }
}

class OnboardingStep {
  final String id;
  final String title;
  final bool isCompleted;
  final bool required;
  final String endpoint;

  OnboardingStep({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.required,
    required this.endpoint,
  });

  factory OnboardingStep.fromJson(Map<String, dynamic> json) {
    return OnboardingStep(
      id: json['id'],
      title: json['title'],
      isCompleted: json['is_completed'] ?? false,
      required: json['required'] ?? false,
      endpoint: json['endpoint'] ?? '',
    );
  }
}
