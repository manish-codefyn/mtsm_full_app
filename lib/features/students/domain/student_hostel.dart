import 'package:json_annotation/json_annotation.dart';

part 'student_hostel.g.dart';

@JsonSerializable()
class StudentHostel {
  final String? id;
  final String student;
  
  @JsonKey(name: 'hostel_name')
  final String? hostelName;
  
  @JsonKey(name: 'room_number')
  final String? roomNumber;
  
  @JsonKey(name: 'bed_number')
  final String? bedNumber;
  
  @JsonKey(name: 'floor')
  final int? floor;
  
  @JsonKey(name: 'room_type')
  final String? roomType; // SINGLE, DOUBLE, TRIPLE, DORMITORY
  
  @JsonKey(name: 'warden_name')
  final String? wardenName;
  
  @JsonKey(name: 'warden_phone')
  final String? wardenPhone;
  
  @JsonKey(name: 'monthly_fee')
  final double? monthlyFee;
  
  @JsonKey(name: 'admission_date')
  final String? admissionDate;
  
  @JsonKey(name: 'checkout_date')
  final String? checkoutDate;
  
  @JsonKey(name: 'is_active')
  final bool isActive;
  
  final String? remarks;

  StudentHostel({
    this.id,
    required this.student,
    this.hostelName,
    this.roomNumber,
    this.bedNumber,
    this.floor,
    this.roomType,
    this.wardenName,
    this.wardenPhone,
    this.monthlyFee,
    this.admissionDate,
    this.checkoutDate,
    this.isActive = true,
    this.remarks,
  });

  factory StudentHostel.fromJson(Map<String, dynamic> json) => _$StudentHostelFromJson(json);
  Map<String, dynamic> toJson() => _$StudentHostelToJson(this);
}
