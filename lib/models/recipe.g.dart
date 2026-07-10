// GENERATED CODE - DO NOT MODIFY BY HAND
part of 'recipe.dart';

class RecipeAdapter extends TypeAdapter<Recipe> {
  @override
  final int typeId = 0;

  @override
  Recipe read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Recipe(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      category: fields[3] as String,
      ingredients: (fields[4] as List).cast<String>(),
      steps: (fields[5] as List).cast<String>(),
      cookTimeMinutes: fields[6] as int,
      servings: fields[7] as int,
      isFavorite: fields[8] as bool,
      imagePath: fields[9] as String,
      createdAt: fields[10] as DateTime,
      isUserCreated: fields[11] as bool,
      rating: fields[12] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Recipe obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.ingredients)
      ..writeByte(5)
      ..write(obj.steps)
      ..writeByte(6)
      ..write(obj.cookTimeMinutes)
      ..writeByte(7)
      ..write(obj.servings)
      ..writeByte(8)
      ..write(obj.isFavorite)
      ..writeByte(9)
      ..write(obj.imagePath)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.isUserCreated)
      ..writeByte(12)
      ..write(obj.rating);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
