import 'package:hive/hive.dart';

part 'meal_plan.g.dart';

@HiveType(typeId: 1)
class MealPlan extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  String mealType; // 'Sarapan', 'Makan Siang', 'Makan Malam', 'Snack'

  @HiveField(3)
  String recipeId;

  @HiveField(4)
  String recipeName; // disimpan langsung biar gak perlu join tiap render

  MealPlan({
    required this.id,
    required this.date,
    required this.mealType,
    required this.recipeId,
    required this.recipeName,
  });
}
