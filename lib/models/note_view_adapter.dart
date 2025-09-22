import 'package:hive/hive.dart';
import 'package:notes_app/providers/settings_provider.dart';

class NoteViewAdapter extends TypeAdapter<NoteView> {
  @override
  final int typeId = 1;

  @override
  NoteView read(BinaryReader reader) {
    return NoteView.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, NoteView obj) {
    writer.writeByte(obj.index);
  }
}
