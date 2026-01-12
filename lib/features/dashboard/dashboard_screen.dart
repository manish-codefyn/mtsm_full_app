import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';
import 'presentation/dashboard_controller.dart';
import '../../shared/widgets/dashboard_error_widget.dart';
import '../../shared/widgets/user_avatar.dart';
import '../../shared/widgets/stats_card.dart';
import '../communications/presentation/notification_bell.dart';
import 'presentation/shortcuts_popup.dart';

// DashboardScreen now focuses purely on CONTENT.
// Navigation/Drawer/FAB are handled by MainScaffold (Shell).
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return statsAsync.when(
      data: (stats) {
        final user = stats['userProfile'] as Map<String, dynamic>?;
        final userName = user != null ? '${user['first_name']} ${user['last_name']}' : 'Admin User';
        final userAvatar = user?['avatar'];
        
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.primaryBlue.withOpacity(0.05),
                Theme.of(context).scaffoldBackgroundColor,
              ],
              stops: const [0.0, 0.3],
            )
          ),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. Customized Modern App Bar / Header
              SliverPadding(
                padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 20),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // TENANT BRANDING (NEW)
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryBlue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.school_rounded, color: AppTheme.primaryBlue, size: 20), 
                                  // TODO: Use Image.network(logoUrl) if available
                                ),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: Text(
                                    statsAsync.value?['tenantName'] ?? 'School ERP', 
                                    style: GoogleFonts.outfit(
                                      fontSize: 14, 
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryBlue
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            Text(
                              _getGreeting(),
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              userName,
                              style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Separator or Spacer could go here
                      Row(
                        children: [
                           const NotificationBell(),
                           const SizedBox(width: 12),
                           InkWell(
                            onTap: () => context.push('/profile'),
                            borderRadius: BorderRadius.circular(30),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.2), width: 2),
                              ),
                              child: UserAvatar(name: userName, imageUrl: userAvatar, radius: 24),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),

              // 2. Search / Universal Action Bar
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverToBoxAdapter(
                  child: _buildModernSearchBar(context),
                ),
              ),

              // 3. Stats Grid with Glassmorphism
              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverGrid.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.4,
                  children: [
                    _buildModernStatsCard(
                      context,
                      'Students',
                      stats['studentCount'].toString(),
                      Icons.school_outlined,
                      const Color(0xFF6366F1),
                      () => context.push('/students'),
                    ),
                    _buildModernStatsCard(
                      context,
                      'Staff',
                      stats['staffCount'].toString(),
                      Icons.badge_outlined,
                      const Color(0xFFEC4899),
                      () => context.push('/hr/staff'),
                    ),
                    _buildModernStatsCard(
                      context,
                      'Collections',
                      '₹${stats['feeCollection'] ?? 0}',
                      Icons.currency_rupee,
                      const Color(0xFF10B981),
                      () => context.push('/finance'),
                    ),
                     _buildModernStatsCard(
                      context,
                      'Attendance',
                      '92%',
                      Icons.calendar_today_outlined,
                      const Color(0xFFF59E0B),
                      () => context.push('/attendance'),
                    ),
                  ],
                ),
              ),

              // 4. Quick Actions Carousel (Horizontal)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                       _buildActionCircle(context, Icons.person_add_alt_1_rounded, 'Admission', Colors.blue, () => context.push('/admission')),
                       const SizedBox(width: 20),
                       _buildActionCircle(context, Icons.class_outlined, 'Classes', Colors.orange, () => context.push('/academics')),
                       const SizedBox(width: 20),
                       _buildActionCircle(context, Icons.assignment_outlined, 'Exams', Colors.purple, () => context.push('/exams')),
                       const SizedBox(width: 20),
                       _buildActionCircle(context, Icons.directions_bus_filled_outlined, 'Transport', Colors.indigo, () => context.push('/transport')),
                       const SizedBox(width: 20),
                       _buildActionCircle(context, Icons.bed_outlined, 'Hostel', Colors.teal, () => context.push('/hostel')),
                       const SizedBox(width: 20),
                       _buildActionCircle(context, Icons.event_note_rounded, 'Events', Colors.pink, () => context.push('/events')),
                       const SizedBox(width: 20),
                       _buildActionCircle(context, Icons.grid_view_rounded, 'View All', Colors.grey, () => _showShortcutsPopup(context)),
                    ],
                  ),
                ),
              ),
              
              const SliverPadding(padding: EdgeInsets.only(bottom: 24)),

              // 5. Analytics Section (Charts)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Text(
                         "Analytics Overview",
                         style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                       ),
                       const SizedBox(height: 16),
                       // Two column layout for larger screens, simplified for mobile
                       Row(
                         children: [
                           Expanded(child: _buildAttendanceChart(context)),
                         ],
                       ),
                       const SizedBox(height: 16),
                       _buildFeeChart(context, stats), // Passed stats
                    ],
                  ),
                ),
              ),

              const SliverPadding(padding: EdgeInsets.only(bottom: 100)), // Space for Bottom Nav
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => DashboardErrorWidget(
        error: err, 
        onRetry: () => ref.refresh(dashboardStatsProvider),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  Widget _buildModernSearchBar(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search students, staff, pages...",
          hintStyle: GoogleFonts.outfit(color: Colors.grey.shade400),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildModernStatsCard(BuildContext context, String title, String value, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.outfit(
                    fontSize: 22, 
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 12, 
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildActionCircle(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
  
  Widget _buildAttendanceChart(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
           BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Today's Attendance", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                     color: Colors.green.withOpacity(0.1),
                     borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text("+2.5%", style: GoogleFonts.outfit(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                )
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 150,
              child: BarChart(
                BarChartData(
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                     leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                     rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                     topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                     bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (val, meta) {
                             const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
                             if (val.toInt() >= 0 && val.toInt() < days.length) {
                               return Padding(
                                 padding: const EdgeInsets.only(top: 8.0),
                                 child: Text(days[val.toInt()], style: const TextStyle(fontSize: 10, color: Colors.grey)),
                               );
                             }
                             return const Text('');
                          },
                        )
                     ),
                  ),
                  barGroups: [
                    _makeBarGroup(0, 18, Colors.blue),
                    _makeBarGroup(1, 15, Colors.purple),
                    _makeBarGroup(2, 19, Colors.orange),
                    _makeBarGroup(3, 17, Colors.pink),
                    _makeBarGroup(4, 20, Colors.green),
                    _makeBarGroup(5, 12, Colors.teal),
                  ],
                )
              ),
            ),
        ],
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
         BarChartRodData(
            toY: y,
            color: color,
            width: 12, 
            borderRadius: BorderRadius.circular(6),
            backDrawRodData: BackgroundBarChartRodData(
               show: true,
               toY: 25, // Max value
               color: color.withOpacity(0.05),
            )
         ),
      ],
    );
  }

  Widget _buildFeeChart(BuildContext context, Map<String, dynamic> stats) {
    // Linked to real stats data
    return Container(
      height: 100, 
      width: double.infinity,
      decoration: BoxDecoration(
         color: AppTheme.primaryBlue,
         borderRadius: BorderRadius.circular(24),
         gradient: AppTheme.primaryGradient,
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
           Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               Text("Total Revenue", style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)),
               Text("₹${stats['feeCollection'] ?? 0}", style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
             ],
           ),
           const Spacer(),
           const Icon(Icons.show_chart, color: Colors.white, size: 40),
        ],
      ),
    );
  }

  void _showShortcutsPopup(BuildContext context) {
    showModalBottomSheet(
      context: context, 
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ShortcutsPopup(),
    );
  }
}
