import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:notes_app/models/note.dart';

class NotesNotifier extends StateNotifier<List<Note>> {
  NotesNotifier(this._ref) : super([]) {
    _loadNotes();
  }

  final Ref _ref;
  final _notesBox = Hive.box<Note>('notes');
  final _deletedNotesBox = Hive.box<Note>('deleted_notes');

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

  void deleteNote(Note note) {
    note.deletionDate = DateTime.now();
    _deletedNotesBox.add(note);
    _notesBox.delete(note.key);
    _loadNotes();
    _ref.invalidate(deletedNotesProvider);
  }

  void restoreNote(Note note) {
    note.deletionDate = null;
    _notesBox.add(note);
    _deletedNotesBox.delete(note.key);
    _loadNotes();
    _ref.invalidate(deletedNotesProvider);
  }

  void permanentlyDeleteNote(Note note) {
    _deletedNotesBox.delete(note.key);
    _ref.invalidate(deletedNotesProvider);
  }

  void cleanupDeletedNotes() {
    final now = DateTime.now();
    for (final note in _deletedNotesBox.values) {
      if (now.difference(note.deletionDate!).inDays > 30) {
        permanentlyDeleteNote(note);
      }
    }
  }
}

final notesProvider = StateNotifierProvider<NotesNotifier, List<Note>>((ref) {
  return NotesNotifier(ref);
});

final deletedNotesProvider = Provider<List<Note>>((ref) {
  final deletedNotesBox = Hive.box<Note>('deleted_notes');
  return deletedNotesBox.values.toList().cast<Note>();
});
