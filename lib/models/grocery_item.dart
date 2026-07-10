import 'package:hive/hive.dart';

part 'grocery_item.g.dart';

@HiveType(typeId: 2)
class GroceryItem extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  bool isChecked;

  @HiveField(3)
  String sourceRecipeId; // dari resep mana item ini berasal (kosong = manual)

  GroceryItem({
    required this.id,
    required this.name,
    this.isChecked = false,
    this.sourceRecipeId = '',
  });
}
