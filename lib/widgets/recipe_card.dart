import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../theme/app_theme.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onDeleteTap;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
    this.onFavoriteTap,
    this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.categoryColors[recipe.category] ?? AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onDeleteTap != null ? () => _showDeleteDialog(context) : null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 14,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Gambar + badge overlay ──────────────────────
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: SizedBox(
                    height: 130,
                    width: double.infinity,
                    child: _buildImage(color),
                  ),
                ),
                // Rating badge – pojok kiri atas
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 11, color: Color(0xFFFFD700)),
                        const SizedBox(width: 3),
                        Text(
                          recipe.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Tombol favorit – pojok kanan atas
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: onFavoriteTap,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Icon(
                        recipe.isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: recipe.isFavorite
                            ? AppColors.pink
                            : AppColors.textMuted,
                        size: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ── Teks konten ────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    recipe.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.timer_outlined, size: 11, color: color),
                      const SizedBox(width: 3),
                      Text(
                        '${recipe.cookTimeMinutes} mnt',
                        style: TextStyle(
                            fontSize: 10,
                            color: color,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.people_outline,
                          size: 11, color: AppColors.textMuted),
                      const SizedBox(width: 3),
                      Text(
                        '${recipe.servings} porsi',
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      recipe.category,
                      style: TextStyle(
                          fontSize: 10,
                          color: color,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 20,
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon hapus
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
                'Resep "${recipe.name}" akan dihapus permanen dan tidak bisa dikembalikan.',
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
                      onPressed: () {
                        Navigator.pop(ctx);
                        onDeleteTap?.call();
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

  Widget _buildImage(Color color) {
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
          AppColors.categoryEmojis[recipe.category] ?? '🍽️',
          style: const TextStyle(fontSize: 48),
        ),
      ),
    );

    if (recipe.imagePath.isEmpty) return placeholder;

    // Gambar dari asset lokal (folder ASET)
    if (recipe.imagePath.startsWith('asset:')) {
      final assetPath = recipe.imagePath.substring(6); // hapus prefix 'asset:'
      return Image.asset(
        assetPath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
      );
    }

    // Gambar URL dari internet (resep bawaan lama)
    if (recipe.imagePath.startsWith('http')) {
      return Image.network(
        recipe.imagePath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
      );
    }

    // Gambar base64 dari upload (lintas platform: web + mobile)
    if (recipe.imagePath.startsWith('data:')) {
      try {
        final base64Str = recipe.imagePath.split(',').last;
        final bytes = base64Decode(base64Str);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => placeholder,
        );
      } catch (_) {
        return placeholder;
      }
    }

    // File lokal path (mobile/desktop) — cek keberadaan file dulu
    if (kIsWeb) return placeholder;

    final file = File(recipe.imagePath);
    return FutureBuilder<bool>(
      future: file.exists(),
      builder: (context, snap) {
        if (snap.data == true) {
          return Image.file(
            file,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => placeholder,
          );
        }
        return placeholder;
      },
    );
  }
}
