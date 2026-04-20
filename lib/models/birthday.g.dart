// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'birthday.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BirthdayAdapter extends TypeAdapter<Birthday> {
  @override
  final int typeId = 1;

  @override
  Birthday read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Birthday(
      id: fields[0] as String,
      name: fields[1] as String,
      date: fields[2] as DateTime,
      relationship: fields[3] as String,
      includeYear: fields[4] == null ? false : fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Birthday obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.relationship)
      ..writeByte(4)
      ..write(obj.includeYear);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BirthdayAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
