import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/providers/settings_provider.dart';
import 'package:notes_app/screens/recently_deleted_page.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(settingsProvider);
    final noteView = ref.watch(noteViewProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Appearance',
              style: theme.textTheme.headlineMedium
                  ?.copyWith(color: theme.primaryColor),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.dark_mode),
                title: Text(
                  'Dark Mode',
                  style: theme.textTheme.bodyLarge,
                ),
                trailing: Switch(
                  value: themeMode == ThemeMode.dark,
                  onChanged: (value) {
                    ref.read(settingsProvider.notifier).updateThemeMode(
                        value ? ThemeMode.dark : ThemeMode.light);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.view_list),
                title: Text(
                  'Note View',
                  style: theme.textTheme.bodyLarge,
                ),
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
            ),
            const SizedBox(height: 32),
            Text(
              'Other',
              style: theme.textTheme.headlineMedium
                  ?.copyWith(color: theme.primaryColor),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.delete_forever),
                title: Text(
                  'Recently Deleted',
                  style: theme.textTheme.bodyLarge,
                ),
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
            ),
          ],
        ),
      ),
    );
  }
}
