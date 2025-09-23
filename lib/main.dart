import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:notes_app/models/note_view_adapter.dart';
import 'package:notes_app/providers/note_provider.dart';
import 'package:notes_app/providers/settings_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:notes_app/models/note.dart';
import 'package:notes_app/screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);
  Hive.registerAdapter(NoteAdapter());
  Hive.registerAdapter(NoteViewAdapter());
  await Hive.openBox<Note>('notes');
  await Hive.openBox<Note>('deleted_notes');
  await Hive.openBox('settings');

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(settingsProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Notes App',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeMode,
      home: const HomePage(),
    );
  }
}
