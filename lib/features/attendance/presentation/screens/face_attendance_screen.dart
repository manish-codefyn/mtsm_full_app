import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import '../controllers/face_attendance_controller.dart';

class FaceAttendanceScreen extends ConsumerStatefulWidget {
  final String? initialType;
  
  const FaceAttendanceScreen({super.key, this.initialType});

  @override
  ConsumerState<FaceAttendanceScreen> createState() => _FaceAttendanceScreenState();
}

class _FaceAttendanceScreenState extends ConsumerState<FaceAttendanceScreen> {
  late String selectedType;
  String? selectedTripType;
  CameraController? cameraController;
  List<CameraDescription>? cameras;
  bool isProcessing = false;
  bool isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    selectedType = widget.initialType ?? 'student';
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras != null && cameras!.isNotEmpty) {
        cameraController = CameraController(
          cameras![0],
          ResolutionPreset.medium,
        );
        await cameraController!.initialize();
        if (mounted) {
          setState(() {
            isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Recognition Attendance'),
      ),
      body: Column(
        children: [
          // Type Selector
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildTypeChip('student', 'Student', Icons.school, Colors.blue),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTypeChip('staff', 'Staff', Icons.badge, Colors.purple),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildTypeChip('hostel', 'Hostel', Icons.hotel, Colors.orange),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTypeChip('transport', 'Transport', Icons.directions_bus, Colors.teal),
                    ),
                  ],
                ),
                if (selectedType == 'transport') ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTripTypeChip('PICKUP', 'Pickup', Icons.arrow_upward),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildTripTypeChip('DROP', 'Drop', Icons.arrow_downward),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Camera Preview
          Expanded(
            child: isCameraInitialized && cameraController != null
                ? Stack(
                    children: [
                      Center(
                        child: AspectRatio(
                          aspectRatio: cameraController!.value.aspectRatio,
                          child: CameraPreview(cameraController!),
                        ),
                      ),
                      // Face overlay
                      Center(
                        child: Container(
                          width: 250,
                          height: 300,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 3),
                            borderRadius: BorderRadius.circular(125),
                          ),
                        ),
                      ),
                      // Instructions
                      Positioned(
                        top: 50,
                        left: 0,
                        right: 0,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 32),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Position your face within the oval\n${selectedType == 'transport' && selectedTripType == null ? 'Please select trip type first' : 'Scanning for ${selectedType.toUpperCase()}'}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      if (isProcessing)
                        Container(
                          color: Colors.black.withOpacity(0.5),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                    ],
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
          ),

          // Capture Button
          Container(
            padding: const EdgeInsets.all(24),
            child: ElevatedButton(
              onPressed: isProcessing ? null : _captureAndProcess,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.camera_alt, size: 24),
                  SizedBox(width: 12),
                  Text('Capture & Mark Attendance', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String type, String label, IconData icon, Color color) {
    final isSelected = selectedType == type;
    return InkWell(
      onTap: () {
        setState(() {
          selectedType = type;
          if (type != 'transport') {
            selectedTripType = null;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.grey.shade600, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripTypeChip(String tripType, String label, IconData icon) {
    final isSelected = selectedTripType == tripType;
    return InkWell(
      onTap: () {
        setState(() {
          selectedTripType = tripType;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.teal : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.grey.shade600, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade600,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _captureAndProcess() async {
    if (selectedType == 'transport' && selectedTripType == null) {
      _showErrorDialog(
        'Trip Type Required',
        'Please select whether this is a Pickup or Drop trip.',
        Icons.warning_amber_rounded,
        Colors.orange,
      );
      return;
    }

    if (cameraController == null || !cameraController!.value.isInitialized) {
      _showErrorDialog(
        'Camera Error',
        'Camera is not initialized. Please restart the app.',
        Icons.camera_alt_outlined,
        Colors.red,
      );
      return;
    }

    setState(() {
      isProcessing = true;
    });

    try {
      final XFile imageFile = await cameraController!.takePicture();
      final Uint8List imageBytes = await imageFile.readAsBytes();
      
      // Convert to base64
      final String base64Image = base64Encode(imageBytes);

      final controller = ref.read(faceAttendanceControllerProvider);
      final result = await controller.markAttendance(
        imageBase64: base64Image,
        type: selectedType,
        tripType: selectedTripType,
      );

      if (mounted) {
        _showSuccessDialog(result);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'An unexpected error occurred. Please try again.';
        String suggestion = '';
        
        if (e.toString().contains('404')) {
          errorMessage = 'No matching person found';
          suggestion = 'Please ensure the person has a profile photo in the system.';
        } else if (e.toString().contains('500')) {
          errorMessage = 'Server error occurred';
          suggestion = 'Please contact support if this persists.';
        } else if (e.toString().contains('No staff')) {
          errorMessage = 'No staff members found';
          suggestion = 'Please ensure staff members have profile photos uploaded.';
        } else if (e.toString().contains('No students')) {
          errorMessage = 'No students found';
          suggestion = 'Please ensure students have profile photos uploaded.';
        }
        
        _showErrorDialog(
          errorMessage,
          suggestion.isNotEmpty ? suggestion : e.toString(),
          Icons.error_outline,
          Colors.red,
        );
        
        setState(() {
          isProcessing = false;
        });
      }
    }
  }

  void _showSuccessDialog(Map<String, dynamic> result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [Colors.green.shade50, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: Colors.green, size: 48),
              ),
              const SizedBox(height: 20),
              const Text(
                'Success!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 12),
              if (result['student_name'] != null)
                Text(
                  result['student_name'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 8),
              Text(
                result['message'] ?? 'Attendance marked successfully',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              if (result['photo_url'] != null) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    result['photo_url'],
                    height: 120,
                    width: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.person, size: 60),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    isProcessing = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Done', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(String title, String message, IconData icon, Color color) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 48),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('OK', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
