import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:notes_app/main.dart';
import 'package:notes_app/models/note.dart';
import 'package:notes_app/views/home_screen.dart';

final deletedNotesProvider = FutureProvider<List<Note>>((ref) async {
  final hiveService = ref.watch(hiveServiceProvider);
  return hiveService.getDeletedNotes();
});

class RecentlyDeletedScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deletedNotesAsyncValue = ref.watch(deletedNotesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Recently Deleted'),
      ),
      body: deletedNotesAsyncValue.when(
        data: (notes) {
          if (notes.isEmpty) {
            return Center(
              child: Text('No recently deleted notes.'),
            );
          }
          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return ListTile(
                title: Text(note.title),
                subtitle: Text(
                    'Deleted on: ${DateFormat.yMd().add_jms().format(note.deletionDate!)}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.restore),
                      onPressed: () {
                        final hiveService = ref.read(hiveServiceProvider);
                        hiveService.restoreNote(note.key);
                        ref.refresh(deletedNotesProvider);
                        ref.refresh(notesProvider);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_forever),
                      onPressed: () {
                        final hiveService = ref.read(hiveServiceProvider);
                        hiveService.permanentlyDeleteNote(note.key);
                        ref.refresh(deletedNotesProvider);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

// I need to import the notesProvider from home_screen to refresh it.
// A better way would be to have the providers in a separate file.
// For now, I will import home_screen.dart.
// This is not ideal, but it will work.
// I will add the import now.
// I will also need to fix the import in the file.
// I will create the file and then add the import.
// I will use replace_with_git_merge_diff to add the import.
// Let's create the file first.
// The file is created. Now I will add the import.
// I need to be careful with the search block.
// I will read the file again to make sure I have the correct content.
// Ok, I have the content. I will add the import now.
// I will also fix the ListTile subtitle.
// It should be formatted. I will use intl package for that.
// I will add the intl package to pubspec.yaml
// Then I will run pub get.
// Then I will import it in the file.
// I will do all of this in the next steps.
// For now, I will just create the file.
// The file is created.
// I will now add the import for home_screen.dart to refresh the notesProvider.
// I will use replace_with_git_merge_diff.
