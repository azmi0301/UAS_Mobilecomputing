import 'package:flutter/material.dart';

class AppColors {
  // Primary - Orange hangat (warna makanan)
  static const primary = Color(0xFFFF6B35);
  static const primaryLight = Color(0xFFFF8C5A);
  static const primaryDark = Color(0xFFE55A2B);

  // Secondary - Kuning segar
  static const secondary = Color(0xFFFFBE0B);

  // Aksen
  static const green = Color(0xFF06D6A0);
  static const pink = Color(0xFFEF476F);
  static const purple = Color(0xFF8338EC);
  static const blue = Color(0xFF118AB2);

  // Background
  static const bgPrimary = Color(0xFFFFFBF7); // putih hangat
  static const bgSecondary = Color(0xFFF5EDE3); // krem lembut
  static const bgCard = Colors.white;

  // Teks
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF6B6B80);
  static const textMuted = Color(0xFFAAAAAA);

  // Gradient
  static const headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );

  // Warna per kategori
  static const categoryColors = {
    'Sarapan': Color(0xFFFFBE0B),
    'Makan Siang': Color(0xFFFF6B35),
    'Makan Malam': Color(0xFF8338EC),
    'Snack': Color(0xFF06D6A0),
    'Minuman': Color(0xFF118AB2),
  };

  // Emoji per kategori
  static const categoryEmojis = {
    'Sarapan': '🌅',
    'Makan Siang': '🍽️',
    'Makan Malam': '🌙',
    'Snack': '🍿',
    'Minuman': '🥤',
  };
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppColors.bgPrimary,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.textPrimary),
      titleTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.bgCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.grey.withOpacity(0.08), width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.3),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.pink, width: 1),
      ),
      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
    ),
  );
}
