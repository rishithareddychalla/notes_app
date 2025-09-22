import 'package:hive/hive.dart';

part 'note.g.dart';

@HiveType(typeId: 0)
class Note extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String content;

  @HiveField(2)
  DateTime creationDate;

  @HiveField(3)
  List<String> imagePaths;

  @HiveField(4)
  List<String> documentPaths;

  @HiveField(5)
  List<Map<String, dynamic>> checklist;

  @HiveField(6)
  String themeColor;

  @HiveField(7)
  String fontStyle;

  @HiveField(8)
  String paragraphStyle;

  @HiveField(9)
  DateTime? reminder;

  Note({
    required this.title,
    required this.content,
    required this.creationDate,
    this.imagePaths = const [],
    this.documentPaths = const [],
    this.checklist = const [],
    this.themeColor = 'default',
    this.fontStyle = 'default',
    this.paragraphStyle = 'default',
    this.reminder,
  });
}
