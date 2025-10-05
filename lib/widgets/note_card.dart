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
    final color = note.themeColor != 'default'
        ? Color(int.parse(note.themeColor, radix: 16))
        : Theme.of(context).cardColor;
    return Card(
      color: color,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.title,
                style: const TextStyle(
                  fontSize: 18,
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
