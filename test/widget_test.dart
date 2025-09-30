import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app/main.dart';
import 'package:notes_app/screens/note_editor_page.dart';

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
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: NoteEditorPage(),
        ),
      ),
    );

    // Get the state of the NoteEditorPage
    final dynamic state = tester.state(find.byType(NoteEditorPage));

    // Simulate adding an image path
    state.setState(() {
      state._imagePaths.add('/fake/image.jpg');
    });
    await tester.pump();

    // Verify that the GridView for images is displayed
    expect(find.byType(GridView), findsOneWidget);
  });

  testWidgets('Theme color functionality UI updates', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: NoteEditorPage(),
        ),
      ),
    );

    // Get the state of the NoteEditorPage
    final dynamic state = tester.state(find.byType(NoteEditorPage));

    // Simulate changing the note color
    state.setState(() {
      state._noteColor = Colors.blue;
    });
    await tester.pump();

    // Verify that the background color of the Scaffold has changed
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, Colors.blue);
  });
}