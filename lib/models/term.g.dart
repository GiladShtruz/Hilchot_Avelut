// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'term.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TermAccessAdapter extends TypeAdapter<TermAccess> {
  @override
  final int typeId = 3;

  @override
  TermAccess read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TermAccess(
      termId: fields[0] as String,
      accessedAt: fields[1] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, TermAccess obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.termId)
      ..writeByte(1)
      ..write(obj.accessedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TermAccessAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
