import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app/models/note.dart';
import 'package:notes_app/screens/note_editor_page.dart';

// Transparent 1x1 PNG
const List<int> kTransparentImage = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
];

void main() {
  testWidgets('NoteEditorPage UI Test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: NoteEditorPage(),
        ),
      ),
    );

    // Verify that the title and content fields are present
    expect(find.widgetWithText(TextField, 'Title'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Content'), findsOneWidget);

    // Verify that the bottom app bar and its buttons are present
    expect(find.byType(BottomAppBar), findsOneWidget);
    expect(find.byIcon(Icons.check_box_outline_blank), findsOneWidget);
    expect(find.byIcon(Icons.image), findsOneWidget);
    expect(find.byIcon(Icons.color_lens), findsOneWidget);
  });

  testWidgets('Checklist functionality', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: NoteEditorPage(),
        ),
      ),
    );

    // Tap the checklist button to switch to checklist mode
    await tester.tap(find.byIcon(Icons.check_box_outline_blank));
    await tester.pump();

    // Verify that the editor is in checklist mode
    expect(find.byIcon(Icons.notes), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'Add item'), findsOneWidget);

    // Add a checklist item
    await tester.tap(find.widgetWithText(ListTile, 'Add item'));
    await tester.pump();

    // Verify that a new checklist item is added
    expect(find.byType(Checkbox), findsOneWidget);
    expect(find.widgetWithText(TextField, 'List item'), findsOneWidget);
  });

  testWidgets('Image attachment UI updates', (WidgetTester tester) async {
    final directory = await Directory.systemTemp.createTemp();
    final fakeImage = File('${directory.path}/fake.png');
    await fakeImage.writeAsBytes(kTransparentImage);

    final noteWithImage = Note(
      title: 'Test Note',
      content: 'This is a test note.',
      creationDate: DateTime.now(),
      imagePaths: [fakeImage.path],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: NoteEditorPage(note: noteWithImage),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify that the GridView for images is displayed
    expect(find.byType(GridView), findsOneWidget);
    // Verify that an image is displayed
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('Theme color functionality UI updates',
      (WidgetTester tester) async {
    final noteWithColor = Note(
      title: 'Test Note',
      content: 'This is a test note.',
      creationDate: DateTime.now(),
      themeColor: Colors.blue.value.toRadixString(16),
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: NoteEditorPage(note: noteWithColor),
        ),
      ),
    );

    // Verify that the background color of the Scaffold has changed
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, Colors.blue);
  });
}