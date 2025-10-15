import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/providers/settings_provider.dart';
import 'package:notes_app/screens/recently_deleted_page.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(settingsProvider);
    final noteView = ref.watch(noteViewProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Dark Mode'),
            trailing: Switch(
              inactiveThumbColor: Colors.black,
              inactiveTrackColor: Color(0xFF82CFFD),
              value: themeMode == ThemeMode.dark,
              onChanged: (value) {
                ref
                    .read(settingsProvider.notifier)
                    .updateThemeMode(value ? ThemeMode.dark : ThemeMode.light);
              },
            ),
          ),
          ListTile(
            title: const Text('Recently Deleted'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RecentlyDeletedPage(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Note View'),
            trailing: SegmentedButton<NoteView>(
              segments: const [
                ButtonSegment(
                    value: NoteView.grid, icon: Icon(Icons.grid_view)),
                ButtonSegment(
                    value: NoteView.list, icon: Icon(Icons.view_list)),
              ],
              selected: {noteView},
              onSelectionChanged: (newSelection) {
                ref
                    .read(settingsProvider.notifier)
                    .updateNoteView(newSelection.first);
              },
            ),
          ),
        ],
      ),
    );
  }
}
