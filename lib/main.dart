import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'core/router/app_router.dart';

final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeState = ref.watch(themeControllerProvider);

    return MaterialApp.router(
      title: 'MTSM',
      theme: AppTheme.getLightTheme(
        primary: themeState.primary ?? AppTheme.primaryBlue,
        secondary: themeState.secondary ?? AppTheme.accentBlue,
      ),
      darkTheme: AppTheme.getDarkTheme(
        primary: themeState.primary ?? AppTheme.primaryBlue,
        secondary: themeState.secondary ?? AppTheme.accentBlue,
      ),
      themeMode: themeState.mode,
      routerConfig: router,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
    );
  }
}
