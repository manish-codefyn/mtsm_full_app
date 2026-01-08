import 'package:json_annotation/json_annotation.dart';

part 'student_document.g.dart';

@JsonSerializable()
class StudentDocument {
  final String id;
  @JsonKey(name: 'doc_type')
  final String docType;
  @JsonKey(name: 'file_name')
  final String? fileName;
  @JsonKey(name: 'file_url')
  final String? fileUrl;
  @JsonKey(name: 'is_verified')
  final bool isVerified;
  @JsonKey(name: 'rejection_reason')
  final String? rejectionReason;

  StudentDocument({
    required this.id,
    required this.docType,
    this.fileName,
    this.fileUrl,
    required this.isVerified,
    this.rejectionReason,
  });

  factory StudentDocument.fromJson(Map<String, dynamic> json) => _$StudentDocumentFromJson(json);
  Map<String, dynamic> toJson() => _$StudentDocumentToJson(this);
}
