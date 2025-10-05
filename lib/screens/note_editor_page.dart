import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:notes_app/models/note.dart';
import 'package:notes_app/providers/note_provider.dart';
import 'package:notes_app/screens/drawing_page.dart';
import 'package:notes_app/utils/colors.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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
  Color _noteColor = noteColors.first;
  String? _drawingData;
  String? _drawingImagePath;
  DateTime? _reminder;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _imagePaths = List<String>.from(widget.note!.imagePaths);
      _drawingData = widget.note!.drawing;
      _drawingImagePath = widget.note!.drawingImagePath;
      _reminder = widget.note!.reminder;
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
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: noteColors.length,
            itemBuilder: (context, index) {
              final color = noteColors[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _noteColor = color;
                  });
                  Navigator.of(context).pop();
                },
                child: CircleAvatar(
                  backgroundColor: color,
                  child: _noteColor == color
                      ? const Icon(Icons.check, color: Colors.black)
                      : null,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _setReminder() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _reminder ?? now,
      firstDate: now,
      lastDate: DateTime(2101),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_reminder ?? now),
      );

      if (time != null) {
        setState(() {
          _reminder =
              DateTime(date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
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
        _imagePaths.isEmpty &&
        _drawingData == null) {
      if (widget.note != null) {
        notesNotifier.deleteNote(widget.note!);
      }
      Navigator.pop(context);
      return;
    }
    final themeColorString = _noteColor.value.toRadixString(16);

    if (widget.note == null) {
      // Add new note
      final newNote = Note(
        title: title,
        content: content,
        creationDate: DateTime.now(),
        checklist: checklist,
        imagePaths: _imagePaths,
        themeColor: themeColorString,
        drawing: _drawingData,
        drawingImagePath: _drawingImagePath,
        reminder: _reminder,
      );
      notesNotifier.addNote(newNote);
    } else {
      // Update existing note
      final updatedNote = widget.note!.copyWith(
        title: title,
        content: content,
        checklist: checklist,
        imagePaths: _imagePaths,
        themeColor: themeColorString,
        drawing: _drawingData,
        drawingImagePath: _drawingImagePath,
        reminder: _reminder,
      );
      notesNotifier.updateNote(updatedNote);
    }

    Navigator.pop(context);
  }

  Widget _buildTextEditor() {
    return TextField(
      controller: _contentController,
      style: const TextStyle(color: Colors.black),
      decoration: const InputDecoration(
        hintText: 'Content',
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.black54),
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
            leading: const Icon(Icons.add, color: Colors.black),
            title: const Text('Add item', style: TextStyle(color: Colors.black)),
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
              activeColor: Colors.black,
              checkColor: _noteColor,
            ),
            Expanded(
              child: TextField(
                controller: _checklistItemControllers[index],
                style: TextStyle(
                  color: Colors.black,
                  decoration: _checklistItems[index]['checked']
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
                decoration: const InputDecoration(
                  hintText: 'List item',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.black54),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.black),
              onPressed: () => _removeChecklistItem(index),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDrawingPreview() {
    if (_drawingImagePath == null || _drawingImagePath!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        GestureDetector(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DrawingPage(drawingData: _drawingData),
              ),
            );

            if (result != null) {
              _drawingData = result['json'];
              final imageBytes = result['image'] as Uint8List?;
              if (imageBytes != null) {
                final directory = await getApplicationDocumentsDirectory();
                final path =
                    '${directory.path}/drawing_${DateTime.now().millisecondsSinceEpoch}.png';
                final file = File(path);
                await file.writeAsBytes(imageBytes);
                setState(() {
                  _drawingImagePath = path;
                });
              }
            }
          },
          child: Image.file(
            File(_drawingImagePath!),
            width: double.infinity,
            height: 200,
            fit: BoxFit.contain,
          ),
        ),
        Positioned(
          top: -10,
          right: -10,
          child: IconButton(
            icon: const Icon(Icons.remove_circle, color: Colors.red),
            onPressed: () {
              setState(() {
                _drawingData = null;
                _drawingImagePath = null;
              });
            },
          ),
        ),
      ],
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
        iconTheme: const IconThemeData(color: Colors.black),
        actionsIconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
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
              if (_reminder != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Chip(
                    label: Text(
                        'Reminder: ${DateFormat.yMd().add_jm().format(_reminder!)}'),
                    onDeleted: () {
                      setState(() {
                        _reminder = null;
                      });
                    },
                  ),
                ),
              const SizedBox(height: 16),
              _buildDrawingPreview(),
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
              icon: Icon(
                _isChecklist ? Icons.notes : Icons.check_box_outline_blank,
                color: Colors.black,
              ),
              onPressed: () {
                setState(() {
                  _isChecklist = !_isChecklist;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.image, color: Colors.black),
              onPressed: _pickImage,
            ),
            IconButton(
              icon: const Icon(Icons.color_lens, color: Colors.black),
              onPressed: _pickColor,
            ),
            IconButton(
              icon: const Icon(Icons.alarm, color: Colors.black),
              onPressed: _setReminder,
            ),
            IconButton(
              icon: const Icon(Icons.brush, color: Colors.black),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DrawingPage(drawingData: _drawingData),
                  ),
                );

                if (result != null) {
                  _drawingData = result['json'];
                  final imageBytes = result['image'] as Uint8List?;
                  if (imageBytes != null) {
                    final directory =
                        await getApplicationDocumentsDirectory();
                    final path =
                        '${directory.path}/drawing_${DateTime.now().millisecondsSinceEpoch}.png';
                    final file = File(path);
                    await file.writeAsBytes(imageBytes);
                    setState(() {
                      _drawingImagePath = path;
                    });
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}