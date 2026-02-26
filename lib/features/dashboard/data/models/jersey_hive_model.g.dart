// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jersey_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class JerseyHiveModelAdapter extends TypeAdapter<JerseyHiveModel> {
  @override
  final int typeId = 7;

  @override
  JerseyHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return JerseyHiveModel(
      id: fields[0] as String,
      name: fields[1] as String,
      price: fields[2] as double,
      imageUrl: fields[3] as String?,
      itemType: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, JerseyHiveModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.price)
      ..writeByte(3)
      ..write(obj.imageUrl)
      ..writeByte(4)
      ..write(obj.itemType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JerseyHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
