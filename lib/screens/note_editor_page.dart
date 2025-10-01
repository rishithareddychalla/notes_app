import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notes_app/models/note.dart';
import 'package:notes_app/providers/note_provider.dart';
import 'package:notes_app/screens/drawing_page.dart';

class NoteEditorPage extends ConsumerStatefulWidget {
  final Note? note;

  const NoteEditorPage({super.key, this.note});

  @override
  _NoteEditorPageState createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends ConsumerState<NoteEditorPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isChecklist = false;
  List<Map<String, dynamic>> _checklistItems = [];
  final List<TextEditingController> _checklistItemControllers = [];
  List<String> _imagePaths = [];
  Color _noteColor = Colors.white;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _imagePaths = List<String>.from(widget.note!.imagePaths);
      _noteColor = widget.note!.themeColor != 'default'
          ? Color(int.parse(widget.note!.themeColor, radix: 16))
          : Colors.white;
      if (widget.note!.checklist.isNotEmpty) {
        setState(() {
          _isChecklist = true;
          _checklistItems =
              List<Map<String, dynamic>>.from(widget.note!.checklist);
          _checklistItemControllers.addAll(_checklistItems
              .map((item) => TextEditingController(text: item['text']))
              .toList());
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    for (final controller in _checklistItemControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addChecklistItem() {
    setState(() {
      _checklistItems.add({'text': '', 'checked': false});
      _checklistItemControllers.add(TextEditingController());
    });
  }

  void _removeChecklistItem(int index) {
    setState(() {
      _checklistItemControllers[index].dispose();
      _checklistItemControllers.removeAt(index);
      _checklistItems.removeAt(index);
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imagePaths.add(pickedFile.path);
      });
    }
  }

  void _pickColor() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _noteColor,
            onColorChanged: (color) {
              setState(() {
                _noteColor = color;
              });
            },
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _saveNote() {
    final title = _titleController.text;
    final notesNotifier = ref.read(notesProvider.notifier);

    String content = '';
    List<Map<String, dynamic>> checklist = [];

    if (_isChecklist) {
      for (var i = 0; i < _checklistItems.length; i++) {
        _checklistItems[i]['text'] = _checklistItemControllers[i].text;
      }
      checklist = _checklistItems
          .where((item) => (item['text'] as String).isNotEmpty)
          .toList();
    } else {
      content = _contentController.text;
    }

    if (title.isEmpty &&
        content.isEmpty &&
        checklist.isEmpty &&
        _imagePaths.isEmpty) {
      if (widget.note != null) {
        notesNotifier.deleteNote(widget.note!);
      }
      Navigator.pop(context);
      return;
    }

    if (widget.note == null) {
      // Add new note
      final newNote = Note(
        title: title,
        content: content,
        creationDate: DateTime.now(),
        checklist: checklist,
        imagePaths: _imagePaths,
        themeColor: _noteColor.value.toRadixString(16),
      );
      notesNotifier.addNote(newNote);
    } else {
      // Update existing note
      final updatedNote = widget.note!.copyWith(
        title: title,
        content: content,
        checklist: checklist,
        imagePaths: _imagePaths,
        themeColor: _noteColor.value.toRadixString(16),
      );
      notesNotifier.updateNote(updatedNote);
    }

    Navigator.pop(context);
  }

  Widget _buildTextEditor() {
    return TextField(
      controller: _contentController,
      decoration: const InputDecoration(
        hintText: 'Content',
        border: InputBorder.none,
      ),
      maxLines: null,
      keyboardType: TextInputType.multiline,
    );
  }

  Widget _buildChecklistEditor() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _checklistItems.length + 1,
      itemBuilder: (context, index) {
        if (index == _checklistItems.length) {
          return ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Add item'),
            onTap: _addChecklistItem,
          );
        }
        return Row(
          children: [
            Checkbox(
              value: _checklistItems[index]['checked'],
              onChanged: (value) {
                setState(() {
                  _checklistItems[index]['checked'] = value!;
                });
              },
            ),
            Expanded(
              child: TextField(
                controller: _checklistItemControllers[index],
                decoration: const InputDecoration(
                  hintText: 'List item',
                  border: InputBorder.none,
                ),
                style: TextStyle(
                  decoration: _checklistItems[index]['checked']
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _removeChecklistItem(index),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImageGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
      ),
      itemCount: _imagePaths.length,
      itemBuilder: (context, index) {
        return Stack(
          children: [
            Image.file(File(_imagePaths[index]),
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover),
            Positioned(
              top: -10,
              right: -10,
              child: IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () {
                  setState(() {
                    _imagePaths.removeAt(index);
                  });
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _noteColor,
      appBar: AppBar(
        backgroundColor: _noteColor,
        elevation: 0,
        title: Text(widget.note == null ? 'New Note' : 'Edit Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveNote,
          ),
          if (widget.note != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Note'),
                    content:
                        const Text('Are you sure you want to delete this note?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          ref
                              .read(notesProvider.notifier)
                              .deleteNote(widget.note!);
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Title',
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (_imagePaths.isNotEmpty) ...[
                _buildImageGrid(),
                const SizedBox(height: 16),
              ],
              _isChecklist ? _buildChecklistEditor() : _buildTextEditor(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: _noteColor,
        elevation: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(_isChecklist
                  ? Icons.notes
                  : Icons.check_box_outline_blank),
              onPressed: () {
                setState(() {
                  _isChecklist = !_isChecklist;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.image),
              onPressed: _pickImage,
            ),
            IconButton(
              icon: const Icon(Icons.color_lens),
              onPressed: _pickColor,
            ),
            IconButton(
              icon: const Icon(Icons.brush),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DrawingPage(),
                  ),
                );

                if (result != null) {
                  setState(() {
                    _imagePaths.add(result);
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}