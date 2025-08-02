// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selected_list_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SelectedListItemAdapter extends TypeAdapter<SelectedListItem> {
  @override
  final int typeId = 0;

  @override
  SelectedListItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SelectedListItem(
      fields[0] as String,
      fields[1] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SelectedListItem obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.value)
      ..writeByte(1)
      ..write(obj.isSelected);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SelectedListItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
