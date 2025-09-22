import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

enum NoteView { grid, list }

class SettingsNotifier extends StateNotifier<ThemeMode> {
  SettingsNotifier(this._ref) : super(ThemeMode.system) {
    _loadSettings();
  }

  final Ref _ref;
  final _settingsBox = Hive.box('settings');

  NoteView get noteView =>
      _settingsBox.get('note_view', defaultValue: NoteView.grid);

  void _loadSettings() {
    final themeModeName =
        _settingsBox.get('theme_mode', defaultValue: 'system');
    state = ThemeMode.values.firstWhere((e) => e.name == themeModeName);
  }

  void updateThemeMode(ThemeMode themeMode) {
    _settingsBox.put('theme_mode', themeMode.name);
    state = themeMode;
  }

  void updateNoteView(NoteView noteView) {
    _settingsBox.put('note_view', noteView.index);
    _ref.invalidate(noteViewProvider);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, ThemeMode>((ref) {
  return SettingsNotifier(ref);
});

final noteViewProvider = Provider<NoteView>((ref) {
  final settingsBox = Hive.box('settings');
  final noteViewIndex = settingsBox.get('note_view', defaultValue: 0);
  return NoteView.values[noteViewIndex];
});
