import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:notes_app/models/note.dart';

const String _notesKey = 'notes';
const String _deletedNotesKey = 'deleted_notes';

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

class NotesNotifier extends StateNotifier<List<Note>> {
  NotesNotifier(this.ref) : super([]) {
    _loadNotes();
  }

  final Ref ref;

  Future<void> _loadNotes() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final notesJson = prefs.getStringList(_notesKey) ?? [];
    state = notesJson.map((note) => Note.fromJson(note)).toList();
  }

  Future<void> _saveNotes() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final notesJson = state.map((note) => note.toJson()).toList();
    await prefs.setStringList(_notesKey, notesJson);
  }

  void addNote(Note note) {
    state = [...state, note];
    _saveNotes();
    if (note.reminder != null) {
      ref
          .read(notificationServiceProvider)
          .scheduleNotification(note.id.hashCode, 'Reminder', note.title, note.reminder!);
    }
  }

  void updateNote(Note note) {
    final oldNote = state.firstWhere((n) => n.id == note.id);
    if (oldNote.reminder != null) {
      ref.read(notificationServiceProvider).cancelNotification(oldNote.id.hashCode);
    }
    state = [
      for (final n in state)
        if (n.id == note.id) note else n,
    ];
    _saveNotes();
    if (note.reminder != null) {
      ref
          .read(notificationServiceProvider)
          .scheduleNotification(note.id.hashCode, 'Reminder', note.title, note.reminder!);
    }
  }

  void deleteNote(Note note) {
    state = state.where((n) => n.id != note.id).toList();
    _saveNotes();
    ref.read(deletedNotesProvider.notifier).addNote(note.copyWith(deletionDate: DateTime.now()));
    if (note.reminder != null) {
      ref.read(notificationServiceProvider).cancelNotification(note.id.hashCode);
    }
  }

  void deleteMultipleNotes(Set<String> noteIds) {
    final notesToDelete = state.where((note) => noteIds.contains(note.id)).toList();
    state = state.where((note) => !noteIds.contains(note.id)).toList();
    _saveNotes();

    final now = DateTime.now();
    final deletedNotesWithTimestamp =
        notesToDelete.map((note) => note.copyWith(deletionDate: now)).toList();
    ref
        .read(deletedNotesProvider.notifier)
        .addMultipleNotes(deletedNotesWithTimestamp);

    for (final note in notesToDelete) {
      if (note.reminder != null) {
        ref.read(notificationServiceProvider).cancelNotification(note.id.hashCode);
      }
    }
  }
}

final notesProvider = StateNotifierProvider<NotesNotifier, List<Note>>((ref) {
  return NotesNotifier(ref);
});

class DeletedNotesNotifier extends StateNotifier<List<Note>> {
  DeletedNotesNotifier(this.ref) : super([]) {
    _loadDeletedNotes();
    cleanupDeletedNotes();
  }

  final Ref ref;

  Future<void> _loadDeletedNotes() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final notesJson = prefs.getStringList(_deletedNotesKey) ?? [];
    state = notesJson.map((note) => Note.fromJson(note)).toList();
  }

  Future<void> _saveDeletedNotes() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final notesJson = state.map((note) => note.toJson()).toList();
    await prefs.setStringList(_deletedNotesKey, notesJson);
  }

  void addNote(Note note) {
    state = [...state, note];
    _saveDeletedNotes();
  }

  void addMultipleNotes(List<Note> notes) {
    state = [...state, ...notes];
    _saveDeletedNotes();
  }

  void restoreNote(Note note) {
    state = state.where((n) => n.id != note.id).toList();
    _saveDeletedNotes();
    ref.read(notesProvider.notifier).addNote(note.copyWith(deletionDate: null));
    if (note.reminder != null) {
      ref
          .read(notificationServiceProvider)
          .scheduleNotification(note.id.hashCode, 'Reminder', note.title, note.reminder!);
    }
  }

  void permanentlyDeleteNote(Note note) {
    state = state.where((n) => n.id != note.id).toList();
    _saveDeletedNotes();
    if (note.reminder != null) {
      ref.read(notificationServiceProvider).cancelNotification(note.id.hashCode);
    }
  }

  void cleanupDeletedNotes() {
    final now = DateTime.now();
    final notesToKeep = state.where((note) {
      if (note.deletionDate != null) {
        return now.difference(note.deletionDate!).inDays <= 30;
      }
      return true;
    }).toList();

    if (notesToKeep.length != state.length) {
      state = notesToKeep;
      _saveDeletedNotes();
    }
  }
}

final deletedNotesProvider = StateNotifierProvider<DeletedNotesNotifier, List<Note>>((ref) {
  return DeletedNotesNotifier(ref);
});
