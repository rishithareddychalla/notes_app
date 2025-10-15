// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:flutter_drawing_board/flutter_drawing_board.dart';
// import 'package:flutter_drawing_board/paint_contents.dart';

// class DrawingPage extends StatefulWidget {
//   final String? drawingData;

//   const DrawingPage({super.key, this.drawingData});

//   @override
//   _DrawingPageState createState() => _DrawingPageState();
// }

// class _DrawingPageState extends State<DrawingPage> {
//   final DrawingController _drawingController = DrawingController();

//   @override
//   void initState() {
//     super.initState();
//     if (widget.drawingData != null && widget.drawingData!.isNotEmpty) {
//       final List<dynamic> history = jsonDecode(widget.drawingData!);
//       final List<PaintContent> contents = history
//           .map((item) => _getPaintContentFromJson(item as Map<String, dynamic>))
//           .toList();
//       _drawingController.addContents(contents);
//     }
//   }

//   @override
//   void dispose() {
//     _drawingController.dispose();
//     super.dispose();
//   }

//   PaintContent _getPaintContentFromJson(Map<String, dynamic> json) {
//     final String type = json['type'] as String;
//     switch (type) {
//       case 'SimpleLine':
//         return SimpleLine.fromJson(json);
//       case 'SmoothLine':
//         return SmoothLine.fromJson(json);
//       case 'StraightLine':
//         return StraightLine.fromJson(json);
//       case 'Rectangle':
//         return Rectangle.fromJson(json);
//       case 'Circle':
//         return Circle.fromJson(json);
//       case 'Eraser':
//         return Eraser.fromJson(json);
//       default:
//         throw Exception('Unknown PaintContent type: $type');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final iconColor =
//         theme.brightness == Brightness.dark ? Colors.white : Colors.black;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Drawing'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.check),
//             onPressed: () async {
//               final drawingJson = jsonEncode(_drawingController.getJsonList());
//               final imageBytes = await _drawingController.getImageData();
//               Navigator.pop(context, {
//                 'json': drawingJson,
//                 'image': imageBytes?.buffer.asUint8List(),
//               });
//             },
//           ),
//         ],
//       ),
//       body: DrawingBoard(
//         controller: _drawingController,
//         background: Container(
//           width: 400,
//           height: 400,
//           color: Colors.white,
//         ),
//         showDefaultActions: true,
//         showDefaultTools: true,
//         actionColor: iconColor,
//         toolbarColor: iconColor,
//       ),
//     );
//   }
// }
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
      body: Stack(
        children: [
          DrawingBoard(
            controller: _drawingController,
            background: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.white,
            ),
            showDefaultActions: false, // disable default toolbar
            showDefaultTools: false,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.grey[200], // toolbar background
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.brush),
                      color: Colors.black,
                      onPressed: () {
                        _drawingController.setTool(SimpleLine()
                          ..color = Colors.black
                          ..strokeWidth = 3);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.create),
                      color: Colors.black,
                      onPressed: () {
                        _drawingController.setTool(SmoothLine()
                          ..color = Colors.black
                          ..strokeWidth = 3);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.crop_square),
                      color: Colors.black,
                      onPressed: () {
                        _drawingController.setTool(Rectangle()
                          ..color = Colors.blue
                          ..strokeWidth = 3);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.circle),
                      color: Colors.black,
                      onPressed: () {
                        _drawingController.setTool(Circle()
                          ..color = Colors.red
                          ..strokeWidth = 3);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.cleaning_services),
                      color: Colors.black,
                      onPressed: () {
                        _drawingController.setTool(Eraser()..strokeWidth = 10);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.undo),
                      color: Colors.black,
                      onPressed: () {
                        _drawingController.undo();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.redo),
                      color: Colors.black,
                      onPressed: () {
                        _drawingController.redo();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear),
                      color: Colors.black,
                      onPressed: () {
                        _drawingController.clear();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
