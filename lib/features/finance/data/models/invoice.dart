class Invoice {
  final String id;
  final String invoiceNumber;
  final String billingPeriod;
  final DateTime issueDate;
  final DateTime dueDate;
  final double totalAmount;
  final double paidAmount;
  final double dueAmount;
  final String status;
  final double totalTax;

  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.billingPeriod,
    required this.issueDate,
    required this.dueDate,
    required this.totalAmount,
    required this.paidAmount,
    required this.dueAmount,
    required this.status,
    required this.totalTax,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id']?.toString() ?? '',
      invoiceNumber: json['invoice_number'] ?? '',
      billingPeriod: json['billing_period'] ?? '',
      issueDate: DateTime.tryParse(json['issue_date'] ?? '') ?? DateTime.now(),
      dueDate: DateTime.tryParse(json['due_date'] ?? '') ?? DateTime.now(),
      totalAmount: double.tryParse(json['total_amount'].toString()) ?? 0.0,
      paidAmount: double.tryParse(json['paid_amount'].toString()) ?? 0.0,
      dueAmount: double.tryParse(json['due_amount'].toString()) ?? 0.0,
      status: json['status'] ?? 'DRAFT',
      totalTax: double.tryParse(json['total_tax'].toString()) ?? 0.0,
    );
  }

  bool get isPaid => status == 'PAID' || dueAmount <= 0;
}
