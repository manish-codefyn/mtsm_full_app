import 'package:json_annotation/json_annotation.dart';

part 'student_transport.g.dart';

@JsonSerializable()
class StudentTransport {
  final String? id;
  final String student;
  
  @JsonKey(name: 'bus_route')
  final String? busRoute;
  
  @JsonKey(name: 'bus_stop')
  final String? busStop;
  
  @JsonKey(name: 'pickup_time')
  final String? pickupTime;
  
  @JsonKey(name: 'drop_time')
  final String? dropTime;
  
  @JsonKey(name: 'distance_km')
  final double? distanceKm;
  
  @JsonKey(name: 'monthly_fee')
  final double? monthlyFee;
  
  @JsonKey(name: 'is_active')
  final bool isActive;
  
  @JsonKey(name: 'emergency_contact')
  final String? emergencyContact;
  
  @JsonKey(name: 'emergency_phone')
  final String? emergencyPhone;
  
  final String? remarks;

  StudentTransport({
    this.id,
    required this.student,
    this.busRoute,
    this.busStop,
    this.pickupTime,
    this.dropTime,
    this.distanceKm,
    this.monthlyFee,
    this.isActive = true,
    this.emergencyContact,
    this.emergencyPhone,
    this.remarks,
  });

  factory StudentTransport.fromJson(Map<String, dynamic> json) => _$StudentTransportFromJson(json);
  Map<String, dynamic> toJson() => _$StudentTransportToJson(this);
}
