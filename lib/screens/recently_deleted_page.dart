import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/models/note.dart';
import 'package:notes_app/providers/note_provider.dart';
import 'package:notes_app/providers/settings_provider.dart';
import 'package:notes_app/widgets/deleted_note_search_delegate.dart';
import 'package:notes_app/widgets/note_card.dart';
import 'package:notes_app/widgets/note_list_tile.dart';

class RecentlyDeletedPage extends ConsumerWidget {
  const RecentlyDeletedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final deletedNotes = ref.watch(deletedNotesProvider);
    final noteView = ref.watch(noteViewProvider);

    final emptyNotesWidget = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.delete_sweep,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No recently deleted notes.',
            style: theme.textTheme.headlineMedium,
          ),
        ],
      ),
    );

    void restoreOrDeleteDialog(Note note) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text('Restore Note'),
          content: const Text('What would you like to do with this note?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                ref.read(deletedNotesProvider.notifier).restoreNote(note);
                Navigator.pop(context);
              },
              child: const Text('Restore'),
            ),
            TextButton(
              onPressed: () {
                ref
                    .read(deletedNotesProvider.notifier)
                    .permanentlyDeleteNote(note);
                Navigator.pop(context);
              },
              child: const Text('Delete Permanently'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recently Deleted'),
        actions: [
          IconButton(
            icon: Icon(
              noteView == NoteView.grid ? Icons.view_module : Icons.view_list,
            ),
            onPressed: () {
              ref.read(settingsProvider.notifier).updateNoteView(
                    noteView == NoteView.grid ? NoteView.list : NoteView.grid,
                  );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: DeletedNoteSearchDelegate(ref),
              );
            },
          ),
        ],
      ),
      body: deletedNotes.isEmpty
          ? emptyNotesWidget
          : noteView == NoteView.grid
              ? GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: deletedNotes.length,
                  itemBuilder: (context, index) {
                    final note = deletedNotes[index];
                    return NoteCard(
                      note: note,
                      onTap: () => restoreOrDeleteDialog(note),
                    );
                  },
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  itemCount: deletedNotes.length,
                  itemBuilder: (context, index) {
                    final note = deletedNotes[index];
                    return NoteListTile(
                      note: note,
                      onTap: () => restoreOrDeleteDialog(note),
                    );
                  },
                ),
    );
  }
}
