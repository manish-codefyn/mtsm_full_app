import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/academics_repository.dart';

class AcademicsDashboardScreen extends ConsumerWidget {
  const AcademicsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: Text(
          'Academics Dashboard',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(dashboardStatsProvider),
          ),
        ],
      ),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading dashboard: $err'),
              TextButton(
                onPressed: () => ref.refresh(dashboardStatsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (data) {
          final stats = data['stats'] as List<dynamic>;
          final meta = data['meta'] as Map<String, dynamic>;

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(dashboardStatsProvider),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meta Info Card
                  _buildMetaCard(context, meta),
                  const SizedBox(height: 24),
                  
                  // Quick Actions
                  Text(
                    'Quick Actions',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildActionCard(context, 'Academic Years', Icons.calendar_today_outlined, Colors.indigo, () => context.push('/academics/academic-years')),
                        const SizedBox(width: 16),
                        _buildActionCard(context, 'Terms', Icons.calendar_view_week, Colors.blueGrey, () => context.push('/academics/terms')),
                        const SizedBox(width: 16),
                        _buildActionCard(context, 'Streams', Icons.account_tree, Colors.lightBlue, () => context.push('/academics/streams')),
                        const SizedBox(width: 16),
                        _buildActionCard(context, 'Classes', Icons.class_outlined, Colors.purple, () => context.push('/academics/classes')),
                        const SizedBox(width: 16),
                        _buildActionCard(context, 'Sections', Icons.grid_view, Colors.orange, () => context.push('/academics/sections')),
                        const SizedBox(width: 16),
                        _buildActionCard(context, 'Subjects', Icons.book_outlined, Colors.blue, () => context.push('/academics/subjects')),
                        const SizedBox(width: 16),
                        _buildActionCard(context, 'Class Subjects', Icons.subject, Colors.cyan, () => context.push('/academics/class-subjects')),
                        const SizedBox(width: 16),
                        _buildActionCard(context, 'Timetable', Icons.schedule, Colors.teal, () => context.push('/academics/timetable')),
                        const SizedBox(width: 16),
                        _buildActionCard(context, 'Attendance', Icons.check_circle_outline, Colors.green, () => context.push('/attendance')),
                        const SizedBox(width: 16),
                        _buildActionCard(context, 'Holidays', Icons.beach_access, Colors.pink, () => context.push('/academics/holidays')),
                         const SizedBox(width: 16),
                        _buildActionCard(context, 'Syllabus', Icons.list_alt, Colors.deepPurple, () => context.push('/academics/syllabus')),
                        const SizedBox(width: 16),
                        _buildActionCard(context, 'Study Materials', Icons.library_books, Colors.brown, () => context.push('/academics/study-materials')),
                        const SizedBox(width: 16),
                        _buildActionCard(context, 'Houses', Icons.house, Colors.red, () => context.push('/academics/houses')),
                         const SizedBox(width: 16),
                        _buildActionCard(context, 'Grading', Icons.grade, Colors.amber, () => context.push('/academics/grading')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Overview',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stats Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.3,
                    ),
                    itemCount: stats.length,
                    itemBuilder: (context, index) {
                      final stat = stats[index];
                      return _buildStatCard(
                        context,
                        label: stat['label'],
                        value: stat['value'],
                        iconName: stat['icon'],
                        colorHex: stat['color'],
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetaCard(BuildContext context, Map<String, dynamic> meta) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Academic Session',
            style: GoogleFonts.outfit(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            meta['current_academic_year'] ?? 'N/A',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.people_outline, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Teacher Coverage',
                    style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    meta['teacher_coverage'] ?? '0/0',
                    style: GoogleFonts.outfit(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String label,
    required String value,
    required String iconName,
    required String colorHex,
  }) {
    // Parse color from hex string like "#RRGGBB"
    final color = Color(int.parse(colorHex.replaceAll('#', '0xff')));
    final iconData = _getIconData(iconName);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // TODO: Navigate to detail list
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(iconData, color: color, size: 24),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'class_outlined':
        return Icons.class_outlined;
      case 'grid_view':
        return Icons.grid_view;
      case 'book_outlined':
        return Icons.book_outlined;
      case 'house_outlined':
        return Icons.house_outlined;
      default:
        return Icons.dashboard_customize;
    }
  }


  Widget _buildActionCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      width: 140, // Fixed width for horizontal scroll items
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
