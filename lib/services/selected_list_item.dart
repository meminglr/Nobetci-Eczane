import 'package:hive/hive.dart';

part 'selected_list_item.g.dart'; // Adapter dosyası için

@HiveType(typeId: 0)
class SelectedListItem extends HiveObject {
  @HiveField(0)
  String value;

  @HiveField(1)
  bool isSelected;

  SelectedListItem(this.value, this.isSelected);
}
