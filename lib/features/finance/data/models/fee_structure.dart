class FeeStructure {
  final String id;
  final String name;
  final double amount;
  final String feeType;
  final String frequency;
  final String deadline;

  FeeStructure({
    required this.id,
    required this.name,
    required this.amount,
    required this.feeType,
    required this.frequency,
    required this.deadline,
  });

  factory FeeStructure.fromJson(Map<String, dynamic> json) {
    return FeeStructure(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      feeType: json['fee_type'] ?? '',
      frequency: json['frequency'] ?? '',
      deadline: json['due_day']?.toString() ?? '', // Simplified mapping
    );
  }
}
