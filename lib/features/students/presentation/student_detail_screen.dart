import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import '../domain/student.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/export_service.dart';
import 'student_medical_form_screen.dart';
import 'student_identification_form_screen.dart';
import 'student_wrapper_form_screen.dart';
import '../../attendance/presentation/providers/attendance_provider.dart';


class StudentDetailScreen extends ConsumerStatefulWidget {
  final Student student;

  const StudentDetailScreen({super.key, required this.student});

  @override
  ConsumerState<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends ConsumerState<StudentDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _buildAppBar(context),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Theme.of(context).primaryColor,
                  tabs: const [
                    Tab(text: 'Overview'),
                    Tab(text: 'Attendance'),
                    Tab(text: 'Results'),
                    Tab(text: 'Fees'),
                  ],
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(),
            _buildAttendanceTab(),
            _buildPlaceholderTab('Exam Results', Icons.grade_rounded),
            _buildPlaceholderTab('Fee History', Icons.monetization_on_rounded),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _generateAndPrintPdf(context, widget.student),
        label: const Text('Export PDF'),
        icon: const Icon(Icons.picture_as_pdf),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar.large(
      expandedHeight: 200,
      pinned: true,
      stretch: true,
      backgroundColor: Theme.of(context).primaryColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        title: Text(
          '${widget.student.firstName} ${widget.student.lastName}',
          style: const TextStyle(
            fontSize: 18, 
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [Shadow(color: Colors.black45, blurRadius: 2)],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(decoration: BoxDecoration(gradient: AppTheme.primaryGradient)),
            Center(
              child: Hero(
                tag: 'student_avatar_${widget.student.id}',
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  backgroundImage: widget.student.photo != null 
                      ? NetworkImage(_resolveImageUrl(widget.student.photo!)) 
                      : null,
                  onBackgroundImageError: (_, __) {
                    print("Error loading image for student: ${widget.student.photo}");
                  },
                  child: (widget.student.photo == null || widget.student.firstName.isEmpty) 
                      ? Text(
                          widget.student.firstName.isNotEmpty ? widget.student.firstName[0] : '?',
                          style: TextStyle(fontSize: 40, color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.white),
          tooltip: 'Edit Student',
          onPressed: () {
             Navigator.push(
               context, 
               MaterialPageRoute(builder: (_) => StudentWrapperFormScreen(student: widget.student))
             ).then((_) {
                // Ideally refresh provider here
                setState(() {});
             });
          }, 
        ),
      ],
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
           if (widget.student.onboardingSummary != null) ...[
             _buildOnboardingProgressCard(),
             const SizedBox(height: 20),
           ],
           _buildSummaryCard(context),
           const SizedBox(height: 20),
           _buildSectionTitle('Personal Information'),
           _buildInfoCard([
             _InfoItem('Gender', widget.student.gender ?? 'N/A', Icons.person),
             _InfoItem('Date of Birth', widget.student.dateOfBirth ?? 'N/A', Icons.cake),
             _InfoItem('Mobile', widget.student.mobilePrimary ?? 'N/A', Icons.phone),
             _InfoItem('Email', widget.student.email ?? 'N/A', Icons.email),
           ]),
           const SizedBox(height: 20),
           _buildSectionTitle('Academic Information'),
           _buildInfoCard([
             _InfoItem('Admission Number', widget.student.admissionNumber ?? 'N/A', Icons.badge),
             _InfoItem('Academic Year', '2025-2026', Icons.calendar_today), 
             _InfoItem('Status', 'Active', Icons.check_circle, color: Colors.green),
           ]),
           const SizedBox(height: 20),
           _buildSectionTitle('Parent Information'),
           _buildInfoCard([
             _InfoItem('Father Name', widget.student.fatherName ?? 'N/A', Icons.person),
             _InfoItem('Mother Name', widget.student.motherName ?? 'N/A', Icons.person_outline),
           ]),
           const SizedBox(height: 20),
           _buildSectionTitle('Address'),
           _buildInfoCard([
             _InfoItem('Current Address', widget.student.currentAddress ?? 'N/A', Icons.location_on),
             _InfoItem('Permanent Address', widget.student.permanentAddress ?? 'N/A', Icons.home),
           ]),
        ],
      ),
    );
  }

  Widget _buildAttendanceTab() {
    return Consumer(
      builder: (context, ref, child) {
        final attendanceAsync = ref.watch(studentAttendanceProvider(widget.student.id!));
        
        return attendanceAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (data) {
            if (data.isEmpty) {
              return const Center(child: Text("No attendance records found"));
            }
             return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final record = data[index];
                final status = record['status'] ?? 'PRESENT';
                final date = record['date'] ?? 'N/A';
                final color = status == 'PRESENT' ? Colors.green : (status == 'ABSENT' ? Colors.red : Colors.orange);
                
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey.shade200)
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color.withOpacity(0.1),
                      child: Icon(
                        status == 'PRESENT' ? Icons.check : (status == 'ABSENT' ? Icons.close : Icons.access_time),
                        color: color,
                        size: 20
                      ),
                    ),
                    title: Text(DateFormat('yyyy-MM-dd').format(DateTime.parse(date)), style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(status),
                    trailing: Text(record['remarks'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ),
                );
              },
            );
          },
        );
      }
    );
  }

  String _resolveImageUrl(String path) {
    if (path.startsWith('http')) return path;
    final cleanPath = path.startsWith('/') ? path : '/$path';
    final url = "http://127.0.0.1:8000$cleanPath";
    print("Resolved Image URL: $url");
    return url;
  }

  Widget _buildPlaceholderTab(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Coming Soon', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // ... (Keep existing helpers _buildSummaryCard, _buildStatItem, _buildSectionTitle, _buildInfoCard, _generateAndPrintPdf) ...
  // Re-implementing helpers to ensure context and widget access is correct in new state class
  
  Widget _buildSummaryCard(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.blue.withOpacity(0.1)),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(context, 'Attendance', '95%', Colors.green),
            _buildStatItem(context, 'Grade', 'A', Colors.blue),
            _buildStatItem(context, 'Fees', 'Paid', Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget _buildInfoCard(List<_InfoItem> items) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: items.map((item) => ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (item.color ?? Colors.grey).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(item.icon, color: item.color ?? Colors.grey[700], size: 20),
            ),
            title: Text(item.label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            subtitle: Text(item.value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
          )).toList(),
        ),
      ),
    );
  }

  Future<void> _generateAndPrintPdf(BuildContext context, Student student) async {
    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Generating PDF...')),
        );
      }
      await ExportService.exportProfileToPdf(context, student);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating PDF: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildOnboardingProgressCard() {
    final summary = widget.student.onboardingSummary!;
    final progress = (summary['progress'] as num?)?.toDouble() ?? 0.0;
    final steps = (summary['steps'] as List?) ?? [];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Onboarding Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('${progress.toInt()}%', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 16),
            ...steps.map((step) {
              final isCompleted = step['is_completed'] as bool? ?? false;
              final title = step['title'] as String? ?? '';
              final id = step['id'] as String? ?? '';
              
              return InkWell(
                onTap: () => _handleStepTap(id),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Row(
                    children: [
                      Icon(
                        isCompleted ? Icons.check_circle : Icons.circle_outlined,
                        color: isCompleted ? Colors.green : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title, 
                          style: TextStyle(
                            color: isCompleted ? Colors.black87 : Colors.grey[800],
                            fontWeight: isCompleted ? FontWeight.w500 : FontWeight.normal,
                          ),
                        ),
                      ),
                       const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _handleStepTap(String stepId) {
     Widget? screen;
     switch(stepId) {
       case 'basic':
         // Navigate to Basic Edit
          screen = StudentWrapperFormScreen(student: widget.student); 
          break;
       case 'medical':
          screen = StudentMedicalFormScreen(studentId: widget.student.id!);
          break;
       case 'identification':
          screen = StudentIdentificationFormScreen(studentId: widget.student.id!);
          break;
       // Add other cases as screens are built
     }
     
     if (screen != null) {
       Navigator.push(context, MaterialPageRoute(builder: (_) => screen!)).then((_) {
          // Trigger a refresh of the student details
          // simpler to just call setState if we re-fetch, but ideally we call a provider refresh
          setState(() {}); 
       });
     } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Screen not implemented yet')));
     }
  }
}

class _InfoItem {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;
  _InfoItem(this.label, this.value, this.icon, {this.color});
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
