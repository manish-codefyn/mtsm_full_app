import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../controllers/qr_attendance_controller.dart';

class QRAttendanceScreen extends ConsumerStatefulWidget {
  final String? initialType;
  
  const QRAttendanceScreen({super.key, this.initialType});

  @override
  ConsumerState<QRAttendanceScreen> createState() => _QRAttendanceScreenState();
}

class _QRAttendanceScreenState extends ConsumerState<QRAttendanceScreen> {
  late String selectedType;
  String? selectedTripType;
  MobileScannerController cameraController = MobileScannerController();
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    selectedType = widget.initialType ?? 'student';
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Attendance'),
        actions: [
          IconButton(
            icon: Icon(cameraController.torchEnabled ? Icons.flash_on : Icons.flash_off),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
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

          // Camera Scanner
          Expanded(
            child: Stack(
              children: [
                MobileScanner(
                  controller: cameraController,
                  onDetect: (capture) {
                    if (!isProcessing) {
                      final List<Barcode> barcodes = capture.barcodes;
                      if (barcodes.isNotEmpty) {
                        final String? code = barcodes.first.rawValue;
                        if (code != null) {
                          _handleQRCode(code);
                        }
                      }
                    }
                  },
                ),
                // Scanning overlay
                Center(
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                // Instructions
                Positioned(
                  bottom: 50,
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
                      'Align QR code within the frame\n${selectedType == 'transport' && selectedTripType == null ? 'Please select trip type first' : 'Scanning for ${selectedType.toUpperCase()}'}',
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

  void _handleQRCode(String qrCode) async {
    if (selectedType == 'transport' && selectedTripType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select trip type (Pickup/Drop)')),
      );
      return;
    }

    setState(() {
      isProcessing = true;
    });

    try {
      final controller = ref.read(qrAttendanceControllerProvider);
      final result = await controller.markAttendance(
        qrText: qrCode,
        type: selectedType,
        tripType: selectedTripType,
      );

      if (mounted) {
        // Show success dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 32),
                SizedBox(width: 12),
                Text('Success'),
              ],
            ),
            content: Text(result['message'] ?? 'Attendance marked successfully'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    isProcessing = false;
                  });
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
        setState(() {
          isProcessing = false;
        });
      }
    }
  }
}
