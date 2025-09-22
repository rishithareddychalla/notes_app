import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/main.dart';
import 'package:notes_app/models/note.dart';
import 'package:notes_app/views/note_editor_screen.dart';
import 'package:notes_app/views/settings_screen.dart';

final notesProvider = FutureProvider<List<Note>>((ref) async {
  final hiveService = ref.watch(hiveServiceProvider);
  return hiveService.getAllNotes();
});

class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsyncValue = ref.watch(notesProvider);
    final isCardView = ref.watch(isCardViewProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('My Notes'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: notesAsyncValue.when(
        data: (notes) {
          if (notes.isEmpty) {
            return Center(
              child: Text('No notes yet. Tap the + button to add one!'),
            );
          }
          return isCardView ? _buildGridView(notes) : _buildListView(notes);
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => NoteEditorScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildGridView(List<Note> notes) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
      ),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return _buildNoteCard(context, note);
      },
    );
  }

  Widget _buildListView(List<Note> notes) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return _buildNoteCard(context, note);
      },
    );
  }

  Widget _buildNoteCard(BuildContext context, Note note) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => NoteEditorScreen(note: note),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (note.imagePaths.isNotEmpty)
              Image.file(
                File(note.imagePaths.first),
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note.title,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.0),
                  if (note.checklist.isNotEmpty)
                    ...note.checklist.take(3).map((item) => Row(
                          children: [
                            Checkbox(
                              value: item['isChecked'],
                              onChanged: (value) {}, // Read-only
                            ),
                            Expanded(
                              child: Text(
                                item['text'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ))
                  else
                    Text(
                      note.content,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
