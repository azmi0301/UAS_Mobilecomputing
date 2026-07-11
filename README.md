# ResepKu 🍳

Aplikasi resep masakan Indonesia berbasis Flutter dengan tampilan colorful & vibrant.

## Fitur
- 📖 Browse resep dengan kategori (Sarapan, Makan Siang, Makan Malam, Snack, Minuman)
- 🔍 Cari & filter resep berdasarkan kategori
- ❤️ Simpan resep favorit
- 📸 Upload resep sendiri lengkap dengan foto dari galeri
- 📅 Meal Planner — atur menu makan harian dalam seminggu
- 🛒 Daftar Belanja otomatis dari bahan resep


## Tech Stack
- **Flutter** — framework UI
- **Provider** — state management
- **Hive** — local database (offline-first)
- **Image Picker** — upload foto resep dari galeri

## Cara Menjalankan
1. Clone repo ini
   ```
   git clone https://github.com/azmi0301/resepku.git
   ```
2. Masuk ke folder project
   ```
   cd resepku
   ```
3. Install dependencies
   ```
   flutter pub get
   ```
4. Jalankan app
   ```
   flutter run
   ```

## Struktur Project
```
lib/
├── models/         # Model data (Recipe, MealPlan, GroceryItem)
├── providers/      # State management (RecipeProvider, MealPlanProvider, GroceryProvider)
├── screens/        # Halaman app (Home, Detail, Upload, MealPlan, Grocery, dll)
├── widgets/        # Widget reusable (RecipeCard, BottomNav, dll)
├── theme/          # Tema & warna app
└── main.dart       # Entry point
```

## Developer
**Muhammad Azmi Arya Putra**  
Sistem Teknologi Informasi — Universitas Cakrawala  
GitHub: [@azmi0301](https://github.com/azmi0301)
