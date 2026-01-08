import 'package:json_annotation/json_annotation.dart';

part 'student_address.g.dart';

@JsonSerializable()
class StudentAddress {
  final String? id;
  final String student; // Student ID
  @JsonKey(name: 'address_type')
  final String addressType;
  @JsonKey(name: 'address_line1')
  final String addressLine1;
  @JsonKey(name: 'address_line2')
  final String? addressLine2;
  final String? landmark;
  final String city;
  final String state;
  final String pincode;
  final String country;
  final double? latitude;
  final double? longitude;
  @JsonKey(name: 'is_current')
  final bool isCurrent;
  @JsonKey(name: 'is_verified')
  final bool isVerified;

  StudentAddress({
    this.id,
    required this.student,
    this.addressType = 'PERMANENT',
    required this.addressLine1,
    this.addressLine2,
    this.landmark,
    required this.city,
    required this.state,
    required this.pincode,
    this.country = 'India',
    this.latitude,
    this.longitude,
    this.isCurrent = true,
    this.isVerified = false,
  });

  factory StudentAddress.fromJson(Map<String, dynamic> json) => _$StudentAddressFromJson(json);
  Map<String, dynamic> toJson() => _$StudentAddressToJson(this);
}
