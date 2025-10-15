import 'package:flutter/material.dart';
import 'package:notes_app/models/note.dart';

class NoteListTile extends StatelessWidget {
  final Note note;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const NoteListTile({
    super.key,
    required this.note,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final noteColor = note.themeColor != 'default'
        ? Color(int.parse(note.themeColor, radix: 16))
        : theme.colorScheme.surface;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Card(
        color: isSelected
            ? theme.colorScheme.tertiary.withOpacity(0.5)
            : noteColor,
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        elevation: 1,
        shadowColor: Colors.grey.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          leading: isSelected
              ? Icon(Icons.check_circle, color: theme.colorScheme.onTertiary)
              : null,
          title: Text(
            note.title,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          subtitle: note.checklist.isNotEmpty
              ? _buildChecklistPreview(note.checklist)
              : Text(
                  note.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
        ),
      ),
    );
  }

  Widget _buildChecklistPreview(List<Map<String, dynamic>> checklist) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: checklist.take(2).map((item) {
        return Text(
          '- ${item['text']}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.black,
            decoration: item['checked']
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        );
      }).toList(),
    );
  }
}
