import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/stats_card.dart';
import '../../core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'presentation/dashboard_controller.dart';
import '../../core/theme/theme_controller.dart';
import '../auth/presentation/auth_controller.dart'; 
import '../../shared/widgets/dashboard_error_widget.dart';
import '../../shared/widgets/user_avatar.dart';
import '../communications/data/communication_repository.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: Drawer(
        elevation: 0,
        shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(topRight: Radius.circular(0), bottomRight: Radius.circular(0)),
        ),
        // backgroundColor: Theme.of(context).drawerTheme.backgroundColor, // Handled by Theme
        child: Column(
          children: [
             // Rocker Sidebar Header
             Container(
               height: 60,
               padding: const EdgeInsets.symmetric(horizontal: 16),
               decoration: const BoxDecoration(
                 border: Border(bottom: BorderSide(color: AppTheme.borderColor)),
               ),
               child: Row(
                 children: [
                   Image.asset('assets/images/app_logo.png', height: 30, errorBuilder: (_,__,___) => const Icon(Icons.school, color: AppTheme.primaryBlue, size: 30)),
                   const SizedBox(width: 10),
                   Expanded(
                     child: Text(
                       statsAsync.value?['tenantName'] ?? 'School ERP', 
                       style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                       overflow: TextOverflow.ellipsis,
                     ),
                   ),
                   // Toggle Icon (Visual only)
                   const Icon(Icons.arrow_back, size: 18, color: AppTheme.primaryBlue),
                 ],
               ),
             ),
             
             Expanded(
               child: SingleChildScrollView(
                 padding: const EdgeInsets.only(top: 10),
                 child: Column(
                   children: [
                     _buildDrawerItem(context, 'Dashboard', Icons.home_filled, onTap: () {}), // Current
                     _buildDrawerItem(context, 'Admission', Icons.person_add_alt_1_outlined, onTap: () => context.push('/admission')), // New
                     _buildDrawerItem(context, 'Analytics', Icons.analytics_outlined, onTap: () => context.push('/analytics')), // New
                     _buildDrawerItem(context, 'Students', Icons.people_outline_rounded, onTap: () => context.push('/students')),
                     _buildDrawerItem(context, 'Academics', Icons.school_outlined, onTap: () => context.push('/academics')),
                     _buildDrawerItem(context, 'Staff', Icons.badge_outlined, onTap: () => context.push('/hr/staff')),
                     _buildDrawerItem(context, 'Attendance', Icons.calendar_today_outlined, onTap: () => context.push('/attendance')),
                     _buildDrawerItem(context, 'Finance', Icons.account_balance_wallet_outlined, onTap: () => context.push('/finance')),
                     _buildDrawerItem(context, 'Transport', Icons.directions_bus_outlined, onTap: () => context.push('/transport')),
                     _buildDrawerItem(context, 'Hostel', Icons.bed_outlined, onTap: () => context.push('/hostel')),
                     _buildDrawerItem(context, 'Events', Icons.event_outlined, onTap: () => context.push('/events')),
                     _buildDrawerItem(context, 'Exams', Icons.assignment_outlined, onTap: () => context.push('/exams')),
                     _buildDrawerItem(context, 'Library', Icons.local_library_outlined, onTap: () => context.push('/library')), // New
                     _buildDrawerItem(context, 'Inventory', Icons.inventory_2_outlined, onTap: () => context.push('/inventory')), // New
                     _buildDrawerItem(context, 'Security', Icons.security_outlined, onTap: () => context.push('/security')), // New
                     _buildDrawerItem(context, 'Communications', Icons.chat_bubble_outline_rounded, onTap: () => context.push('/communications')),
                     _buildDrawerItem(context, 'Assignments', Icons.assignment_ind_outlined, onTap: () => context.push('/assignments')),
                     _buildDrawerItem(context, 'Users', Icons.manage_accounts_outlined, onTap: () => context.push('/users')), // New
                   ],
                 ),
               ),
             )
          ],
        ),
      ),
      body: statsAsync.when(
        data: (stats) {
          final user = stats['userProfile'] as Map<String, dynamic>?;
          final userName = user != null ? '${user['first_name']} ${user['last_name']}' : 'Admin User';
          final userAvatar = user?['avatar'];

          return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              floating: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Match scaffold
              elevation: 4,
              shadowColor: Theme.of(context).cardTheme.shadowColor,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu, color: AppTheme.primaryBlue),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              title: Text(
                'Dashboard', 
                style: GoogleFonts.roboto(color: AppTheme.textColor, fontWeight: FontWeight.bold),
              ),
              actions: [
                Stack(
                  children: [
                    IconButton(
                        icon: const Icon(Icons.notifications_outlined, color: AppTheme.primaryBlue),
                        onPressed: () {
                          // For now, simpler than full center, just show bottom sheet or dialog
                          _showNotificationSheet(context, ref);
                        },
                    ),
                    const Positioned(
                      right: 8,
                      top: 8,
                      child: CircleAvatar(
                        radius: 5,
                        backgroundColor: Colors.red,
                        child: Text('!', style: TextStyle(fontSize: 8, color: Colors.white)),
                      ),
                    )
                  ],
                ),
                Stack(
                  children: [
                     IconButton(
                        icon: const Icon(Icons.chat_bubble_outline, color: AppTheme.primaryBlue),
                        onPressed: () => context.push('/communications'),
                     ),
                     // ... Badge logic can be connected to real stats later
                  ],
                ),
                IconButton( // Theme Toggle
                  icon: Icon(
                    Theme.of(context).brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.yellow : const Color(0xFF5F5F5F),
                  ),
                  onPressed: () {
                    ref.read(themeControllerProvider.notifier).toggleTheme();
                  },
                ),
                InkWell(
                  onTap: () => context.push('/profile'),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: UserAvatar(name: userName, imageUrl: userAvatar, radius: 16),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.all(24),
               sliver: SliverGrid.count(
                 crossAxisCount: 2,
                 crossAxisSpacing: 16,
                 mainAxisSpacing: 16,
                 childAspectRatio: 1.5, // Adjusted for detailed stats
                 children: [
                   StatsCard(
                     title: 'Total Students',
                     value: stats['studentCount'].toString(),
                     icon: Icons.people_alt,
                     borderColor: const Color(0xFF14abef),
                     onTap: () => context.push('/students'),
                   ),
                   StatsCard(
                     title: 'Total Fees',
                     value: '\$${stats['feeCollection']}',
                     icon: Icons.account_balance_wallet,
                     borderColor: const Color(0xFFf41127),
                     onTap: () => context.push('/finance'),
                   ),
                   StatsCard(
                     title: 'Attendance',
                     value: '92.6%',
                     icon: Icons.bar_chart,
                     borderColor: const Color(0xFF17a00e),
                     onTap: () => context.push('/attendance'),
                   ),
                   StatsCard(
                     title: 'Total Staff',
                     value: stats['staffCount'].toString(),
                     icon: Icons.group,
                     borderColor: const Color(0xFFffc107),
                     onTap: () => context.push('/hr/staff'),
                   ),
                 ],
               ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              sliver: SliverToBoxAdapter(
                child: _buildSimpleChartSection(context),
              ),
            ),
             // Quick Actions Grid (Mobile Display)
             SliverPadding(
               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
               sliver: SliverGrid.count(
                 crossAxisCount: 4,
                 crossAxisSpacing: 12,
                 mainAxisSpacing: 12,
                 children: [
                    _buildQuickAction(context, Icons.person_add_alt_1, 'Admission', Colors.purple, () => context.push('/admission')),
                    _buildQuickAction(context, Icons.people, 'Students', Colors.blue, () => context.push('/students')),
                    _buildQuickAction(context, Icons.school, 'Academics', Colors.orange, () => context.push('/academics')),
                    _buildQuickAction(context, Icons.badge, 'Staff', Colors.teal, () => context.push('/hr/staff')),
                    _buildQuickAction(context, Icons.calendar_today, 'Attend.', Colors.green, () => context.push('/attendance')),
                    _buildQuickAction(context, Icons.account_balance_wallet, 'Fees', Colors.red, () => context.push('/finance')),
                    _buildQuickAction(context, Icons.directions_bus, 'Transp.', Colors.indigo, () => context.push('/transport')),
                    _buildQuickAction(context, Icons.event, 'Events', Colors.pink, () => context.push('/events')),
                 ],
               ),
             ),
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                   const SizedBox(height: 24),
                   Text(
                      "Quick Actions".toUpperCase(),
                      style: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFFB0AFAF), letterSpacing: 0.5),
                    ),
                   const SizedBox(height: 16),
                   _buildManagementTile(context, 'Academics', 'Classes, Subjects & TimeTable', Icons.school_outlined, Colors.indigo, () => context.push('/academics')),
                   _buildManagementTile(context, 'Transport', 'Routes, Vehicles & Drivers', Icons.directions_bus_outlined, Colors.blue, () => context.push('/transport')),
                   _buildManagementTile(context, 'Hostel', 'Rooms & Allocations', Icons.bed_outlined, Colors.teal, () => context.push('/hostel')),
                   const SizedBox(height: 40),
                ]),
              ),
            ),
          ],

        );
        },
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (err, stack) => DashboardErrorWidget(
          error: err, 
          onRetry: () => ref.refresh(dashboardStatsProvider),
        ),
      ),
    );
  }

  void _showNotificationSheet(BuildContext context, WidgetRef ref) {
     showModalBottomSheet(
       context: context,
       isScrollControlled: true, // Allow full height if needed
       shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
       builder: (context) {
         return FractionallySizedBox(
           heightFactor: 0.6,
           child: Padding(
             padding: const EdgeInsets.all(16),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     Text("Notifications", style: Theme.of(context).textTheme.titleLarge),
                     TextButton(
                       onPressed: () {
                          // Mark all read logic
                          Navigator.pop(context);
                       }, 
                       child: const Text("Mark all read")
                     ),
                   ],
                 ),
                 const Divider(),
                 Expanded(
                   child: Consumer(
                     builder: (context, ref, _) {
                       final notificationsAsync = ref.watch(notificationsProvider);
                       return notificationsAsync.when(
                         data: (notifications) {
                           if (notifications.isEmpty) {
                             return const Center(child: Text("No new notifications"));
                           }
                           return ListView.separated(
                             itemCount: notifications.length,
                             separatorBuilder: (_, __) => const Divider(),
                             itemBuilder: (context, index) {
                               final notif = notifications[index];
                               return ListTile(
                                 leading: const CircleAvatar(
                                   backgroundColor: AppTheme.primaryBlue, 
                                   radius: 4, 
                                   child: SizedBox(), // Dot
                                 ),
                                 title: Text(notif['title'] ?? 'Notification', style: const TextStyle(fontWeight: FontWeight.bold)),
                                 subtitle: Text(notif['message'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
                                 trailing: Text(
                                   notif['created_at'] != null ? notif['created_at'].toString().split('T')[0] : 'Now',
                                   style: const TextStyle(fontSize: 10, color: Colors.grey)
                                 ),
                               );
                             },
                           );
                         },
                         loading: () => const Center(child: CircularProgressIndicator()),
                         error: (err, stack) => Center(child: Text("Error: $err")),
                       );
                     },
                   ),
                 ),
                 SizedBox(
                   width: double.infinity,
                   child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
                 )
               ],
             ),
           ),
         );
       }
     );
  }

  Widget _buildDrawerItem(BuildContext context, String title, IconData icon, {required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: ListTile(
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
        leading: Icon(icon, color: Theme.of(context).iconTheme.color?.withOpacity(0.7), size: 22), 
        title: Text(title, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 15)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        hoverColor: Theme.of(context).primaryColor.withOpacity(0.05),
        // Note: Flutter standard ListTile hover doesn't support changing Icon color easily without state. 
        // For strict adherence we'd need a custom stateful widget, but this is close.
      ),
    );
  }

  Widget _buildAnalysisChart(BuildContext context) {
    return Card(
      elevation: 0,
       shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Theme.of(context).dividerTheme.color ?? Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Fee Collection", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "This Year",
                    style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBar(context, "Jan", 0.4),
                _buildBar(context, "Feb", 0.6),
                _buildBar(context, "Mar", 0.8),
                _buildBar(context, "Apr", 0.5),
                _buildBar(context, "May", 0.7),
                _buildBar(context, "Jun", 0.9),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBar(BuildContext context, String label, double pct) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 120 * pct,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            gradient: AppTheme.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildSimpleChartSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Attendance Overview', 
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          // Simple Bar Chart Placeholder
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildBarChartItem(context, 0.4, 'Mon'),
              _buildBarChartItem(context, 0.7, 'Tue'),
              _buildBarChartItem(context, 0.6, 'Wed'),
              _buildBarChartItem(context, 0.85, 'Thu'),
              _buildBarChartItem(context, 0.9, 'Fri'),
              _buildBarChartItem(context, 0.5, 'Sat'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarChartItem(BuildContext context, double heightPct, String label) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 150 * heightPct,
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withOpacity(0.8),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildQuickAction(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
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
          const SizedBox(height: 8),
          Text(
            label, 
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
            maxLines: 1, 
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildManagementTile(BuildContext context, String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade100),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle, style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 13)),
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
        onTap: onTap,
      ),
    );
  }
}

