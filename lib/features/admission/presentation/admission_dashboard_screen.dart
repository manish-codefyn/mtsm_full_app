import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class AdmissionDashboardScreen extends ConsumerWidget {
  const AdmissionDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Placeholder for stats logic
    final stats = [
      {'label': 'Total Applications', 'value': '45', 'sub_label': 'All time', 'icon': 'fact_check', 'color': '#2196F3'},
      {'label': 'Pending Review', 'value': '12', 'sub_label': 'Needs action', 'icon': 'pending', 'color': '#FF9800'},
      {'label': 'Admitted', 'value': '28', 'sub_label': 'This session', 'icon': 'how_to_reg', 'color': '#4CAF50'},
      {'label': 'Rejected', 'value': '5', 'sub_label': '', 'icon': 'cancel', 'color': '#F44336'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Admission Dashboard',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Actions
            Text(
              'Quick Actions',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.3,
              children: [
                _buildActionCard(
                  context,
                  'All Applications',
                  Icons.list_alt_rounded,
                  Colors.blue,
                  () => context.push('/admission/list'),
                ),
                _buildActionCard(
                  context,
                  'Pending Review',
                  Icons.pending_actions_rounded,
                  Colors.orange,
                  // We simulate filtering via future query params if implemented, for now list defaults to All
                  // But ideally: /admission/list?status=SUBMITTED
                  () => context.push('/admission/list'), 
                ),
                _buildActionCard(
                  context,
                  'Approved/Admitted',
                  Icons.check_circle_outline_rounded,
                  Colors.green,
                  () => context.push('/admission/list'),
                ),
                 _buildActionCard(
                  context,
                  'Waitlisted',
                  Icons.hourglass_empty_rounded,
                  Colors.purple,
                  () => context.push('/admission/list'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Text(
              'Overview (Demo Stats)',
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
                childAspectRatio: 1.1,
              ),
              itemCount: stats.length,
              itemBuilder: (context, index) {
                final stat = stats[index];
                return _buildStatCard(
                  context,
                  label: stat['label']!,
                  value: stat['value']!,
                  subLabel: stat['sub_label']!,
                  iconName: stat['icon']!,
                  colorHex: stat['color']!,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String label,
    required String value,
    required String subLabel,
    required String iconName,
    required String colorHex,
  }) {
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
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
              ],
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
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                 const SizedBox(height: 4),
                 Text(
                  subLabel,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'fact_check': return Icons.fact_check;
      case 'pending': return Icons.pending;
      case 'how_to_reg': return Icons.how_to_reg;
      case 'cancel': return Icons.cancel;
      default: return Icons.dashboard;
    }
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
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
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
