// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_log_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyLogModelAdapter extends TypeAdapter<DailyLogModel> {
  @override
  final int typeId = 1;

  @override
  DailyLogModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyLogModel(
      id: fields[0] as String,
      petId: fields[1] as String,
      dateTime: fields[2] as DateTime,
      logType: fields[3] as String,
      title: fields[4] as String,
      note: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DailyLogModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.petId)
      ..writeByte(2)
      ..write(obj.dateTime)
      ..writeByte(3)
      ..write(obj.logType)
      ..writeByte(4)
      ..write(obj.title)
      ..writeByte(5)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyLogModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
