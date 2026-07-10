// GENERATED CODE - DO NOT MODIFY BY HAND
part of 'meal_plan.dart';

class MealPlanAdapter extends TypeAdapter<MealPlan> {
  @override
  final int typeId = 1;

  @override
  MealPlan read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MealPlan(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      mealType: fields[2] as String,
      recipeId: fields[3] as String,
      recipeName: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MealPlan obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.mealType)
      ..writeByte(3)
      ..write(obj.recipeId)
      ..writeByte(4)
      ..write(obj.recipeName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealPlanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
