import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:notes_app/main.dart';
import 'package:notes_app/models/note.dart';
import 'package:notes_app/services/hive_service.dart';
import 'package:notes_app/views/home_screen.dart';
import 'package:mockito/mockito.dart';

class MockHiveService extends Mock implements HiveService {
  @override
  Future<List<Note>> getAllNotes() async {
    return [];
  }
}

void main() {
  setUpAll(() async {
    // We need to initialize Hive and register the adapter for the tests.
    // This is a workaround for the tests. In a real app, we would use a
    // separate test setup.
    final hiveTestPath = './test/hive_test_path';
    Hive.init(hiveTestPath);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(NoteAdapter());
    }
  });

  testWidgets('HomeScreen displays "No notes yet" message', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          hiveServiceProvider.overrideWithValue(MockHiveService()),
        ],
        child: MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    // The first frame is a loading state.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Pump a frame to settle the FutureProvider.
    await tester.pump();

    // Now the UI should show the "No notes yet" message.
    expect(find.text('No notes yet. Tap the + button to add one!'), findsOneWidget);
  });
}
