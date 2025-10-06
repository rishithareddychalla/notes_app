import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app/models/note.dart';
import 'package:notes_app/screens/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final testNotes = [
    Note(
        id: '1',
        title: 'Note 1',
        content: 'Content 1',
        creationDate: DateTime.now()),
    Note(
        id: '2',
        title: 'Note 2',
        content: 'Content 2',
        creationDate: DateTime.now()),
    Note(
        id: '3',
        title: 'Note 3',
        content: 'Content 3',
        creationDate: DateTime.now()),
  ];

  final notesJson = testNotes.map((note) => note.toJson()).toList();

  testWidgets('HomePage multi-select and delete', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'notes': notesJson,
      'deleted_notes': <String>[],
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: HomePage(),
        ),
      ),
    );

    // Wait for notes to load
    await tester.pumpAndSettle();

    // Verify initial state
    expect(find.text('Note 1'), findsOneWidget);
    expect(find.text('Note 2'), findsOneWidget);
    expect(find.text('Note 3'), findsOneWidget);
    expect(find.text('Notes'), findsOneWidget); // Normal app bar title

    // Long press to enter selection mode
    await tester.longPress(find.text('Note 1'));
    await tester.pump();

    // Verify selection mode UI
    expect(find.text('1 selected'), findsOneWidget);
    expect(find.byIcon(Icons.delete), findsOneWidget);

    // Select another note
    await tester.tap(find.text('Note 2'));
    await tester.pump();
    expect(find.text('2 selected'), findsOneWidget);

    // Deselect a note
    await tester.tap(find.text('Note 1'));
    await tester.pump();
    expect(find.text('1 selected'), findsOneWidget);

    // Reselect note 1
    await tester.tap(find.text('Note 1'));
    await tester.pump();
    expect(find.text('2 selected'), findsOneWidget);

    // Delete selected notes
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();

    // Verify notes are deleted from home page
    expect(find.text('Note 1'), findsNothing);
    expect(find.text('Note 2'), findsNothing);
    expect(find.text('Note 3'), findsOneWidget);

    // Verify app bar is back to normal
    expect(find.text('Notes'), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    final deletedNotesRaw = prefs.getStringList('deleted_notes');
    expect(deletedNotesRaw, isNotNull);
    final deletedNotes = deletedNotesRaw!.map((e) => Note.fromJson(e)).toList();
    expect(deletedNotes.length, 2);
    expect(deletedNotes.any((n) => n.id == '1'), isTrue);
    expect(deletedNotes.any((n) => n.id == '2'), isTrue);
  });
}