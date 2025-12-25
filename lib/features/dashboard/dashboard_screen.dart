import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/stats_card.dart';
import '../../core/theme/app_theme.dart';
import 'presentation/dashboard_controller.dart';
import '../../core/theme/theme_controller.dart';
import '../auth/presentation/auth_controller.dart'; // From features/dashboard to features/auth

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      drawer: NavigationDrawer(
        onDestinationSelected: (index) {
          Navigator.pop(context); // Close drawer
          switch (index) {
            case 0: break;
            case 1: context.push('/students'); break;
            case 2: context.push('/academics'); break;
            case 3: context.push('/hr/staff'); break;
            case 4: context.push('/attendance'); break;
            case 5: context.push('/finance/fees'); break;
            case 6: context.push('/transport'); break;
            case 7: context.push('/hostel'); break;
          }
        },
        children: const [
          Padding(
            padding: EdgeInsets.fromLTRB(28, 16, 16, 10),
            child: Text('Menu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          NavigationDrawerDestination( icon: Icon(Icons.dashboard_rounded), label: Text('Dashboard')),
          NavigationDrawerDestination( icon: Icon(Icons.people_rounded), label: Text('Students')),
          NavigationDrawerDestination( icon: Icon(Icons.school_rounded), label: Text('Academics')),
          NavigationDrawerDestination( icon: Icon(Icons.people_outline_rounded), label: Text('Staff')),
          NavigationDrawerDestination( icon: Icon(Icons.calendar_today_rounded), label: Text('Attendance')),
          NavigationDrawerDestination( icon: Icon(Icons.account_balance_wallet_rounded), label: Text('Finance')),
          NavigationDrawerDestination( icon: Icon(Icons.directions_bus_rounded), label: Text('Transport')),
          NavigationDrawerDestination( icon: Icon(Icons.bed_rounded), label: Text('Hostel')),
        ],
      ),
      body: statsAsync.when(
        data: (stats) => CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar.large(
              expandedHeight: 120,
              pinned: true,
              stretch: true,
              backgroundColor: Theme.of(context).primaryColor,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Dashboard',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                  ),
                ),
              ),
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu_rounded, color: Colors.white),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.dark_mode_outlined, color: Colors.white),
                  onPressed: () => ref.read(themeControllerProvider.notifier).toggleTheme(),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.person_outline_rounded, color: Colors.white),
                  onSelected: (value) {
                    if (value == 'logout') {
                      ref.read(authControllerProvider.notifier).logout();
                      context.go('/login');
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'profile', child: Text('Profile')),
                    const PopupMenuItem(value: 'settings', child: Text('Settings')),
                    const PopupMenuItem(value: 'logout', child: Text('Logout')),
                  ],
                ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (stats['tenantName'] != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Text(
                          'Welcome back, ${stats['tenantName']}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.grey[800],
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    
                    const Text(
                      "Overview",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85, // Taller cards
                children: [
                  StatsCard(
                    title: 'Students',
                    value: stats['studentCount'].toString(),
                    icon: Icons.people_rounded,
                    onTap: () => context.push('/students'),
                  ),
                  StatsCard(
                    title: 'Staff',
                    value: stats['staffCount'].toString(),
                    icon: Icons.people_outline_rounded,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                    ),
                    onTap: () => context.push('/hr/staff'),
                  ),
                  StatsCard(
                    title: 'Attendance',
                    value: '92%',
                    icon: Icons.check_circle_outline_rounded,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                    ),
                    onTap: () => context.push('/attendance'),
                  ),
                  StatsCard(
                    title: 'Fees',
                    value: stats['feeCollection'].toString(),
                    icon: Icons.attach_money_rounded,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEC4899), Color(0xFFDB2777)],
                    ),
                    onTap: () => context.push('/finance/fees'),
                  ),
                ],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                   const SizedBox(height: 24),
                   const Text(
                     "Analysis",
                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                   ),
                   const SizedBox(height: 16),
                   _buildAnalysisChart(context),
                   const SizedBox(height: 24),
                   const Text(
                     "Quick Actions",
                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                   ),
                   const SizedBox(height: 16),
                   _buildManagementTile(context, 'Academics', 'Classes, Subjects & TimeTable', Icons.school_rounded, Colors.indigo, () => context.push('/academics')),
                   _buildManagementTile(context, 'Transport', 'Routes, Vehicles & Drivers', Icons.directions_bus_rounded, Colors.blue, () => context.push('/transport')),
                   _buildManagementTile(context, 'Hostel', 'Rooms & Allocations', Icons.bed_rounded, Colors.teal, () => context.push('/hostel')),
                   const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
      ),
    );
  }

  Widget _buildAnalysisChart(BuildContext context) {
    return Card(
      elevation: 0,
       shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade200),
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
          child: Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
        onTap: onTap,
      ),
    );
  }
}
