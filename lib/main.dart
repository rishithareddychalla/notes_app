import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/models/note.dart';
import 'package:notes_app/providers/note_provider.dart';
import 'package:notes_app/providers/settings_provider.dart';
import 'package:notes_app/screens/home_page.dart';
import 'package:notes_app/services/notification_service.dart';
import 'package:notes_app/utils/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

final notificationServiceProvider =
    Provider<NotificationService>((ref) => NotificationService());

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final notificationService = NotificationService();
  await notificationService.init();

  runApp(ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      notificationServiceProvider.overrideWithValue(notificationService),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      final activeNote = ref.read(activeNoteProvider);
      if (activeNote != null) {
        final notesNotifier = ref.read(notesProvider.notifier);
        final isNewNote = activeNote.id == null;
        final isNoteEmpty = activeNote.title.isEmpty &&
            activeNote.content.isEmpty &&
            activeNote.checklist.isEmpty &&
            activeNote.imagePaths.isEmpty &&
            activeNote.drawing == null;

        if (!isNoteEmpty) {
          if (isNewNote) {
            notesNotifier.addNote(activeNote);
          } else {
            notesNotifier.updateNote(activeNote);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(settingsProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Notes App',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      home: const HomePage(),
    );
  }
}