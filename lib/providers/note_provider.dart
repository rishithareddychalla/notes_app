import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:notes_app/models/note.dart';

class NotesNotifier extends StateNotifier<List<Note>> {
  NotesNotifier() : super([]) {
    _loadNotes();
  }

  final _notesBox = Hive.box<Note>('notes');

  void _loadNotes() {
    state = _notesBox.values.toList().cast<Note>();
  }

  void addNote(Note note) {
    _notesBox.add(note);
    _loadNotes();
  }

  void updateNote(dynamic key, Note note) {
    _notesBox.put(key, note);
    _loadNotes();
  }

  void deleteNote(int index) {
    _notesBox.deleteAt(index);
    _loadNotes();
  }
}

final notesProvider = StateNotifierProvider<NotesNotifier, List<Note>>((ref) {
  return NotesNotifier();
});
