// ─────────────────────────────────────────────
// recipe_detail_screen.dart
// ─────────────────────────────────────────────
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../providers/recipe_provider.dart';
import '../providers/meal_plan_provider.dart';
import '../theme/app_theme.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;
  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.categoryColors[recipe.category] ?? AppColors.primary;
    final provider = context.read<RecipeProvider>();
    final groceryProvider = context.read<GroceryProvider>();

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: color,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                icon: Icon(
                  recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: recipe.isFavorite ? AppColors.pink : Colors.white,
                ),
                onPressed: () => provider.toggleFavorite(recipe),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                tooltip: 'Hapus resep',
                onPressed: () => _confirmDelete(context, provider),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _buildDetailImage(recipe, color),
            ),
          ),

          // ── Konten detail resep ──────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(recipe.category,
                            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                      const Spacer(),
                      Icon(Icons.star_rounded, color: AppColors.secondary, size: 16),
                      Text(' ${recipe.rating.toStringAsFixed(1)}',
                          style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(recipe.name,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  const SizedBox(height: 6),
                  Text(recipe.description,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _InfoChip(icon: Icons.timer_outlined, label: '${recipe.cookTimeMinutes} mnt', color: color),
                      const SizedBox(width: 10),
                      _InfoChip(icon: Icons.people_outline, label: '${recipe.servings} porsi', color: color),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Tambah ke daftar belanja
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: color,
                        side: BorderSide(color: color),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        groceryProvider.addFromRecipe(recipe.ingredients, recipe.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Bahan ditambahkan ke Daftar Belanja!'),
                            backgroundColor: color,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      },
                      icon: const Icon(Icons.shopping_cart_outlined),
                      label: const Text('Tambah ke Daftar Belanja'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _SectionTitle(title: 'Bahan-bahan (${recipe.ingredients.length})', color: color),
                  const SizedBox(height: 10),
                  ...recipe.ingredients.asMap().entries.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 28, height: 28,
                              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
                              child: Center(
                                child: Text('${e.key + 1}',
                                    style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(e.value,
                                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 24),
                  _SectionTitle(title: 'Cara Membuat', color: color),
                  const SizedBox(height: 10),
                  ...recipe.steps.asMap().entries.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 28, height: 28,
                              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                              child: Center(
                                child: Text('${e.key + 1}',
                                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(e.value,
                                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, height: 1.5)),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Dialog konfirmasi hapus resep dari halaman detail
  void _confirmDelete(BuildContext context, RecipeProvider provider) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        elevation: 20,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.pink.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.pink, size: 36),
              ),
              const SizedBox(height: 16),
              const Text(
                'Hapus Resep?',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                '"${recipe.name}" akan dihapus permanen dan tidak bisa dikembalikan.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.5),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        side: const BorderSide(color: AppColors.textMuted),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Batal',
                          style: TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.pink,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        final name = recipe.name;
                        Navigator.pop(ctx); // tutup dialog
                        await provider.deleteRecipe(recipe);
                        if (context.mounted) {
                          Navigator.pop(context); // kembali ke list
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(children: [
                                const Icon(Icons.check_circle_outline,
                                    color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text('$name berhasil dihapus',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                ),
                              ]),
                              backgroundColor: AppColors.pink,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      child: const Text('Hapus',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper: render gambar header detail resep lintas platform
  Widget _buildDetailImage(Recipe r, Color color) {
    final placeholder = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.7), color],
        ),
      ),
      child: Center(
        child: Text(
          AppColors.categoryEmojis[r.category] ?? '🍽️',
          style: const TextStyle(fontSize: 80),
        ),
      ),
    );

    if (r.imagePath.isEmpty) return placeholder;

    // Gambar dari asset lokal (folder ASET)
    if (r.imagePath.startsWith('asset:')) {
      final assetPath = r.imagePath.substring(6); // hapus prefix 'asset:'
      return Image.asset(assetPath, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => placeholder);
    }

    // Gambar URL dari internet (resep bawaan lama)
    if (r.imagePath.startsWith('http')) {
      return Image.network(r.imagePath, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => placeholder);
    }

    // Gambar base64 dari upload
    if (r.imagePath.startsWith('data:')) {
      try {
        final b64 = r.imagePath.split(',').last;
        final bytes = base64Decode(b64);
        return Image.memory(bytes, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => placeholder);
      } catch (_) {
        return placeholder;
      }
    }

    // File lokal path (mobile/desktop)
    if (kIsWeb) return placeholder;

    final file = File(r.imagePath);
    return FutureBuilder<bool>(
      future: file.exists(),
      builder: (context, snap) {
        if (snap.data == true) {
          return Image.file(file, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => placeholder);
        }
        return placeholder;
      },
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Color color;
  const _SectionTitle({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 4, height: 20, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ],
    );
  }
}
