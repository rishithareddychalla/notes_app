import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/models/note.dart';
import 'package:notes_app/providers/note_provider.dart';
import 'package:notes_app/widgets/note_card.dart';

class DeletedNoteSearchDelegate extends SearchDelegate<Note?> {
  DeletedNoteSearchDelegate(this.ref) : super();

  final WidgetRef ref;

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final notes = ref.read(deletedNotesProvider);
    final filteredNotes = notes
        .where((note) =>
            note.title.toLowerCase().contains(query.toLowerCase()) ||
            note.content.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: filteredNotes.length,
      itemBuilder: (context, index) {
        final note = filteredNotes[index];
        return NoteCard(
          note: note,
          onTap: () {
            _showRestoreOrDeleteDialog(context, note);
          }, isSelected: false, onLongPress: () {  },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final notes = ref.read(deletedNotesProvider);
    final filteredNotes = notes
        .where((note) =>
            note.title.toLowerCase().contains(query.toLowerCase()) ||
            note.content.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: filteredNotes.length,
      itemBuilder: (context, index) {
        final note = filteredNotes[index];
        return NoteCard(
          note: note,
          onTap: () {
            _showRestoreOrDeleteDialog(context, note);
          }, isSelected: false, onLongPress: () {  },
        );
      },
    );
  }

  void _showRestoreOrDeleteDialog(BuildContext context, Note note) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Restore Note'),
        content: const Text('What would you like to do with this note?'),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(deletedNotesProvider.notifier).restoreNote(note);
              Navigator.pop(dialogContext);
              close(context, note);
            },
            child: const Text('Restore'),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(deletedNotesProvider.notifier)
                  .permanentlyDeleteNote(note);
              Navigator.pop(dialogContext);
              close(context, null);
            },
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );
  }
}