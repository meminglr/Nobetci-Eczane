// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sehir_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IllerAdapter extends TypeAdapter<Iller> {
  @override
  final int typeId = 1;

  @override
  Iller read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Iller(
      ilAdi: fields[0] as String?,
      plakaKodu: fields[1] as String?,
      ilceler: (fields[2] as List?)?.cast<Ilceler>(),
      kisaBilgi: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Iller obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.ilAdi)
      ..writeByte(1)
      ..write(obj.plakaKodu)
      ..writeByte(2)
      ..write(obj.ilceler)
      ..writeByte(3)
      ..write(obj.kisaBilgi);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IllerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class IlcelerAdapter extends TypeAdapter<Ilceler> {
  @override
  final int typeId = 2;

  @override
  Ilceler read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Ilceler(
      ilceAdi: fields[0] as String?,
      nufus: fields[1] as String?,
      erkekNufus: fields[2] as String?,
      kadinNufus: fields[3] as String?,
      yuzolcumu: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Ilceler obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.ilceAdi)
      ..writeByte(1)
      ..write(obj.nufus)
      ..writeByte(2)
      ..write(obj.erkekNufus)
      ..writeByte(3)
      ..write(obj.kadinNufus)
      ..writeByte(4)
      ..write(obj.yuzolcumu);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IlcelerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
