import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/providers/note_provider.dart';
import 'package:notes_app/widgets/note_list_tile.dart';

class RecentlyDeletedPage extends ConsumerWidget {
  const RecentlyDeletedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deletedNotes = ref.watch(deletedNotesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recently Deleted'),
      ),
      body: deletedNotes.isEmpty
          ? const Center(
              child: Text('No recently deleted notes.'),
            )
          : ListView.builder(
              itemCount: deletedNotes.length,
              itemBuilder: (context, index) {
                final note = deletedNotes[index];
                return NoteListTile(
                  note: note,
                  onTap: () {
                    // Show a dialog to restore or permanently delete the note
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Restore Note'),
                        content: const Text(
                            'What would you like to do with this note?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              ref
                                  .read(notesProvider.notifier)
                                  .restoreNote(note);
                              Navigator.pop(context);
                            },
                            child: const Text('Restore'),
                          ),
                          TextButton(
                            onPressed: () {
                              ref
                                  .read(notesProvider.notifier)
                                  .permanentlyDeleteNote(note);
                              Navigator.pop(context);
                            },
                            child: const Text('Delete Permanently'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
