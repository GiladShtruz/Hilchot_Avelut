// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_position.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReadingPositionAdapter extends TypeAdapter<ReadingPosition> {
  @override
  final int typeId = 1;

  @override
  ReadingPosition read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReadingPosition(
      chapterId: fields[0] as String,
      scrollPosition: fields[1] as double,
      updatedAt: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ReadingPosition obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.chapterId)
      ..writeByte(1)
      ..write(obj.scrollPosition)
      ..writeByte(2)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReadingPositionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
