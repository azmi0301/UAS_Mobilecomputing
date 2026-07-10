import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';

// ─── Search Screen ───────────────────────────
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecipeProvider>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Cari Resep',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            const SizedBox(height: 14),
            TextField(
              controller: _ctrl,
              autofocus: false,
              onChanged: provider.setSearch,
              decoration: InputDecoration(
                hintText: 'Ketik nama resep...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                suffixIcon: _ctrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, color: AppColors.textMuted, size: 18),
                        onPressed: () {
                          _ctrl.clear();
                          provider.setSearch('');
                        },
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 14),
            // Filter kategori
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: RecipeProvider.categories.map((cat) {
                  final isSelected = provider.selectedCategory == cat;
                  final color = AppColors.categoryColors[cat] ?? AppColors.primary;
                  return GestureDetector(
                    onTap: () => provider.setCategory(cat),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? (cat == 'Semua' ? AppColors.primary : color) : AppColors.bgSecondary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        cat == 'Semua' ? 'Semua' : '${AppColors.categoryEmojis[cat]} $cat',
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: provider.recipes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🔍', style: TextStyle(fontSize: 50)),
                          const SizedBox(height: 10),
                          Text('Resep tidak ditemukan',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                        ],
                      ),
                    )
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: 0.72),
                      itemCount: provider.recipes.length,
                      itemBuilder: (context, i) {
                        final r = provider.recipes[i];
                        return RecipeCard(
                          recipe: r,
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: r))),
                          onFavoriteTap: () => provider.toggleFavorite(r),
                          onDeleteTap: () {
                            provider.deleteRecipe(r);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(children: [
                                  const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text('${r.name} berhasil dihapus',
                                      style: const TextStyle(fontWeight: FontWeight.w600))),
                                ]),
                                backgroundColor: AppColors.pink,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                duration: const Duration(seconds: 2),
                              ),
                            );
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

// ─── Favorite Screen ─────────────────────────
class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<RecipeProvider>().favorites;
    final provider = context.read<RecipeProvider>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Favorit ❤️',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text('${favorites.length} resep tersimpan',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 16),
            Expanded(
              child: favorites.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('💔', style: TextStyle(fontSize: 60)),
                          const SizedBox(height: 12),
                          const Text('Belum ada resep favorit',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                          const SizedBox(height: 4),
                          const Text('Tap ikon ❤️ di resep untuk menyimpan',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                        ],
                      ),
                    )
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: 0.72),
                      itemCount: favorites.length,
                      itemBuilder: (context, i) => RecipeCard(
                        recipe: favorites[i],
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: favorites[i]))),
                        onFavoriteTap: () => provider.toggleFavorite(favorites[i]),
                        onDeleteTap: () {
                          final name = favorites[i].name;
                          provider.deleteRecipe(favorites[i]);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(children: [
                                const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Expanded(child: Text('$name berhasil dihapus',
                                    style: const TextStyle(fontWeight: FontWeight.w600))),
                              ]),
                              backgroundColor: AppColors.pink,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
