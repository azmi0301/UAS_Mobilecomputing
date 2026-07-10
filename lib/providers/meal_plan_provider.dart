import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/meal_plan.dart';
import '../models/grocery_item.dart';

class MealPlanProvider extends ChangeNotifier {
  final Box<MealPlan> _box = Hive.box<MealPlan>('meal_plans');
  final _uuid = const Uuid();

  List<MealPlan> plansForDate(DateTime date) {
    return _box.values.where((p) =>
        p.date.year == date.year &&
        p.date.month == date.month &&
        p.date.day == date.day).toList()
      ..sort((a, b) => _mealOrder(a.mealType).compareTo(_mealOrder(b.mealType)));
  }

  int _mealOrder(String type) {
    const order = {'Sarapan': 0, 'Makan Siang': 1, 'Snack': 2, 'Makan Malam': 3};
    return order[type] ?? 99;
  }

  Future<void> addPlan({
    required DateTime date,
    required String mealType,
    required String recipeId,
    required String recipeName,
  }) async {
    final plan = MealPlan(
      id: _uuid.v4(),
      date: date,
      mealType: mealType,
      recipeId: recipeId,
      recipeName: recipeName,
    );
    await _box.put(plan.id, plan);
    notifyListeners();
  }

  Future<void> deletePlan(MealPlan plan) async {
    await plan.delete();
    notifyListeners();
  }
}

class GroceryProvider extends ChangeNotifier {
  final Box<GroceryItem> _box = Hive.box<GroceryItem>('groceries');
  final _uuid = const Uuid();

  List<GroceryItem> get items => _box.values.toList()
    ..sort((a, b) => (a.isChecked ? 1 : 0).compareTo(b.isChecked ? 1 : 0));

  int get uncheckedCount => _box.values.where((i) => !i.isChecked).length;

  Future<void> addItem(String name, {String sourceRecipeId = ''}) async {
    final item = GroceryItem(
      id: _uuid.v4(),
      name: name,
      sourceRecipeId: sourceRecipeId,
    );
    await _box.put(item.id, item);
    notifyListeners();
  }

  /// Tambah semua bahan dari resep ke grocery list (skip duplikat nama).
  Future<void> addFromRecipe(List<String> ingredients, String recipeId) async {
    final existingNames = _box.values.map((i) => i.name.toLowerCase()).toSet();
    for (final ing in ingredients) {
      if (!existingNames.contains(ing.toLowerCase())) {
        await addItem(ing, sourceRecipeId: recipeId);
      }
    }
    notifyListeners();
  }

  Future<void> toggleItem(GroceryItem item) async {
    item.isChecked = !item.isChecked;
    await item.save();
    notifyListeners();
  }

  Future<void> deleteItem(GroceryItem item) async {
    await item.delete();
    notifyListeners();
  }

  Future<void> clearChecked() async {
    final checked = _box.values.where((i) => i.isChecked).toList();
    for (final i in checked) {
      await i.delete();
    }
    notifyListeners();
  }
}
