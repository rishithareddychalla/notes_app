// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NoteAdapter extends TypeAdapter<Note> {
  @override
  final int typeId = 0;

  @override
  Note read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Note(
      title: fields[0] as String,
      content: fields[1] as String,
      creationDate: fields[2] as DateTime,
      imagePaths: (fields[3] as List).cast<String>(),
      documentPaths: (fields[4] as List).cast<String>(),
      checklist: (fields[5] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
      themeColor: fields[6] as String,
      fontStyle: fields[7] as String,
      paragraphStyle: fields[8] as String,
      reminder: fields[9] as DateTime?,
      deletionDate: fields[10] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Note obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.creationDate)
      ..writeByte(3)
      ..write(obj.imagePaths)
      ..writeByte(4)
      ..write(obj.documentPaths)
      ..writeByte(5)
      ..write(obj.checklist)
      ..writeByte(6)
      ..write(obj.themeColor)
      ..writeByte(7)
      ..write(obj.fontStyle)
      ..writeByte(8)
      ..write(obj.paragraphStyle)
      ..writeByte(9)
      ..write(obj.reminder)
      ..writeByte(10)
      ..write(obj.deletionDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
