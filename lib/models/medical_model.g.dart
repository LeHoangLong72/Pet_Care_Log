// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medical_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MedicalModelAdapter extends TypeAdapter<MedicalModel> {
  @override
  final int typeId = 2;

  @override
  MedicalModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MedicalModel(
      id: fields[0] as String,
      petId: fields[1] as String,
      type: fields[2] as String,
      dateAdministered: fields[3] as DateTime,
      nextDueDate: fields[4] as DateTime,
      isCompleted: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, MedicalModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.petId)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.dateAdministered)
      ..writeByte(4)
      ..write(obj.nextDueDate)
      ..writeByte(5)
      ..write(obj.isCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicalModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
