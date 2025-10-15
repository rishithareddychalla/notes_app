import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/providers/note_provider.dart';
import 'package:notes_app/providers/settings_provider.dart';
import 'package:notes_app/widgets/deleted_note_search_delegate.dart';
import 'package:notes_app/widgets/note_card.dart';
import 'package:notes_app/widgets/note_list_tile.dart';

class RecentlyDeletedPage extends ConsumerWidget {
  const RecentlyDeletedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deletedNotes = ref.watch(deletedNotesProvider);
    final noteView = ref.watch(noteViewProvider);

    final emptyNotesWidget = Center(
      child: Text('No recently deleted notes.'),
    );

    final restoreOrDeleteDialog = (note) => showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Restore Note'),
            content: const Text('What would you like to do with this note?'),
            actions: [
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
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: deletedNotes.length,
                  itemBuilder: (context, index) {
                    final note = deletedNotes[index];
                    return NoteCard(
                      note: note,
                      onTap: () => restoreOrDeleteDialog(note), isSelected: false, onLongPress: () {  },
                    );
                  },
                )
              : ListView.builder(
                  itemCount: deletedNotes.length,
                  itemBuilder: (context, index) {
                    final note = deletedNotes[index];
                    return NoteListTile(
                      note: note,
                      onTap: () => restoreOrDeleteDialog(note), isSelected: false, onLongPress: () {  },
                    );
                  },
                ),
    );
  }
}
