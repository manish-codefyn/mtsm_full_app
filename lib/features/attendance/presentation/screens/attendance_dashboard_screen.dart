import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/attendance_stat_card.dart';
import '../widgets/quick_action_button.dart';
import '../../data/models/attendance.dart';
import '../../data/models/attendance_stats.dart';
import '../controllers/attendance_dashboard_controller.dart';
import 'qr_attendance_screen.dart';
import 'face_attendance_screen.dart';

class AttendanceDashboardScreen extends ConsumerWidget {
  const AttendanceDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(attendanceDashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Dashboard'),
        centerTitle: true,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(attendanceDashboardProvider);
        },
        child: dashboardAsync.when(
          data: (dashboard) => _buildDashboard(context, dashboard),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error loading dashboard: $err'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(attendanceDashboardProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, Map<String, dynamic> dashboard) {
    final stats = dashboard['stats'] as Map<String, dynamic>?;
    final recentList = dashboard['recent_attendance'] as List?;
    
    final studentStats = stats?['student'] != null 
        ? AttendanceStats.fromJson(stats!['student']) 
        : AttendanceStats.empty();
    final staffStats = stats?['staff'] != null 
        ? AttendanceStats.fromJson(stats!['staff']) 
        : AttendanceStats.empty();
    final hostelStats = stats?['hostel'] != null 
        ? AttendanceStats.fromJson(stats!['hostel']) 
        : AttendanceStats.empty();
    final transportStats = stats?['transport'] != null 
        ? AttendanceStats.fromJson(stats!['transport']) 
        : AttendanceStats.empty();

    final recentRecords = recentList?.map((json) => Attendance.fromJson(json)).toList() ?? [];

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Today\'s Overview',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Student Attendance Section
          _buildAttendanceSection(
            context,
            'Student Attendance',
            studentStats,
            Colors.blue,
            Icons.school,
          ),
          const SizedBox(height: 16),

          // Staff Attendance Section
          _buildAttendanceSection(
            context,
            'Staff Attendance',
            staffStats,
            Colors.purple,
            Icons.badge,
          ),
          const SizedBox(height: 16),

          // Hostel Attendance Section
          _buildAttendanceSection(
            context,
            'Hostel Attendance',
            hostelStats,
            Colors.orange,
            Icons.hotel,
          ),
          const SizedBox(height: 16),

          // Transport Attendance Section
          _buildAttendanceSection(
            context,
            'Transport Attendance',
            transportStats,
            Colors.teal,
            Icons.directions_bus,
          ),
          const SizedBox(height: 24),

          // Recent Activity
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to full list
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (recentRecords.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('No recent attendance records'),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentRecords.length > 5 ? 5 : recentRecords.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final record = recentRecords[index];
                return _buildAttendanceCard(context, record);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildAttendanceSection(
    BuildContext context,
    String title,
    AttendanceStats stats,
    Color color,
    IconData icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${stats.present}/${stats.total} Present (${stats.percentage.toStringAsFixed(1)}%)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Stats Row
          Row(
            children: [
              Expanded(
                child: _buildMiniStatCard(
                  'Present',
                  stats.present.toString(),
                  Colors.green,
                  Icons.check_circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMiniStatCard(
                  'Absent',
                  stats.absent.toString(),
                  Colors.red,
                  Icons.cancel,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMiniStatCard(
                  'Late',
                  stats.late.toString(),
                  Colors.orange,
                  Icons.access_time,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Quick Actions
          Row(
            children: [
              Expanded(
                child: _buildQuickActionChip(
                  'QR Scan',
                  Icons.qr_code_scanner,
                  color,
                  () => _navigateToQRScanner(context, title.split(' ')[0].toLowerCase()),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildQuickActionChip(
                  'Face Scan',
                  Icons.face,
                  color,
                  () => _navigateToFaceScanner(context, title.split(' ')[0].toLowerCase()),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildQuickActionChip(
                  'View All',
                  Icons.list,
                  color,
                  () => _navigateToViewAll(context, title.split(' ')[0].toLowerCase()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionChip(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToQRScanner(BuildContext context, String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRAttendanceScreen(initialType: type),
      ),
    );
  }

  void _navigateToFaceScanner(BuildContext context, String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FaceAttendanceScreen(initialType: type),
      ),
    );
  }

  void _navigateToViewAll(BuildContext context, String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('View all $type attendance - Coming soon!')),
    );
  }

  Widget _buildAttendanceCard(BuildContext context, Attendance record) {
    Color statusColor = Colors.grey;
    if (record.status == 'PRESENT') statusColor = Colors.green;
    if (record.status == 'ABSENT') statusColor = Colors.red;
    if (record.status == 'LATE') statusColor = Colors.orange;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.check_circle, color: statusColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.studentName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${record.type.toUpperCase()} • ${record.className} • ${record.date}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                if (record.tripType != null)
                  Text(
                    'Trip: ${record.tripType}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.blue,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              record.status,
              style: TextStyle(
                fontSize: 12,
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
