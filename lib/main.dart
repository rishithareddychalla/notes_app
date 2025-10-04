import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/providers/settings_provider.dart';
import 'package:notes_app/screens/home_page.dart';
import 'package:notes_app/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final notificationServiceProvider =
    Provider<NotificationService>((ref) => throw UnimplementedError());

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
