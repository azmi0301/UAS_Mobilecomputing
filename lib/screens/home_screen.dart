import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/recipe_card.dart';
import '../widgets/bottom_nav.dart';
import 'search_screen.dart';
import 'recipe_detail_screen.dart';
import 'upload_recipe_screen.dart';
import 'favorite_screen.dart';
import 'meal_plan_screen.dart';
import 'grocery_screen.dart';
import 'login_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHome(context),
      const SearchScreen(),
      const FavoriteScreen(),
      const MealPlanScreen(),
      const GroceryScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: pages[_navIndex],
      bottomNavigationBar: AppBottomNav(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),
      floatingActionButton: _navIndex == 0
          ? FloatingActionButton(
              backgroundColor: AppColors.primary,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UploadRecipeScreen()),
              ),
              child: const Icon(Icons.add_rounded, color: Colors.white),
            )
          : null,
    );
  }

  void _showProfileDialog(BuildContext context, AuthProvider authProvider) {
    final user = authProvider.currentUser;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 10,
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  user != null && user['name'].toString().isNotEmpty
                      ? user['name'].toString().substring(0, 1).toUpperCase()
                      : 'T',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user?['name'] ?? 'Pengguna Tamu',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                user?['email'] ?? 'tamu@resepku.com',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              const Divider(color: AppColors.bgSecondary),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: AppColors.textMuted),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Tutup',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.pink,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        authProvider.logout();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      },
                      child: const Text(
                        'Keluar',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHome(BuildContext context) {
    final provider = context.watch<RecipeProvider>();
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;
    final recipes = provider.recipes;

    return CustomScrollView(
      slivers: [
        // Header gradient
        SliverToBoxAdapter(
          child: Container(
            decoration: const BoxDecoration(
              gradient: AppColors.headerGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).padding.top + 20, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Halo, ${currentUser?['name'] ?? 'Tamu'}! 👋',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 2),
                        const Text('Mau masak apa hari ini?',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800)),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => _showProfileDialog(context, authProvider),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Text('🍳', style: TextStyle(fontSize: 22)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Search bar (tap untuk ke SearchScreen)
                GestureDetector(
                  onTap: () => setState(() => _navIndex = 1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search_rounded,
                            color: AppColors.textMuted, size: 20),
                        SizedBox(width: 10),
                        Text('Cari resep...',
                            style: TextStyle(
                                color: AppColors.textMuted, fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Kategori
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text('Kategori',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 90,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: RecipeProvider.categories
                  .where((c) => c != 'Semua')
                  .map((cat) {
                final color =
                    AppColors.categoryColors[cat] ?? AppColors.primary;
                final isSelected =
                    provider.selectedCategory == cat;
                return GestureDetector(
                  onTap: () => provider.setCategory(
                      isSelected ? 'Semua' : cat),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? color : color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppColors.categoryEmojis[cat] ?? '🍽️',
                          style: const TextStyle(fontSize: 26),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cat,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : color,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // Resep
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              provider.selectedCategory == 'Semua'
                  ? 'Semua Resep (${recipes.length})'
                  : provider.selectedCategory,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary),
            ),
          ),
        ),

        recipes.isEmpty
            ? const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Text('🍽️', style: TextStyle(fontSize: 60)),
                        SizedBox(height: 12),
                        Text('Belum ada resep di kategori ini',
                            style: TextStyle(
                                color: AppColors.textMuted, fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              )
            : SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => RecipeCard(
                      recipe: recipes[i],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                RecipeDetailScreen(recipe: recipes[i])),
                      ),
                      onFavoriteTap: () =>
                          provider.toggleFavorite(recipes[i]),
                      onDeleteTap: () {
                        provider.deleteRecipe(recipes[i]);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle_outline,
                                    color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${recipes[i].name} berhasil dihapus',
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: AppColors.pink,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    childCount: recipes.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    mainAxisExtent: 230,
                  ),
                ),
              ),
      ],
    );
  }
}
