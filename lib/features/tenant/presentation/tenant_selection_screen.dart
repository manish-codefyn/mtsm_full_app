import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/data/auth_repository.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/theme_controller.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/config/constants.dart';

class TenantSelectionScreen extends ConsumerStatefulWidget {
  const TenantSelectionScreen({super.key});

  @override
  ConsumerState<TenantSelectionScreen> createState() => _TenantSelectionScreenState();
}

class _TenantSelectionScreenState extends ConsumerState<TenantSelectionScreen> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _error;

  Future<void> _verifyTenant() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final code = _codeController.text.trim();
      final data = await ref.read(authRepositoryProvider).checkTenant(code);
      
      // Store schema
      const storage = FlutterSecureStorage();
      await storage.write(key: AppConstants.tenantSchemaKey, value: data['schema_name']);

      // Update API Base URL
      if (data.containsKey('api_url')) {
        ref.read(apiClientProvider).setBaseUrl(data['api_url']);
      }
      
      // Update Theme if branding is present
      if (data.containsKey('branding')) {
        final branding = data['branding'];
        if (branding != null) {
          // Parse colors
          // branding['primary_color'] might be '#RRGGBB'
          Color? primary = _parseColor(branding['primary_color']);
          Color? secondary = _parseColor(branding['secondary_color']);
          
          if (primary != null && secondary != null) {
             ref.read(themeControllerProvider.notifier).setTenantColors(primary, secondary);
          }
        }
      }

      if (mounted) {
        context.go('/login');
      }
    } catch (e) {
      setState(() {
        _error = "Error: ${e.toString()}";
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Color? _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    try {
      hex = hex.replaceAll('#', '');
      if (hex.length == 6) {
        hex = 'FF' + hex;
      }
      return Color(int.parse(hex, radix: 16));
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   Icon(
                    Icons.business,
                    size: 80,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Enter School Code',
                    style: GoogleFonts.roboto(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please enter the code provided by your institution',
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  if (_error != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        _error!,
                        style: TextStyle(color: Colors.red.shade800),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  TextFormField(
                    controller: _codeController,
                    decoration: const InputDecoration(
                      labelText: 'School Code',
                      hintText: 'e.g. dps_delhi',
                      prefixIcon: Icon(Icons.qr_code),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Required' : null,
                    textInputAction: TextInputAction.send,
                    onFieldSubmitted: (_) => _verifyTenant(),
                  ),
                  const SizedBox(height: 24),
                   FilledButton(
                    onPressed: _isLoading ? null : _verifyTenant,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Continue'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
