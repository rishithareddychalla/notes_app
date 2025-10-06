import 'package:flutter/material.dart';
import 'package:notes_app/models/note.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = note.themeColor != 'default'
        ? Color(int.parse(note.themeColor, radix: 16))
        : theme.cardColor;

    return Card(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.title,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.black,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              if (note.checklist.isNotEmpty)
                _buildChecklistPreview(context, note.checklist)
              else
                Text(
                  note.content,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.black87,
                  ),
                ),
            ],
          ),
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
                onChanged: null,
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
                style: theme.textTheme.bodyMedium?.copyWith(
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
