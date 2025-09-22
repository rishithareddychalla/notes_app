import 'package:hive_flutter/hive_flutter.dart';
import 'package:notes_app/models/note.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class HiveService {
  static const String notesBoxName = 'notes';
  static const String deletedNotesBoxName = 'deleted_notes';

  Future<void> init() async {
    final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);
    Hive.registerAdapter(NoteAdapter());
    await Hive.openBox<Note>(notesBoxName);
    await Hive.openBox<Note>(deletedNotesBoxName);
    await cleanupDeletedNotes();
  }

  Future<void> addNote(Note note) async {
    final box = await Hive.openBox<Note>(notesBoxName);
    await box.add(note);
  }

  Future<List<Note>> getAllNotes() async {
    final box = await Hive.openBox<Note>(notesBoxName);
    return box.values.toList();
  }

  Future<void> updateNote(dynamic key, Note note) async {
    final box = await Hive.openBox<Note>(notesBoxName);
    await box.put(key, note);
  }

  Future<void> deleteNote(dynamic key) async {
    final notesBox = await Hive.openBox<Note>(notesBoxName);
    final deletedNotesBox = await Hive.openBox<Note>(deletedNotesBoxName);
    final noteToDelete = notesBox.get(key);
    if (noteToDelete != null) {
      noteToDelete.deletionDate = DateTime.now();
      await deletedNotesBox.add(noteToDelete);
      await notesBox.delete(key);
    }
  }

  Future<List<Note>> getDeletedNotes() async {
    final box = await Hive.openBox<Note>(deletedNotesBoxName);
    return box.values.toList();
  }

  Future<void> restoreNote(dynamic key) async {
    final notesBox = await Hive.openBox<Note>(notesBoxName);
    final deletedNotesBox = await Hive.openBox<Note>(deletedNotesBoxName);
    final noteToRestore = deletedNotesBox.get(key);
    if (noteToRestore != null) {
      noteToRestore.deletionDate = null;
      await notesBox.add(noteToRestore);
      await deletedNotesBox.delete(key);
    }
  }

  Future<void> permanentlyDeleteNote(dynamic key) async {
    final box = await Hive.openBox<Note>(deletedNotesBoxName);
    await box.delete(key);
  }

  Future<void> cleanupDeletedNotes() async {
    final box = await Hive.openBox<Note>(deletedNotesBoxName);
    final thirtyDaysAgo = DateTime.now().subtract(Duration(days: 30));
    for (var key in box.keys) {
      final note = box.get(key);
      if (note != null && note.deletionDate != null && note.deletionDate!.isBefore(thirtyDaysAgo)) {
        await box.delete(key);
      }
    }
  }
}
