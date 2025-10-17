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

enum DialogAction { save, discard, cancel }

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
  bool _isInitialized = false;
  Note? _initialNote;

  Color get _textColor =>
      _noteColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      if (widget.note != null) {
        _titleController.text = widget.note!.title;
        _contentController.text = widget.note!.content;
        _imagePaths = List<String>.from(widget.note!.imagePaths);
        _drawingData = widget.note!.drawing;
        _drawingImagePath = widget.note!.drawingImagePath;
        _reminder = widget.note!.reminder;
        _noteColor = widget.note!.themeColor != 'default'
            ? Color(int.parse(widget.note!.themeColor, radix: 16))
            : Theme.of(context).cardColor;
        if (widget.note!.checklist.isNotEmpty) {
          _isChecklist = true;
          _checklistItems =
              List<Map<String, dynamic>>.from(widget.note!.checklist);
          _checklistItemControllers.addAll(_checklistItems
              .map((item) => TextEditingController(text: item['text']))
              .toList());
        }
      } else {
        _noteColor = Theme.of(context).cardColor;
      }
      _isInitialized = true;
      _initialNote = widget.note?.copyWith() ??
          Note(
            title: '',
            content: '',
            creationDate: DateTime.now(),
            themeColor: _noteColor.value.toRadixString(16),
          );
      _titleController.addListener(_updateActiveNote);
      _contentController.addListener(_updateActiveNote);
      for (final controller in _checklistItemControllers) {
        controller.addListener(_updateActiveNote);
      }
      Future.microtask(
          () => ref.read(activeNoteProvider.notifier).state = _initialNote);
    }
  }

  @override
  void dispose() {
    Future.microtask(() => ref.read(activeNoteProvider.notifier).state = null);
    _titleController.dispose();
    _contentController.dispose();
    for (final controller in _checklistItemControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateActiveNote() {
    for (var i = 0; i < _checklistItems.length; i++) {
      _checklistItems[i]['text'] = _checklistItemControllers[i].text;
    }
    final checklist = _checklistItems
        .where((item) => (item['text'] as String).isNotEmpty)
        .toList();

    final activeNote = _initialNote?.copyWith(
      title: _titleController.text,
      content: _contentController.text,
      checklist: checklist,
      imagePaths: _imagePaths,
      themeColor: _noteColor.value.toRadixString(16),
      drawing: _drawingData,
      drawingImagePath: _drawingImagePath,
      reminder: _reminder,
    );
    ref.read(activeNoteProvider.notifier).state = activeNote;
  }

  void _addChecklistItem() {
    setState(() {
      _checklistItems.add({'text': '', 'checked': false});
      final controller = TextEditingController();
      controller.addListener(_updateActiveNote);
      _checklistItemControllers.add(controller);
    });
  }

  void _removeChecklistItem(int index) {
    setState(() {
      _checklistItemControllers[index].dispose();
      _checklistItemControllers.removeAt(index);
      _checklistItems.removeAt(index);
    });
    _updateActiveNote();
  }

  Future<void> _pickImage() async {
    final permission = await Permission.photos.request();
    if (permission.isGranted) {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() => _imagePaths.add(pickedFile.path));
        _updateActiveNote();
      }
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
                  _updateActiveNote();
                  Navigator.of(context).pop();
                },
                child: CircleAvatar(
                  backgroundColor: color,
                  child: _noteColor.value == color.value
                      ? Icon(Icons.check, color: _textColor)
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
        _updateActiveNote();
      }
    }
  }

  bool _isNoteModified() {
    for (var i = 0; i < _checklistItems.length; i++) {
      _checklistItems[i]['text'] = _checklistItemControllers[i].text;
    }
    final checklist = _checklistItems
        .where((item) => (item['text'] as String).isNotEmpty)
        .toList();

    final currentNote = _initialNote?.copyWith(
      title: _titleController.text,
      content: _contentController.text,
      checklist: checklist,
      imagePaths: _imagePaths,
      themeColor: _noteColor.value.toRadixString(16),
      drawing: _drawingData,
      drawingImagePath: _drawingImagePath,
      reminder: _reminder,
    );
    return !(_initialNote == currentNote);
  }

  bool _isNoteEmpty() {
    return _titleController.text.isEmpty &&
        _contentController.text.isEmpty &&
        _checklistItems.every((item) => (item['text'] as String).isEmpty) &&
        _imagePaths.isEmpty &&
        _drawingData == null;
  }

  Future<bool> _onWillPop() async {
    if (_isNoteModified() && !_isNoteEmpty()) {
      final action = await showDialog<DialogAction>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Save changes?'),
          content: const Text('Do you want to save the changes you made?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, DialogAction.discard),
              child: const Text('Discard'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, DialogAction.cancel),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, DialogAction.save),
              child: const Text('Save'),
            ),
          ],
        ),
      );

      switch (action) {
        case DialogAction.save:
          _saveNote(pop: false);
          return true;
        case DialogAction.discard:
          return true;
        case DialogAction.cancel:
          return false;
        default:
          return false;
      }
    }
    return true;
  }

  void _saveNote({bool pop = true}) {
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

    final isNewNote = widget.note == null;
    final isNoteEmpty = title.isEmpty &&
        (_isChecklist ? checklist.isEmpty : content.isEmpty) &&
        _imagePaths.isEmpty &&
        _drawingData == null;

    if (isNoteEmpty) {
      if (!isNewNote) {
        notesNotifier.deleteNote(widget.note!);
      }
    } else {
      final themeColorString = _noteColor.value.toRadixString(16);
      final note = Note(
        id: isNewNote ? null : widget.note!.id,
        title: title,
        content: content,
        creationDate: isNewNote ? DateTime.now() : widget.note!.creationDate,
        checklist: checklist,
        imagePaths: _imagePaths,
        themeColor: themeColorString,
        drawing: _drawingData,
        drawingImagePath: _drawingImagePath,
        reminder: _reminder,
      );

      if (isNewNote) {
        notesNotifier.addNote(note);
      } else {
        notesNotifier.updateNote(note);
      }
    }
    if (pop && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  Widget _buildTextEditor() {
    return TextField(
      controller: _contentController,
      style: TextStyle(color: _textColor),
      decoration: InputDecoration(
        hintText: 'Content',
        border: InputBorder.none,
        hintStyle: TextStyle(color: _textColor.withOpacity(0.6)),
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
            leading: Icon(Icons.add, color: _textColor),
            title: Text('Add item', style: TextStyle(color: _textColor)),
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
                _updateActiveNote();
              },
              activeColor: _textColor,
              checkColor: _noteColor,
            ),
            Expanded(
              child: TextField(
                controller: _checklistItemControllers[index],
                style: TextStyle(
                  color: _textColor,
                  decoration: _checklistItems[index]['checked']
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
                decoration: InputDecoration(
                  hintText: 'List item',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: _textColor.withOpacity(0.6)),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: _textColor),
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
            _handleDrawingResult(await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DrawingPage(drawingData: _drawingData),
              ),
            ));
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
              _updateActiveNote();
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

  void _handleDrawingResult(Map<String, dynamic>? result) async {
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
      _updateActiveNote();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
            backgroundColor: _noteColor,
            appBar: AppBar(
        backgroundColor: _noteColor,
        elevation: 0,
        title: Text(widget.note == null ? 'New Note' : 'Edit Note'),
        iconTheme: IconThemeData(color: _textColor),
        actionsIconTheme: IconThemeData(color: _textColor),
        titleTextStyle: TextStyle(
          color: _textColor,
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
                    content: const Text(
                        'Are you sure you want to delete this note?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
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
                style: TextStyle(
                  fontSize: 24,
                  color: _textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_reminder != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Chip(
                    label: Text(
                      'Reminder: ${DateFormat.yMd().add_jm().format(_reminder!)}',
                    ),
                    onDeleted: () {
                      setState(() => _reminder = null);
                      _updateActiveNote();
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
                color: _textColor,
              ),
              onPressed: () {
                setState(() => _isChecklist = !_isChecklist);
                _updateActiveNote();
              },
            ),
            IconButton(
              icon: Icon(Icons.image, color: _textColor),
              onPressed: _pickImage,
            ),
            IconButton(
              icon: Icon(Icons.color_lens, color: _textColor),
              onPressed: _pickColor,
            ),
            IconButton(
              icon: Icon(Icons.alarm, color: _textColor),
              onPressed: _setReminder,
            ),
            IconButton(
              icon: Icon(Icons.brush, color: _textColor),
              onPressed: () async =>
                  _handleDrawingResult(await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DrawingPage(drawingData: _drawingData),
                ),
              )),
            ),
          ],
        ),
      ),
    ));
  }
}
