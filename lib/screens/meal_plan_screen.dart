import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meal_plan_provider.dart';
import '../providers/recipe_provider.dart';
import '../theme/app_theme.dart';

// ─── Meal Plan Screen ─────────────────────────
class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  DateTime _selectedDate = DateTime.now();
  static const _mealTypes = ['Sarapan', 'Makan Siang', 'Snack', 'Makan Malam'];
  static const _weekdays = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  List<DateTime> _weekDates() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final mealProvider = context.watch<MealPlanProvider>();
    final plansToday = mealProvider.plansForDate(_selectedDate);
    final weekDates = _weekDates();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Meal Planner 📅',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            // Week selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: weekDates.asMap().entries.map((e) {
                final date = e.value;
                final isSelected = _isSameDay(date, _selectedDate);
                final isToday = _isSameDay(date, DateTime.now());
                return GestureDetector(
                  onTap: () => setState(() => _selectedDate = date),
                  child: Container(
                    width: 40,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : (isToday ? AppColors.primary.withOpacity(0.1) : Colors.transparent),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(_weekdays[e.key],
                            style: TextStyle(
                                fontSize: 11,
                                color: isSelected ? Colors.white : AppColors.textMuted,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text('${date.day}',
                            style: TextStyle(
                                fontSize: 15,
                                color: isSelected ? Colors.white : AppColors.textPrimary,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: _mealTypes.map((mealType) {
                  final plan = plansToday.where((p) => p.mealType == mealType).toList();
                  final color = AppColors.categoryColors[mealType] ?? AppColors.primary;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: color.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(AppColors.categoryEmojis[mealType] ?? '🍽️', style: const TextStyle(fontSize: 18)),
                                const SizedBox(width: 8),
                                Text(mealType,
                                    style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 14)),
                              ],
                            ),
                            GestureDetector(
                              onTap: () => _showAddPlanSheet(context, mealType),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                child: Icon(Icons.add, color: color, size: 18),
                              ),
                            ),
                          ],
                        ),
                        if (plan.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          ...plan.map((p) => Row(
                                children: [
                                  Expanded(
                                    child: Text(p.recipeName,
                                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                                  ),
                                  GestureDetector(
                                    onTap: () => context.read<MealPlanProvider>().deletePlan(p),
                                    child: const Icon(Icons.close, size: 16, color: AppColors.textMuted),
                                  ),
                                ],
                              )),
                        ] else
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text('Belum ada rencana',
                                style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPlanSheet(BuildContext context, String mealType) {
    final recipes = context.read<RecipeProvider>().allRecipes;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pilih resep untuk $mealType',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 14),
            SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: recipes.length,
                itemBuilder: (_, i) {
                  final r = recipes[i];
                  final color = AppColors.categoryColors[r.category] ?? AppColors.primary;
                  return ListTile(
                    leading: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: Center(child: Text(AppColors.categoryEmojis[r.category] ?? '🍽️', style: const TextStyle(fontSize: 20))),
                    ),
                    title: Text(r.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: Text(r.category, style: TextStyle(fontSize: 12, color: color)),
                    onTap: () {
                      context.read<MealPlanProvider>().addPlan(
                            date: _selectedDate,
                            mealType: mealType,
                            recipeId: r.id,
                            recipeName: r.name,
                          );
                      Navigator.pop(ctx);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Grocery Screen ───────────────────────────
class GroceryScreen extends StatelessWidget {
  const GroceryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GroceryProvider>();
    final items = provider.items;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Daftar Belanja 🛒',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                if (items.any((i) => i.isChecked))
                  TextButton(
                    onPressed: provider.clearChecked,
                    child: const Text('Hapus centang', style: TextStyle(color: AppColors.pink, fontSize: 12)),
                  ),
              ],
            ),
            Text('${provider.uncheckedCount} item belum dibeli',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 16),
            // Add manual item
            Row(
              children: [
                Expanded(
                  child: _AddItemField(onAdd: (name) => provider.addItem(name)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🛒', style: TextStyle(fontSize: 60)),
                          const SizedBox(height: 12),
                          const Text('Daftar belanja kosong',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                          const SizedBox(height: 4),
                          const Text('Tambah dari detail resep atau tulis manual',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final item = items[i];
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: item.isChecked ? AppColors.bgSecondary : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => provider.toggleItem(item),
                                child: Container(
                                  width: 24, height: 24,
                                  decoration: BoxDecoration(
                                    color: item.isChecked ? AppColors.green : Colors.transparent,
                                    border: Border.all(
                                        color: item.isChecked ? AppColors.green : AppColors.textMuted),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: item.isChecked
                                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: TextStyle(
                                    color: item.isChecked ? AppColors.textMuted : AppColors.textPrimary,
                                    decoration: item.isChecked ? TextDecoration.lineThrough : null,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => provider.deleteItem(item),
                                child: const Icon(Icons.delete_outline, color: AppColors.textMuted, size: 18),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddItemField extends StatefulWidget {
  final Function(String) onAdd;
  const _AddItemField({required this.onAdd});

  @override
  State<_AddItemField> createState() => _AddItemFieldState();
}

class _AddItemFieldState extends State<_AddItemField> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _ctrl,
            decoration: const InputDecoration(
              hintText: 'Tambah item belanja...',
              prefixIcon: Icon(Icons.add_shopping_cart, color: AppColors.primary, size: 20),
            ),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: () {
            if (_ctrl.text.trim().isNotEmpty) {
              widget.onAdd(_ctrl.text.trim());
              _ctrl.clear();
            }
          },
          child: const Text('+ Tambah', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}
