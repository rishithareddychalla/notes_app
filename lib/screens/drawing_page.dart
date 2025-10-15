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

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor =
        theme.brightness == Brightness.dark ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Drawing'),
        actions: [
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
      body: DrawingBoard(
        controller: _drawingController,
        background: Container(
          width: 400,
          height: 400,
          color: Colors.white,
        ),
        showDefaultActions: true,
        showDefaultTools: true,
        actionColor: iconColor,
        toolbarColor: iconColor,
      ),
    );
  }
}
