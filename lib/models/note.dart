import 'dart:convert';

class Note {
  String title;
  String content;
  DateTime creationDate;
  List<String> imagePaths;
  List<String> documentPaths;
  List<Map<String, dynamic>> checklist;
  String themeColor;
  String fontStyle;
  String paragraphStyle;
  DateTime? reminder;
  DateTime? deletionDate;
  final String id;

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
    this.deletionDate,
    String? id,
  }) : id = id ?? DateTime.now().toIso8601String();

  Note copyWith({
    String? title,
    String? content,
    DateTime? creationDate,
    List<String>? imagePaths,
    List<String>? documentPaths,
    List<Map<String, dynamic>>? checklist,
    String? themeColor,
    String? fontStyle,
    String? paragraphStyle,
    DateTime? reminder,
    DateTime? deletionDate,
    String? id,
  }) {
    return Note(
      title: title ?? this.title,
      content: content ?? this.content,
      creationDate: creationDate ?? this.creationDate,
      imagePaths: imagePaths ?? this.imagePaths,
      documentPaths: documentPaths ?? this.documentPaths,
      checklist: checklist ?? this.checklist,
      themeColor: themeColor ?? this.themeColor,
      fontStyle: fontStyle ?? this.fontStyle,
      paragraphStyle: paragraphStyle ?? this.paragraphStyle,
      reminder: reminder ?? this.reminder,
      deletionDate: deletionDate ?? this.deletionDate,
      id: id ?? this.id,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'creationDate': creationDate.toIso8601String(),
      'imagePaths': imagePaths,
      'documentPaths': documentPaths,
      'checklist': checklist,
      'themeColor': themeColor,
      'fontStyle': fontStyle,
      'paragraphStyle': paragraphStyle,
      'reminder': reminder?.toIso8601String(),
      'deletionDate': deletionDate?.toIso8601String(),
      'id': id,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      creationDate: DateTime.parse(map['creationDate']),
      imagePaths: List<String>.from(map['imagePaths'] ?? []),
      documentPaths: List<String>.from(map['documentPaths'] ?? []),
      checklist: List<Map<String, dynamic>>.from(map['checklist'] ?? []),
      themeColor: map['themeColor'] ?? 'default',
      fontStyle: map['fontStyle'] ?? 'default',
      paragraphStyle: map['paragraphStyle'] ?? 'default',
      reminder: map['reminder'] != null ? DateTime.parse(map['reminder']) : null,
      deletionDate: map['deletionDate'] != null ? DateTime.parse(map['deletionDate']) : null,
      id: map['id'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Note.fromJson(String source) => Note.fromMap(json.decode(source));
}
