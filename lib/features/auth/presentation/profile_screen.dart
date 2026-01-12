import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/theme/app_theme.dart';
import 'profile_controller.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  late TextEditingController _firstNameCtrl;
  late TextEditingController _lastNameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;

  // State
  bool _isEditing = false;
  String? _selectedAvatarPath;

  @override
  void initState() {
    super.initState();
    _firstNameCtrl = TextEditingController();
    _lastNameCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  // Populate controllers when data is loaded
  void _populateControllers(Map<String, dynamic> user) {
    if (_firstNameCtrl.text.isEmpty && !_isEditing) {
      _firstNameCtrl.text = user['first_name'] ?? '';
      _lastNameCtrl.text = user['last_name'] ?? '';
      _phoneCtrl.text = user['phone_number'] ?? '';
      _emailCtrl.text = user['email'] ?? '';
    }
  }

  Future<void> _pickAvatar() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedAvatarPath = result.files.single.path;
      });
      // Optionally auto-upload immediately or wait for Save
      // Let's wait for Save to be consistent with form
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final data = {
        'first_name': _firstNameCtrl.text,
        'last_name': _lastNameCtrl.text,
        'phone_number': _phoneCtrl.text,
      };

      await ref.read(profileControllerProvider).updateProfile(data, filePath: _selectedAvatarPath);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully')));
        setState(() {
          _isEditing = false;
          _selectedAvatarPath = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
      }
    }
  }

  void _showChangePasswordDialog(BuildContext context) {
    final oldPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: oldPassCtrl,
                decoration: const InputDecoration(labelText: 'Old Password'),
                obscureText: true,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: newPassCtrl,
                decoration: const InputDecoration(labelText: 'New Password'),
                obscureText: true,
                validator: (v) => v!.length < 8 ? 'Min 8 chars' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  await ref.read(profileControllerProvider).changePassword(
                    oldPassCtrl.text,
                    newPassCtrl.text,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password changed')));
                  }
                } catch (e) {
                  if (context.mounted) {
                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              }
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppTheme.bodyBackground,
      appBar: AppBar(
        title: const Text("My Profile", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: context.canPop() 
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => context.pop(),
            )
          : null,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: AppTheme.primaryBlue),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
        data: (user) {
          _populateControllers(user);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Avatar Section
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: _selectedAvatarPath != null 
                              ? null // FileImage(File(_selectedAvatarPath!)) - requires dart:io, let's skip preview for web compat or use kIsWeb check if needed. For now simple.
                              : (user['avatar'] != null ? NetworkImage(user['avatar']) : null),
                          child: (_selectedAvatarPath == null && user['avatar'] == null)
                              ? const Icon(Icons.person, size: 60, color: Colors.grey)
                              : null,
                        ),
                        if (_isEditing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              backgroundColor: AppTheme.primaryBlue,
                              radius: 18,
                              child: IconButton(
                                icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                                onPressed: _pickAvatar,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Info Section
                  _buildTextField("First Name", _firstNameCtrl, enabled: _isEditing),
                  const SizedBox(height: 16),
                  _buildTextField("Last Name", _lastNameCtrl, enabled: _isEditing),
                  const SizedBox(height: 16),
                  _buildTextField("Email", _emailCtrl, enabled: false), // Always disabled
                  const SizedBox(height: 16),
                  _buildTextField("Phone", _phoneCtrl, enabled: _isEditing),
                  
                  const SizedBox(height: 32),

                  if (_isEditing)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                               setState(() {
                                 _isEditing = false;
                                 _selectedAvatarPath = null;
                                 _firstNameCtrl.clear(); // Will trigger repopulate
                               });
                            },
                            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                            child: const Text("Cancel"),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryBlue,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text("Save Changes", style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showChangePasswordDialog(context),
                        icon: const Icon(Icons.lock_outline),
                        label: const Text("Change Password"),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool enabled = true}) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: !enabled,
        fillColor: enabled ? null : Colors.grey.shade50,
      ),
      validator: (val) => val!.isEmpty ? 'Required' : null,
    );
  }
}
