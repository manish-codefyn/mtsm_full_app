import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/tenant_repository.dart';
import 'package:school_erp_app/core/network/api_client.dart';

final tenantControllerProvider = AsyncNotifierProvider<TenantController, String?>(TenantController.new);

class TenantController extends AsyncNotifier<String?> {
  @override
  FutureOr<String?> build() async {
    return await ref.read(tenantRepositoryProvider).getSavedTenantUrl();
  }

  Future<void> setTenant(String schemaName) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final url = await ref.read(tenantRepositoryProvider).validateTenant(schemaName);
      ref.read(apiClientProvider).setBaseUrl(url);
      return url;
    });
  }

  Future<void> clearTenant() async {
    state = const AsyncLoading();
    await ref.read(tenantRepositoryProvider).clearTenant();
    state = const AsyncData(null);
  }
}
