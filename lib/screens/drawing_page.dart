import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:flutter_drawing_board/paint_contents.dart';

class DrawingPage extends StatefulWidget {
  final String? drawingData;

  const DrawingPage({super.key, this.drawingData});

  @override
  _DrawingPageState createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  final DrawingController _drawingController = DrawingController();
  Color _selectedColor = Colors.black;
  double _strokeWidth = 4.0;
  final List<Color> _colors = [
    Colors.black,
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
  ];

  @override
  void initState() {
    super.initState();
    _drawingController.setStyle(
      color: _selectedColor,
      strokeWidth: _strokeWidth,
    );
    if (widget.drawingData != null && widget.drawingData!.isNotEmpty) {
      final List<dynamic> history = jsonDecode(widget.drawingData!);
      final List<PaintContent> contents = history
          .map((item) => _getPaintContentFromJson(item as Map<String, dynamic>))
          .toList();
      _drawingController.addContents(contents);
    }
  }

  @override
  void dispose() {
    _drawingController.dispose();
    super.dispose();
  }

  PaintContent _getPaintContentFromJson(Map<String, dynamic> json) {
    final String type = json['type'] as String;
    switch (type) {
      case 'SimpleLine':
        return SimpleLine.fromJson(json);
      case 'SmoothLine':
        return SmoothLine.fromJson(json);
      case 'StraightLine':
        return StraightLine.fromJson(json);
      case 'Rectangle':
        return Rectangle.fromJson(json);
      case 'Circle':
        return Circle.fromJson(json);
      case 'Eraser':
        return Eraser.fromJson(json);
      default:
        throw Exception('Unknown PaintContent type: $type');
    }
  }

  Widget _buildColorPalette() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _colors.map((color) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: const SizedBox.shrink(),
              selected: _selectedColor == color,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedColor = color;
                    _drawingController.setStyle(color: _selectedColor);
                  });
                }
              },
              backgroundColor: color,
              selectedColor: color,
              shape: const CircleBorder(),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStrokeWidthSlider() {
    return Slider(
      value: _strokeWidth,
      min: 1.0,
      max: 20.0,
      onChanged: (value) {
        setState(() {
          _strokeWidth = value;
          _drawingController.setStyle(strokeWidth: _strokeWidth);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drawing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: () {
              _drawingController.undo();
            },
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            onPressed: () {
              _drawingController.redo();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _drawingController.clear();
            },
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () async {
              final drawingJson = jsonEncode(_drawingController.getJsonList());
              final imageBytes = await _drawingController.getImageData();
              Navigator.pop(context, {
                'json': drawingJson,
                'image': imageBytes?.buffer.asUint8List(),
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildColorPalette(),
          _buildStrokeWidthSlider(),
          Expanded(
            child: DrawingBoard(
              controller: _drawingController,
              background: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.white,
              ),
              showDefaultActions: false,
            ),
          ),
        ],
      ),
    );
  }
}
