import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../features/dashboard/presentation/dashboard_controller.dart';
import '../../features/dashboard/presentation/shortcuts_popup.dart';

class MainScaffold extends ConsumerStatefulWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/academics')) return 1;
    if (location.startsWith('/students')) return 2;
    if (location.startsWith('/profile')) return 3;
    if (location == '/') return 0;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/academics');
        break;
      case 2:
        context.go('/students');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch tenant stats for drawer info
    final statsAsync = ref.watch(dashboardStatsProvider);
    final tenantName = statsAsync.value?['tenantName'] ?? 'School ERP';
    
    // Determine strict color branding
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final selectedItemColor = AppTheme.primaryBlue;
    final unselectedItemColor = Colors.grey.shade500;

    return Scaffold(
      extendBody: false, // Prevent content overlap with BottomAppBar
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: _buildDrawer(context, tenantName),
      body: widget.child,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showShortcutsPopup(context),
        backgroundColor: AppTheme.primaryBlue,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.grid_view_rounded, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          color: navBgColor,
          elevation: 10,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.black.withOpacity(0.1),
          height: 80, // Explicit height for BottomAppBar
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavItem(context, 0, Icons.home_rounded, Icons.home_outlined, 'Home'),
                _buildNavItem(context, 1, Icons.school, Icons.school_outlined, 'Academics'),
                const SizedBox(width: 48), // Space for FAB
                _buildNavItem(context, 2, Icons.people, Icons.people_outline, 'Students'),
                _buildNavItem(context, 3, Icons.person, Icons.person_outline, 'Profile'),
              ],
            ),
          ),
        ),
      );
    }
  
    Widget _buildNavItem(BuildContext context, int index, IconData activeIcon, IconData inactiveIcon, String label) {
      final selectedIndex = _calculateSelectedIndex(context);
      final isSelected = selectedIndex == index;
      
      return InkWell(
        onTap: () => _onItemTapped(index, context),
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0), // Reduced vertical padding
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               AnimatedContainer(
                 duration: const Duration(milliseconds: 200),
                 padding: const EdgeInsets.all(4),
                 decoration: isSelected 
                   ? BoxDecoration(
                       color: AppTheme.primaryBlue.withOpacity(0.1),
                       borderRadius: BorderRadius.circular(12)
                     )
                   : null,
                 child: Icon(
                  isSelected ? activeIcon : inactiveIcon,
                  color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade500,
                  size: 24,
                ),
               ),
              if (isSelected) 
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryBlue,
                  ),
                )
            ],
          ),
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

  Widget _buildDrawer(BuildContext context, String tenantName) {
    return Drawer(
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(topRight: Radius.circular(0), bottomRight: Radius.circular(0)),
      ),
      child: Column(
        children: [
           Container(
             height: 120, // Taller header for logo
             padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
             decoration: BoxDecoration(
               color: AppTheme.primaryBlue.withOpacity(0.05),
               border: const Border(bottom: BorderSide(color: AppTheme.borderColor)),
             ),
             child: Row(
               crossAxisAlignment: CrossAxisAlignment.center,
               children: [
                 Container(
                   width: 50,
                   height: 50,
                   decoration: BoxDecoration(
                     color: Colors.white,
                     borderRadius: BorderRadius.circular(12),
                     boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
                   ),
                   child: const Icon(Icons.school_rounded, color: AppTheme.primaryBlue, size: 30),
                   // TODO: Replace with Image.network(logoUrl) if available
                 ),
                 const SizedBox(width: 15),
                 Expanded(
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       Text(
                         tenantName, 
                         style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                         overflow: TextOverflow.ellipsis,
                         maxLines: 2,
                       ),
                       Text(
                         "Administration", 
                         style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
                       ),
                     ],
                   ),
                 ),
               ],
             ),
           ),
           
           Expanded(
             child: SingleChildScrollView(
               padding: const EdgeInsets.symmetric(vertical: 10),
               child: Column(
                 children: [
                   _buildDrawerItem(context, 'Dashboard', Icons.dashboard_outlined, onTap: () => context.go('/')),
                   const Divider(indent: 20, endIndent: 20),
                   _buildDrawerItem(context, 'Admission', Icons.person_add_alt_1_outlined, onTap: () => context.push('/admission')),
                   _buildDrawerItem(context, 'Students', Icons.people_outline_rounded, onTap: () => context.push('/students')),
                   _buildDrawerItem(context, 'Academics', Icons.school_outlined, onTap: () => context.push('/academics')),
                   _buildDrawerItem(context, 'Attendance', Icons.calendar_today_outlined, onTap: () => context.push('/attendance')),
                   const Divider(indent: 20, endIndent: 20),
                   _buildDrawerItem(context, 'Finance', Icons.account_balance_wallet_outlined, onTap: () => context.push('/finance')),
                   _buildDrawerItem(context, 'HR & Staff', Icons.badge_outlined, onTap: () => context.push('/hr/staff')),
                   _buildDrawerItem(context, 'Transport', Icons.directions_bus_outlined, onTap: () => context.push('/transport')),
                   _buildDrawerItem(context, 'Hostel', Icons.bed_outlined, onTap: () => context.push('/hostel')),
                   const Divider(indent: 20, endIndent: 20),
                   _buildDrawerItem(context, 'Events', Icons.event_outlined, onTap: () => context.push('/events')),
                   _buildDrawerItem(context, 'Exams', Icons.assignment_outlined, onTap: () => context.push('/exams')),
                   _buildDrawerItem(context, 'Library', Icons.local_library_outlined, onTap: () => context.push('/library')),
                   _buildDrawerItem(context, 'Security', Icons.security_outlined, onTap: () => context.push('/security')),
                   _buildDrawerItem(context, 'Communications', Icons.chat_bubble_outline_rounded, onTap: () => context.push('/communications')),
                   _buildDrawerItem(context, 'Users', Icons.manage_accounts_outlined, onTap: () => context.push('/users')),
                   _buildDrawerItem(context, 'Settings', Icons.settings_outlined, onTap: () {}), // Placeholder
                 ],
               ),
             ),
           ),
           
           // Footer with tenant version or shortcuts
           Container(
             padding: const EdgeInsets.all(20),
             decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppTheme.borderColor)),
             ),
             child: Row(
               children: [
                 const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                 const SizedBox(width: 8),
                 Text("v6.0.0 Enterprise", style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
               ],
             ),
           )
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, String title, IconData icon, {required VoidCallback onTap}) {
    return ListTile(
      onTap: () {
        Navigator.pop(context); // Close drawer
        onTap();
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
      leading: Icon(icon, color: Colors.grey.shade600, size: 22), 
      title: Text(title, style: GoogleFonts.outfit(color: Colors.grey.shade800, fontSize: 15, fontWeight: FontWeight.w500)),
      hoverColor: AppTheme.primaryBlue.withOpacity(0.05),
      dense: true,
    );
  }
}
