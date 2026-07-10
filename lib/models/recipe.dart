import 'package:hive/hive.dart';

part 'recipe.g.dart';

@HiveType(typeId: 0)
class Recipe extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  String category; // 'Sarapan', 'Makan Siang', 'Makan Malam', 'Snack', 'Minuman'

  @HiveField(4)
  List<String> ingredients; // "2 sdm gula", "1 butir telur", dst

  @HiveField(5)
  List<String> steps;

  @HiveField(6)
  int cookTimeMinutes;

  @HiveField(7)
  int servings;

  @HiveField(8)
  bool isFavorite;

  @HiveField(9)
  String imagePath; // path lokal foto (kosong = pakai placeholder)

  @HiveField(10)
  DateTime createdAt;

  @HiveField(11)
  bool isUserCreated; // false = resep bawaan/seed, true = upload sendiri

  @HiveField(12)
  double rating;

  Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.ingredients,
    required this.steps,
    required this.cookTimeMinutes,
    required this.servings,
    this.isFavorite = false,
    this.imagePath = '',
    DateTime? createdAt,
    this.isUserCreated = false,
    this.rating = 0.0,
  }) : createdAt = createdAt ?? DateTime.now();
}
