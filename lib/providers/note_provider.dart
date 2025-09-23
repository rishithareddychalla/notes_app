import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:notes_app/models/note.dart';

/// Manages the state of the notes, including soft deletes and restores.
class NotesNotifier extends StateNotifier<List<Note>> {
  NotesNotifier(this._ref) : super([]) {
    // Load notes from the database when the provider is initialized.
    _loadNotes();
    // Clean up notes that were deleted over 30 days ago.
    cleanupDeletedNotes();
  }

  final Ref _ref;
  final _notesBox = Hive.box<Note>('notes');
  final _deletedNotesBox = Hive.box<Note>('deleted_notes');

  /// Loads all non-deleted notes from the Hive box into the state.
  void _loadNotes() {
    state = _notesBox.values.toList().cast<Note>();
  }

  /// Adds a new note to the database.
  void addNote(Note note) {
    _notesBox.add(note);
    _loadNotes();
  }

  /// Updates an existing note in the database.
  void updateNote(dynamic key, Note note) {
    _notesBox.put(key, note);
    _loadNotes();
  }

  /// Soft deletes a note by moving it to the 'deleted_notes' box.
  void deleteNote(Note note) {
    note.deletionDate = DateTime.now();
    // Use the note's original key to store it in the deleted box.
    // This is important for being able to restore it later.
    _deletedNotesBox.put(note.key, note);
    _notesBox.delete(note.key);
    _loadNotes();
    // Invalidate the deletedNotesProvider to trigger a UI update on the
    // Recently Deleted page.
    _ref.invalidate(deletedNotesProvider);
  }

  /// Restores a soft-deleted note from the 'deleted_notes' box.
  void restoreNote(Note note) {
    note.deletionDate = null;
    // Use the note's original key to move it back to the main notes box.
    _notesBox.put(note.key, note);
    _deletedNotesBox.delete(note.key);
    _loadNotes();
    // Invalidate the deletedNotesProvider to trigger a UI update.
    _ref.invalidate(deletedNotesProvider);
  }

  /// Permanently deletes a note from the 'deleted_notes' box.
  void permanentlyDeleteNote(Note note) {
    _deletedNotesBox.delete(note.key);
    // Invalidate the deletedNotesProvider to trigger a UI update.
    _ref.invalidate(deletedNotesProvider);
  }

  /// Permanently deletes any notes that were soft-deleted more than 30 days ago.
  void cleanupDeletedNotes() {
    final now = DateTime.now();
    for (final note in _deletedNotesBox.values) {
      if (note.deletionDate != null &&
          now.difference(note.deletionDate!).inDays > 30) {
        permanentlyDeleteNote(note);
      }
    }
  }
}

/// Provider for the list of active (non-deleted) notes.
final notesProvider = StateNotifierProvider<NotesNotifier, List<Note>>((ref) {
  return NotesNotifier(ref);
});

/// Provider for the list of soft-deleted notes.
final deletedNotesProvider = Provider<List<Note>>((ref) {
  final deletedNotesBox = Hive.box<Note>('deleted_notes');
  return deletedNotesBox.values.toList().cast<Note>();
});
