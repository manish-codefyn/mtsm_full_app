import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.bodyBackground,
      appBar: AppBar(
        title: const Text("Edit Profile", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
           children: [
             const CircleAvatar(radius: 50, backgroundColor: Colors.grey, child: Icon(Icons.person, size: 50, color: Colors.white)),
             const SizedBox(height: 20),
             TextFormField(
               initialValue: "Admin User",
               decoration: const InputDecoration(labelText: "Full Name", border: OutlineInputBorder()),
             ),
             const SizedBox(height: 16),
             TextFormField(
               initialValue: "admin@school.com",
               readOnly: true,
               decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder()),
             ),
             const SizedBox(height: 16),
             TextFormField(
               initialValue: "+91 98765 43210",
               decoration: const InputDecoration(labelText: "Phone", border: OutlineInputBorder()),
             ),
              const SizedBox(height: 24),
             SizedBox(
               width: double.infinity,
               child: ElevatedButton(
                 style: ElevatedButton.styleFrom(
                   backgroundColor: AppTheme.primaryBlue,
                   padding: const EdgeInsets.symmetric(vertical: 16),
                 ),
                 onPressed: () {
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile Updated")));
                 }, 
                 child: const Text("Save Changes", style: TextStyle(color: Colors.white)),
               ),
             )
           ],
        ),
      ),
    );
  }
}
