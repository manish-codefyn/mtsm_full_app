// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudentDocument _$StudentDocumentFromJson(Map<String, dynamic> json) =>
    StudentDocument(
      id: json['id'] as String,
      docType: json['doc_type'] as String,
      fileName: json['file_name'] as String?,
      fileUrl: json['file_url'] as String?,
      isVerified: json['is_verified'] as bool,
      rejectionReason: json['rejection_reason'] as String?,
    );

Map<String, dynamic> _$StudentDocumentToJson(StudentDocument instance) =>
    <String, dynamic>{
      'id': instance.id,
      'doc_type': instance.docType,
      'file_name': instance.fileName,
      'file_url': instance.fileUrl,
      'is_verified': instance.isVerified,
      'rejection_reason': instance.rejectionReason,
    };
