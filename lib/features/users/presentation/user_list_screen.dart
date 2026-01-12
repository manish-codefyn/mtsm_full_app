import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import 'user_controller.dart';

class UserListScreen extends ConsumerStatefulWidget {
  const UserListScreen({super.key});

  @override
  ConsumerState<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends ConsumerState<UserListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    // Debounce can be added here
    ref.read(userFilterProvider.notifier).update((state) => state.copyWith(search: value, page: 1));
  }

  void _showRoleDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Update Role: ${user['first_name']}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['admin', 'staff', 'student', 'parent', 'driver'].map((role) {
            return ListTile(
              title: Text(role.toUpperCase()),
              leading: Radio<String>(
                value: role,
                groupValue: user['role'],
                onChanged: (val) {
                  Navigator.pop(context);
                  _confirmRoleChange(user, val!);
                },
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmRoleChange(user, role);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _confirmRoleChange(Map<String, dynamic> user, String newRole) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Change"),
        content: Text("Are you sure you want to change ${user['first_name']}'s role to $newRole?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(userControllerProvider).updateUserRole(user['id'].toString(), newRole);
            },
            child: const Text("Confirm"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userListProvider);
    final filters = ref.watch(userFilterProvider);

    return Scaffold(
      backgroundColor: AppTheme.bodyBackground,
      appBar: AppBar(
        title: const Text("User Management", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Search & Filters
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: "Search users...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip("All", filters.role == null),
                      const SizedBox(width: 8),
                      _buildFilterChip("Admin", filters.role == 'admin', role: 'admin'),
                      const SizedBox(width: 8),
                      _buildFilterChip("Staff", filters.role == 'staff', role: 'staff'),
                      const SizedBox(width: 8),
                      _buildFilterChip("Student", filters.role == 'student', role: 'student'),
                    ],
                  ),
                )
              ],
            ),
          ),
          
          Expanded(
            child: userAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) => Center(child: Text("Error: $err")),
              data: (data) {
                final users = data['results'] as List;
                if (users.isEmpty) return const Center(child: Text("No users found"));

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final isActive = user['is_active'] ?? false;
                    
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), 
                        side: BorderSide(color: Colors.grey.shade200)
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundImage: user['avatar'] != null ? NetworkImage(user['avatar']) : null,
                              child: user['avatar'] == null ? Text((user['first_name']?[0] ?? 'U').toUpperCase()) : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${user['first_name']} ${user['last_name']}",
                                    style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 16),
                                  ),
                                  Text(
                                    "${user['email']} • ${user['role']?.toUpperCase()}",
                                    style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Switch(
                                  value: isActive,
                                  onChanged: (val) {
                                    ref.read(userControllerProvider).toggleUserStatus(user['id'].toString(), isActive);
                                  },
                                  activeColor: Colors.green,
                                ),
                                InkWell(
                                  onTap: () => _showRoleDialog(user),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(4)
                                    ),
                                    child: const Text("Edit Role", style: TextStyle(fontSize: 10, color: Colors.blue)),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, {String? role}) {
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (bool selected) {
        ref.read(userFilterProvider.notifier).update(
          (state) => state.copyWith(role: role, page: 1) // role can be null for 'All'
        );
      },
      backgroundColor: Colors.white,
      selectedColor: AppTheme.primaryBlue.withOpacity(0.1),
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primaryBlue : Colors.black,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal
      ),
      shape: StadiumBorder(side: BorderSide(color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade300)),
      showCheckmark: false,
    );
  }
}
