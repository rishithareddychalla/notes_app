import 'package:flutter/material.dart';
import 'package:notes_app/models/note.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const NoteCard({
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
        : theme.cardColor;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Card(
        color: isSelected
            ? theme.colorScheme.tertiary.withOpacity(0.5)
            : noteColor,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (note.checklist.isNotEmpty)
                    _buildChecklistPreview(context, note.checklist)
                  else
                    Text(
                      note.content,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.black),
                    ),
                ],
              ),
            ),
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.onTertiary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistPreview(
      BuildContext context, List<Map<String, dynamic>> checklist) {
    final theme = Theme.of(context);
    final noteColor = note.themeColor != 'default'
        ? Color(int.parse(note.themeColor, radix: 16))
        : theme.cardColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: checklist.take(5).map((item) {
        return Row(
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: item['checked'],
                onChanged: null, // Make it non-interactive in preview
                activeColor: Colors.black,
                checkColor: noteColor,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item['text'],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.black,
                  decoration: item['checked']
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
