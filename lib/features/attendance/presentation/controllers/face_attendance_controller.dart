import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/attendance_repository.dart';

class FaceAttendanceController {
  final AttendanceRepository _repository;

  FaceAttendanceController(this._repository);

  Future<Map<String, dynamic>> markAttendance({
    required String imageBase64,
    required String type,
    String? tripType,
  }) async {
    return await _repository.markFaceAttendance(
      imageBase64: imageBase64,
      type: type,
      tripType: tripType,
    );
  }
}

final faceAttendanceControllerProvider = Provider<FaceAttendanceController>((ref) {
  final repository = ref.watch(attendanceRepositoryProvider);
  return FaceAttendanceController(repository);
});
