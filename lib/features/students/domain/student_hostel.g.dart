// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_hostel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudentHostel _$StudentHostelFromJson(Map<String, dynamic> json) =>
    StudentHostel(
      id: json['id'] as String?,
      student: json['student'] as String,
      hostelName: json['hostel_name'] as String?,
      roomNumber: json['room_number'] as String?,
      bedNumber: json['bed_number'] as String?,
      floor: (json['floor'] as num?)?.toInt(),
      roomType: json['room_type'] as String?,
      wardenName: json['warden_name'] as String?,
      wardenPhone: json['warden_phone'] as String?,
      monthlyFee: (json['monthly_fee'] as num?)?.toDouble(),
      admissionDate: json['admission_date'] as String?,
      checkoutDate: json['checkout_date'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      remarks: json['remarks'] as String?,
    );

Map<String, dynamic> _$StudentHostelToJson(StudentHostel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'student': instance.student,
      'hostel_name': instance.hostelName,
      'room_number': instance.roomNumber,
      'bed_number': instance.bedNumber,
      'floor': instance.floor,
      'room_type': instance.roomType,
      'warden_name': instance.wardenName,
      'warden_phone': instance.wardenPhone,
      'monthly_fee': instance.monthlyFee,
      'admission_date': instance.admissionDate,
      'checkout_date': instance.checkoutDate,
      'is_active': instance.isActive,
      'remarks': instance.remarks,
    };
