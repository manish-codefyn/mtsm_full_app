import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class ShortcutsPopup extends StatefulWidget {
  @override
  State<ShortcutsPopup> createState() => _ShortcutsPopupState();
}

class _ShortcutsPopupState extends State<ShortcutsPopup> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allShortcuts = [
      {'icon': Icons.person_add_alt_1, 'label': 'Admission', 'color': Colors.purple, 'route': '/admission'},
      {'icon': Icons.people, 'label': 'Students', 'color': Colors.blue, 'route': '/students'},
      {'icon': Icons.school, 'label': 'Academics', 'color': Colors.orange, 'route': '/academics'},
      {'icon': Icons.badge, 'label': 'Staff', 'color': Colors.teal, 'route': '/hr/staff'},
      {'icon': Icons.calendar_today, 'label': 'Attendance', 'color': Colors.green, 'route': '/attendance'},
      {'icon': Icons.account_balance_wallet, 'label': 'Finance', 'color': Colors.red, 'route': '/finance'},
      {'icon': Icons.directions_bus, 'label': 'Transport', 'color': Colors.indigo, 'route': '/transport'},
      {'icon': Icons.bed, 'label': 'Hostel', 'color': Colors.pink, 'route': '/hostel'},
      {'icon': Icons.event, 'label': 'Events', 'color': Colors.deepOrange, 'route': '/events'},
      {'icon': Icons.assignment, 'label': 'Exams', 'color': Colors.deepPurple, 'route': '/exams'},
      {'icon': Icons.local_library, 'label': 'Library', 'color': Colors.brown, 'route': '/library'},
      {'icon': Icons.inventory_2, 'label': 'Inventory', 'color': Colors.cyan, 'route': '/inventory'},
      {'icon': Icons.security, 'label': 'Security', 'color': Colors.blueGrey, 'route': '/security'},
      {'icon': Icons.chat_bubble, 'label': 'Message', 'color': Colors.lightBlue, 'route': '/communications'},
      {'icon': Icons.assignment_ind, 'label': 'Assign.', 'color': Colors.lime, 'route': '/assignments'},
      {'icon': Icons.manage_accounts, 'label': 'Users', 'color': Colors.blueAccent, 'route': '/users'},
      {'icon': Icons.picture_as_pdf, 'label': 'Reports', 'color': Colors.redAccent, 'route': '/reports'},
  ];
  
  List<Map<String, dynamic>> _filteredShortcuts = [];

  @override
  void initState() {
    super.initState();
    _filteredShortcuts = _allShortcuts;
    _searchController.addListener(_filterShortcuts);
  }

  void _filterShortcuts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredShortcuts = _allShortcuts.where((item) {
        return item['label'].toString().toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("All Shortcuts", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 16),
          // Search in Popup
          Container(
            height: 40,
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Find a module...",
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _filteredShortcuts.isEmpty 
              ? Center(child: Text("No shortcuts found", style: GoogleFonts.outfit(color: Colors.grey)))
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.8, // Fix overflow by allowing taller items
                  ),
                  itemCount: _filteredShortcuts.length,
                  itemBuilder: (context, index) {
                    final item = _filteredShortcuts[index];
                    return _buildShortcutItem(
                      context, 
                      item['icon'] as IconData, 
                      item['label'] as String, 
                      item['color'] as Color, 
                      item['route'] as String
                    );
                  },
              ),
          )
        ],
      ),
    );
  }

  Widget _buildShortcutItem(BuildContext context, IconData icon, String label, Color color, String route) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        context.push(route);
      },
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
          const SizedBox(height: 8),
          Text(label, style: GoogleFonts.outfit(fontSize: 12), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
