// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_transport.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudentTransport _$StudentTransportFromJson(Map<String, dynamic> json) =>
    StudentTransport(
      id: json['id'] as String?,
      student: json['student'] as String,
      busRoute: json['bus_route'] as String?,
      busStop: json['bus_stop'] as String?,
      pickupTime: json['pickup_time'] as String?,
      dropTime: json['drop_time'] as String?,
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      monthlyFee: (json['monthly_fee'] as num?)?.toDouble(),
      isActive: json['is_active'] as bool? ?? true,
      emergencyContact: json['emergency_contact'] as String?,
      emergencyPhone: json['emergency_phone'] as String?,
      remarks: json['remarks'] as String?,
    );

Map<String, dynamic> _$StudentTransportToJson(StudentTransport instance) =>
    <String, dynamic>{
      'id': instance.id,
      'student': instance.student,
      'bus_route': instance.busRoute,
      'bus_stop': instance.busStop,
      'pickup_time': instance.pickupTime,
      'drop_time': instance.dropTime,
      'distance_km': instance.distanceKm,
      'monthly_fee': instance.monthlyFee,
      'is_active': instance.isActive,
      'emergency_contact': instance.emergencyContact,
      'emergency_phone': instance.emergencyPhone,
      'remarks': instance.remarks,
    };
