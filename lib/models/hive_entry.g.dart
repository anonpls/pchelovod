// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveEntryAdapter extends TypeAdapter<HiveEntry> {
  @override
  final int typeId = 0;

  @override
  HiveEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveEntry(
      id: fields[0] as String,
      name: fields[1] as String?,
      description: fields[2] as String?,
      type: fields[3] as String,
      tags: (fields[6] as List).cast<String>(),
      notes: (fields[4] as List).cast<String>(),
      imagePaths: (fields[5] as List).cast<String>(),
      latitude: fields[7] as double?,
      longitude: fields[8] as double?,
      frames: fields[9] as int?,
      total: fields[10] as int?,
      brood: fields[11] as int?,
      honey: fields[12] as int?,
      history: (fields[13] as List).cast<HiveCheckEntry>(),
      breed: fields[14] as String?,
      queenPresent: fields[15] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, HiveEntry obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.notes)
      ..writeByte(5)
      ..write(obj.imagePaths)
      ..writeByte(6)
      ..write(obj.tags)
      ..writeByte(7)
      ..write(obj.latitude)
      ..writeByte(8)
      ..write(obj.longitude)
      ..writeByte(9)
      ..write(obj.frames)
      ..writeByte(10)
      ..write(obj.total)
      ..writeByte(11)
      ..write(obj.brood)
      ..writeByte(12)
      ..write(obj.honey)
      ..writeByte(13)
      ..write(obj.history)
      ..writeByte(14)
      ..write(obj.breed)
      ..writeByte(15)
      ..write(obj.queenPresent);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
