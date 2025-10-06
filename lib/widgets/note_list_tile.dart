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
    final color = note.themeColor != 'default'
        ? Color(int.parse(note.themeColor, radix: 16))
        : Theme.of(context).cardColor;
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Card(
        color: isSelected ? Colors.blue.withOpacity(0.5) : color,
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        child: ListTile(
          leading: isSelected
              ? const Icon(Icons.check_circle, color: Colors.white)
              : null,
          title: Text(
            note.title,
            style: const TextStyle(color: Colors.black),
          ),
          subtitle: note.checklist.isNotEmpty
              ? _buildChecklistPreview(note.checklist)
              : Text(
                  note.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black),
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
