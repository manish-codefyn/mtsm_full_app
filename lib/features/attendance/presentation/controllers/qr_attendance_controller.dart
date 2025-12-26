import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/attendance_repository.dart';

class QRAttendanceController {
  final AttendanceRepository _repository;

  QRAttendanceController(this._repository);

  Future<Map<String, dynamic>> markAttendance({
    required String qrText,
    required String type,
    String? tripType,
  }) async {
    return await _repository.markQRAttendance(
      qrText: qrText,
      type: type,
      tripType: tripType,
    );
  }
}

final qrAttendanceControllerProvider = Provider<QRAttendanceController>((ref) {
  final repository = ref.watch(attendanceRepositoryProvider);
  return QRAttendanceController(repository);
});
