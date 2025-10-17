// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_check_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveCheckEntryAdapter extends TypeAdapter<HiveCheckEntry> {
  @override
  final int typeId = 1;

  @override
  HiveCheckEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveCheckEntry(
      timestamp: fields[0] as DateTime,
      frames: fields[1] as int?,
      total: fields[2] as int?,
      brood: fields[3] as int?,
      honey: fields[4] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, HiveCheckEntry obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.timestamp)
      ..writeByte(1)
      ..write(obj.frames)
      ..writeByte(2)
      ..write(obj.total)
      ..writeByte(3)
      ..write(obj.brood)
      ..writeByte(4)
      ..write(obj.honey);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveCheckEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
