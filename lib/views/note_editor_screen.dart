import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notes_app/main.dart';
import 'package:notes_app/models/note.dart';
import 'package:notes_app/views/home_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class NoteEditorScreen extends ConsumerStatefulWidget {
  final Note? note;

  NoteEditorScreen({this.note});

  @override
  _NoteEditorScreenState createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  List<Map<String, dynamic>> _checklist = [];
  List<String> _imagePaths = [];
  bool _isChecklistMode = false;
  String _originalTitle = '';
  String _originalContent = '';
  List<Map<String, dynamic>> _originalChecklist = [];
  List<String> _originalImagePaths = [];

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _checklist = List<Map<String, dynamic>>.from(widget.note!.checklist);
      _imagePaths = List<String>.from(widget.note!.imagePaths);

      _originalTitle = widget.note!.title;
      _originalContent = widget.note!.content;
      _originalChecklist = List<Map<String, dynamic>>.from(widget.note!.checklist);
      _originalImagePaths = List<String>.from(widget.note!.imagePaths);

      if (_checklist.isNotEmpty) {
        _isChecklistMode = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
        title: Text(widget.note == null ? 'New Note' : 'Edit Note'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _deleteNote();
            },
          ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              _saveNote();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Title',
                border: InputBorder.none,
              ),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildAttachments(),
            Expanded(
              child: _isChecklistMode ? _buildChecklist() : _buildTextField(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.image),
              onPressed: _pickImage,
            ),
            IconButton(
              icon: Icon(Icons.check_box),
              onPressed: () {
                setState(() {
                  _isChecklistMode = !_isChecklistMode;
                });
              },
            ),
            IconButton(icon: Icon(Icons.color_lens), onPressed: () {}),
            IconButton(icon: Icon(Icons.font_download), onPressed: () {}),
            IconButton(icon: Icon(Icons.mic), onPressed: () {}),
            IconButton(icon: Icon(Icons.alarm), onPressed: () {}),
          ],
        ),
      ),
      floatingActionButton: _isChecklistMode
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  _checklist.add({'text': '', 'isChecked': false});
                });
              },
              child: Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildTextField() {
    return TextField(
      controller: _contentController,
      decoration: InputDecoration(
        hintText: 'Note content',
        border: InputBorder.none,
      ),
      maxLines: null,
    );
  }

  Widget _buildChecklist() {
    return ListView.builder(
      itemCount: _checklist.length,
      itemBuilder: (context, index) {
        return Row(
          children: [
            Checkbox(
              value: _checklist[index]['isChecked'],
              onChanged: (value) {
                setState(() {
                  _checklist[index]['isChecked'] = value!;
                });
              },
            ),
            Expanded(
              child: TextFormField(
                initialValue: _checklist[index]['text'],
                onChanged: (text) {
                  _checklist[index]['text'] = text;
                },
                decoration: InputDecoration(
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAttachments() {
    return _imagePaths.isEmpty
        ? Container()
        : SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _imagePaths.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.file(File(_imagePaths[index])),
                );
              },
            ),
          );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = path.basename(pickedFile.path);
      final savedImage = await File(pickedFile.path).copy('${appDir.path}/$fileName');
      setState(() {
        _imagePaths.add(savedImage.path);
      });
    }
  }

  void _saveNote({bool pop = true}) {
    final title = _titleController.text;
    final content = _contentController.text;

    if (title.isEmpty && content.isEmpty && _checklist.isEmpty && _imagePaths.isEmpty) {
      if (pop) Navigator.of(context).pop();
      return;
    }

    final hiveService = ref.read(hiveServiceProvider);
    final now = DateTime.now();

    final noteToSave = Note(
      title: title,
      content: _isChecklistMode ? '' : content,
      creationDate: widget.note?.creationDate ?? now,
      checklist: _isChecklistMode ? _checklist : [],
      imagePaths: _imagePaths,
      documentPaths: widget.note?.documentPaths ?? [],
      themeColor: widget.note?.themeColor ?? 'default',
      fontStyle: widget.note?.fontStyle ?? 'default',
      paragraphStyle: widget.note?.paragraphStyle ?? 'default',
      reminder: widget.note?.reminder,
    );

    if (widget.note == null) {
      hiveService.addNote(noteToSave);
    } else {
      hiveService.updateNote(widget.note!.key, noteToSave);
    }

    ref.refresh(notesProvider);
    if (pop) Navigator.of(context).pop();
  }

  bool get _hasChanged {
    final titleChanged = _titleController.text != _originalTitle;
    final contentChanged = _contentController.text != _originalContent;
    final checklistChanged = _checklist.toString() != _originalChecklist.toString();
    final imagesChanged = _imagePaths.toString() != _originalImagePaths.toString();
    return titleChanged || contentChanged || checklistChanged || imagesChanged;
  }

  Future<bool> _onWillPop() async {
    if (_hasChanged) {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Save changes?'),
          content: Text('Do you want to save the changes you made to this note?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Discard
              child: Text('Discard'),
            ),
            TextButton(
              onPressed: () {
                _saveNote(pop: false);
                Navigator.of(context).pop(true); // Save and pop screen
              },
              child: Text('Save'),
            ),
          ],
        ),
      );
      return result ?? false;
    }
    return true;
  }

  void _deleteNote() {
    if (widget.note != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Delete Note?'),
          content: Text('Are you sure you want to delete this note?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final hiveService = ref.read(hiveServiceProvider);
                hiveService.deleteNote(widget.note!.key);
                ref.refresh(notesProvider);
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: Text('Delete'),
            ),
          ],
        ),
      );
    }
  }
}
