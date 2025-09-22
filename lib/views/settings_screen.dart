import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/views/recently_deleted_screen.dart';

final isCardViewProvider = StateProvider<bool>((ref) => true);

class SettingsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCardView = ref.watch(isCardViewProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('Card View'),
            value: isCardView,
            onChanged: (value) {
              ref.read(isCardViewProvider.notifier).state = value;
            },
          ),
          ListTile(
            title: Text('Recently Deleted'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => RecentlyDeletedScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
