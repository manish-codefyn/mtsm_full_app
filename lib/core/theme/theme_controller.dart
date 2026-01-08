import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeControllerProvider = NotifierProvider<ThemeController, ThemeState>(ThemeController.new);

class ThemeState {
  final ThemeMode mode;
  final Color? primary;
  final Color? secondary;

  const ThemeState({this.mode = ThemeMode.system, this.primary, this.secondary});

  ThemeState copyWith({ThemeMode? mode, Color? primary, Color? secondary}) {
    return ThemeState(
      mode: mode ?? this.mode,
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
    );
  }
}

class ThemeController extends Notifier<ThemeState> {
  @override
  ThemeState build() {
    return const ThemeState();
  }

  void toggleTheme() {
    state = state.copyWith(mode: state.mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);
  }

  void setSystem() {
    state = state.copyWith(mode: ThemeMode.system);
  }

  void setTenantColors(Color primary, Color secondary) {
    state = state.copyWith(primary: primary, secondary: secondary);
  }
  
  void resetColors() {
    state = state.copyWith(primary: null, secondary: null); // Will fallback to defaults in UI
  }
}
