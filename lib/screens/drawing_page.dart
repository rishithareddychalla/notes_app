import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:path_provider/path_provider.dart';

class DrawingPage extends StatefulWidget {
  const DrawingPage({super.key});

  @override
  _DrawingPageState createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  final DrawingController _drawingController = DrawingController();

  @override
  void dispose() {
    _drawingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drawing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () async {
              final image = await _drawingController.getImageData();
              if (image == null) return;
              final directory = await getTemporaryDirectory();
              final path =
                  '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.png';
              final file = File(path);
              await file.writeAsBytes(image.buffer.asUint8List());
              Navigator.pop(context, path);
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
      ),
    );
  }
}