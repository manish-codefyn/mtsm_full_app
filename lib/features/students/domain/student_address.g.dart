// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_address.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudentAddress _$StudentAddressFromJson(Map<String, dynamic> json) =>
    StudentAddress(
      id: json['id'] as String?,
      student: json['student'] as String,
      addressType: json['address_type'] as String? ?? 'PERMANENT',
      addressLine1: json['address_line1'] as String,
      addressLine2: json['address_line2'] as String?,
      landmark: json['landmark'] as String?,
      city: json['city'] as String,
      state: json['state'] as String,
      pincode: json['pincode'] as String,
      country: json['country'] as String? ?? 'India',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isCurrent: json['is_current'] as bool? ?? true,
      isVerified: json['is_verified'] as bool? ?? false,
    );

Map<String, dynamic> _$StudentAddressToJson(StudentAddress instance) =>
    <String, dynamic>{
      'id': instance.id,
      'student': instance.student,
      'address_type': instance.addressType,
      'address_line1': instance.addressLine1,
      'address_line2': instance.addressLine2,
      'landmark': instance.landmark,
      'city': instance.city,
      'state': instance.state,
      'pincode': instance.pincode,
      'country': instance.country,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'is_current': instance.isCurrent,
      'is_verified': instance.isVerified,
    };
