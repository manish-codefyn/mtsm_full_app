class TransportRoute {
  final String id;
  final String name;
  final String startPoint;
  final String endPoint;
  final double fare;

  TransportRoute({
    required this.id,
    required this.name,
    required this.startPoint,
    required this.endPoint,
    required this.fare,
  });

  factory TransportRoute.fromJson(Map<String, dynamic> json) {
    return TransportRoute(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      startPoint: json['start_point'] ?? '',
      endPoint: json['end_point'] ?? '',
      fare: double.tryParse(json['fare']?.toString() ?? '0') ?? 0.0,
    );
  }
}
