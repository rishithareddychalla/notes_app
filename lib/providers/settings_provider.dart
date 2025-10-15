import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum NoteView { grid, list }

class SettingsNotifier extends StateNotifier<ThemeMode> {
  SettingsNotifier(this._ref) : super(ThemeMode.system) {
    _loadSettings();
  }

  final Ref _ref;

  NoteView get noteView {
    final prefs = _ref.watch(sharedPreferencesProvider);
    final noteViewIndex = prefs.getInt('note_view') ?? 0;
    return NoteView.values[noteViewIndex];
  }

  void _loadSettings() {
    final prefs = _ref.read(sharedPreferencesProvider);
    final themeModeName = prefs.getString('theme_mode') ?? 'system';
    state = ThemeMode.values.firstWhere((e) => e.name == themeModeName);
  }

  void updateThemeMode(ThemeMode themeMode) {
    final prefs = _ref.read(sharedPreferencesProvider);
    prefs.setString('theme_mode', themeMode.name);
    state = themeMode;
  }

  void updateNoteView(NoteView noteView) {
    final prefs = _ref.read(sharedPreferencesProvider);
    prefs.setInt('note_view', noteView.index);
    _ref.invalidate(noteViewProvider);
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  // This provider is overridden in main.dart
  throw UnimplementedError();
});

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, ThemeMode>((ref) {
  return SettingsNotifier(ref);
});

final noteViewProvider = Provider<NoteView>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final noteViewIndex = prefs.getInt('note_view') ?? 0;
  return NoteView.values[noteViewIndex];
});
