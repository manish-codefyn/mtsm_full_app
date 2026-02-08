import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/theme_controller.dart';
import 'core/config/constants.dart';

// Global key for ScaffoldMessenger to show snackbars from anywhere
final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeState = ref.watch(themeControllerProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      themeMode: themeState.mode,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: themeState.primary ?? Colors.blue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: themeState.primary ?? Colors.blue,
          primary: themeState.primary,
          secondary: themeState.secondary,
        ),
      ),
      darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
        primaryColor: themeState.primary ?? Colors.blue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: themeState.primary ?? Colors.blue,
          primary: themeState.primary,
          secondary: themeState.secondary,
          brightness: Brightness.dark,
        ),
      ),
      routerConfig: router,
    );
  }
}
