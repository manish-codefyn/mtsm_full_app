class Staff {
  final String id;
  final String employeeId;
  final String firstName;
  final String lastName;
  final String email;
  final String? departmentName;
  final String? designationTitle;

  Staff({
    required this.id,
    required this.employeeId,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.departmentName,
    this.designationTitle,
  });

  String get fullName => '$firstName $lastName';

  factory Staff.fromJson(Map<String, dynamic> json) {
    // Handling nested user object if present (common in Django REST Framework)
    final user = json['user'] is Map ? json['user'] : json;
    
    return Staff(
      id: json['id']?.toString() ?? '',
      employeeId: json['employee_id'] ?? '',
      firstName: user['first_name'] ?? '',
      lastName: user['last_name'] ?? '',
      email: json['personal_email'] ?? user['email'] ?? '',
      departmentName: json['department_data']?['name'] ?? json['department_name'] ?? '',
      designationTitle: json['designation_data']?['title'] ?? json['designation_title'] ?? '',
    );
  }
}
