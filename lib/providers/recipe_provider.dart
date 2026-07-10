import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/recipe.dart';

class RecipeProvider extends ChangeNotifier {
  final Box<Recipe> _box = Hive.box<Recipe>('recipes');
  final _uuid = const Uuid();

  String _search = '';
  String _selectedCategory = 'Semua';

  String get search => _search;
  String get selectedCategory => _selectedCategory;

  static const categories = ['Semua', 'Sarapan', 'Makan Siang', 'Makan Malam', 'Snack', 'Minuman'];

  List<Recipe> get recipes {
    var list = _box.values.toList();
    if (_selectedCategory != 'Semua') {
      list = list.where((r) => r.category == _selectedCategory).toList();
    }
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      list = list.where((r) =>
          r.name.toLowerCase().contains(q) ||
          r.description.toLowerCase().contains(q)).toList();
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  List<Recipe> get favorites => _box.values.where((r) => r.isFavorite).toList();
  List<Recipe> get allRecipes => _box.values.toList();

  Recipe? getById(String id) {
    try {
      return _box.values.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> toggleFavorite(Recipe recipe) async {
    recipe.isFavorite = !recipe.isFavorite;
    await recipe.save();
    notifyListeners();
  }

  Future<Recipe> addRecipe({
    required String name,
    required String description,
    required String category,
    required List<String> ingredients,
    required List<String> steps,
    required int cookTimeMinutes,
    required int servings,
    String imagePath = '',
    bool isUserCreated = true,
    double rating = 0.0,
  }) async {
    final recipe = Recipe(
      id: _uuid.v4(),
      name: name,
      description: description,
      category: category,
      ingredients: ingredients,
      steps: steps,
      cookTimeMinutes: cookTimeMinutes,
      servings: servings,
      imagePath: imagePath,
      isUserCreated: isUserCreated,
      rating: rating,
    );
    await _box.put(recipe.id, recipe);
    notifyListeners();
    return recipe;
  }

  Future<void> updateRecipe(Recipe recipe) async {
    await recipe.save();
    notifyListeners();
  }

  Future<void> deleteRecipe(Recipe recipe) async {
    await recipe.delete();
    notifyListeners();
  }

  /// Seed resep Indonesia bawaan — dipanggil sekali di init kalau box kosong.
  String _getDefaultImageUrl(String name) {
    final urls = {
      'Nasi Goreng Spesial': 'asset:ASET/Nasi Goreng Special.jpg',
      'Soto Ayam Lamongan': 'asset:ASET/Soto ayam lamongan.jpg',
      'Rendang Daging': 'asset:ASET/Rendang daging.jpg',
      'Pisang Goreng Crispy': 'asset:ASET/pisang goreng crispy.jpg',
      'Es Teh Tarik': 'asset:ASET/Es Teh Tarik.jpg',
      'Gado-Gado Jakarta': 'asset:ASET/gado gado Jakarta.jpg',
      'Bakso Sapi Kuah': 'asset:ASET/Bakso Sapi Kuah.jpg',
      'Sate Ayam Madura': 'asset:ASET/Sate ayam Madura.jpg',
      'Martabak Manis': 'asset:ASET/martabak manis.jpg',
      'Es Cendol Durian': 'asset:ASET/Es Cendol Durian.jpg',
      'Bubur Ayam Kuning': 'asset:ASET/Bubur Ayam Kuning.jpg',
    };
    return urls[name] ?? '';
  }

  /// Seed resep Indonesia bawaan — dipanggil sekali di init kalau box kosong.
  Future<void> seedDefaultsIfEmpty() async {
    final seeds = [
      Recipe(
        id: _uuid.v4(),
        name: 'Nasi Goreng Spesial',
        description: 'Nasi goreng gurih dengan telur, ayam, dan sayuran segar — sarapan favorit keluarga Indonesia.',
        category: 'Sarapan',
        ingredients: ['2 piring nasi putih', '2 butir telur', '100g dada ayam potong dadu', '3 siung bawang putih', '2 siung bawang merah', '2 sdm kecap manis', '1 sdm saus tiram', 'Garam & merica secukupnya', '2 sdm minyak goreng', 'Daun bawang secukupnya'],
        steps: ['Panaskan minyak, tumis bawang putih dan bawang merah hingga harum.', 'Masukkan ayam, masak hingga matang.', 'Tambahkan telur, orak-arik.', 'Masukkan nasi, aduk rata.', 'Tambahkan kecap manis, saus tiram, garam, merica.', 'Aduk rata, masak 2-3 menit. Taburi daun bawang.'],
        cookTimeMinutes: 15,
        servings: 2,
        rating: 4.8,
        isUserCreated: false,
        imagePath: 'asset:ASET/Nasi Goreng Special.jpg',
      ),
      Recipe(
        id: _uuid.v4(),
        name: 'Soto Ayam Lamongan',
        description: 'Soto ayam bening khas Lamongan dengan kuah kuning segar dan taburan koya gurih.',
        category: 'Makan Siang',
        ingredients: ['1 ekor ayam kampung', '2 batang serai', '3 lembar daun salam', '4 lembar daun jeruk', '3 cm lengkuas', '5 siung bawang putih', '4 siung bawang merah', '2 cm kunyit', '1 sdt ketumbar', 'Garam secukupnya', 'Bihun, tauge, telur rebus untuk pelengkap', 'Koya (kerupuk udang halus + bawang putih goreng)'],
        steps: ['Rebus ayam dengan serai, salam, daun jeruk, lengkuas hingga empuk.', 'Haluskan bumbu: bawang putih, bawang merah, kunyit, ketumbar.', 'Tumis bumbu halus hingga harum, masukkan ke rebusan ayam.', 'Bumbui dengan garam, masak 15 menit lagi.', 'Suwir ayam. Sajikan dengan bihun, tauge, telur, dan koya.'],
        cookTimeMinutes: 60,
        servings: 4,
        rating: 4.9,
        isUserCreated: false,
        imagePath: 'asset:ASET/Soto ayam lamongan.jpg',
      ),
      Recipe(
        id: _uuid.v4(),
        name: 'Rendang Daging',
        description: 'Rendang daging sapi empuk bercita rasa kaya rempah — masakan Minang yang mendunia.',
        category: 'Makan Malam',
        ingredients: ['500g daging sapi', '400ml santan kental', '2 batang serai', '3 lembar daun jeruk', '2 lembar daun salam', '3 cm lengkuas', '5 cabai merah besar', '10 cabai merah keriting', '8 siung bawang merah', '5 siung bawang putih', '3 cm jahe', '2 cm kunyit', 'Garam & gula secukupnya'],
        steps: ['Haluskan semua bumbu (cabai, bawang, jahe, kunyit).', 'Masak santan dengan bumbu halus, serai, daun jeruk, salam, lengkuas.', 'Masukkan daging, masak dengan api sedang sambil terus diaduk.', 'Kecilkan api saat santan mulai mengering.', 'Masak terus hingga daging berwarna coklat kehitaman dan kering (±3 jam).'],
        cookTimeMinutes: 180,
        servings: 4,
        rating: 5.0,
        isUserCreated: false,
        imagePath: 'asset:ASET/Rendang daging.jpg',
      ),
      Recipe(
        id: _uuid.v4(),
        name: 'Pisang Goreng Crispy',
        description: 'Pisang goreng renyah dengan balutan tepung gurih — snack legendaris Indonesia.',
        category: 'Snack',
        ingredients: ['4 buah pisang kepok/raja', '150g tepung terigu', '2 sdm tepung beras', '1/2 sdt garam', '1/4 sdt vanili', 'Air secukupnya', 'Minyak goreng untuk menggoreng'],
        steps: ['Kupas pisang, belah dua memanjang.', 'Campur tepung terigu, tepung beras, garam, vanili.', 'Tambahkan air sedikit demi sedikit hingga adonan kental.', 'Celupkan pisang ke adonan tepung.', 'Goreng dalam minyak panas hingga kuning keemasan.', 'Angkat, tiriskan. Sajikan hangat.'],
        cookTimeMinutes: 20,
        servings: 4,
        rating: 4.6,
        isUserCreated: false,
        imagePath: 'asset:ASET/pisang goreng crispy.jpg',
      ),
      Recipe(
        id: _uuid.v4(),
        name: 'Es Teh Tarik',
        description: 'Teh tarik creamy berbusa dengan rasa manis legit — minuman favorit warung kopi nusantara.',
        category: 'Minuman',
        ingredients: ['2 kantong teh celup', '200ml air panas', '100ml susu kental manis', '3 sdm gula pasir', 'Es batu secukupnya'],
        steps: ['Seduh teh dengan air panas, tunggu 3 menit lalu angkat kantong teh.', 'Tambahkan susu kental manis and gula, aduk rata.', '"Tarik" teh dengan menuang bolak-balik antara 2 gelas dari ketinggian agar berbusa.', 'Dinginkan sebentar, lalu tuang ke gelas berisi es batu.', 'Sajikan segera.'],
        cookTimeMinutes: 10,
        servings: 2,
        rating: 4.7,
        isUserCreated: false,
        imagePath: 'asset:ASET/Es Teh Tarik.jpg',
      ),
      Recipe(
        id: _uuid.v4(),
        name: 'Gado-Gado Jakarta',
        description: 'Gado-gado segar dengan sayuran rebus, tahu, tempe, dan siraman saus kacang yang gurih manis.',
        category: 'Makan Siang',
        ingredients: ['100g kangkung', '100g tauge', '2 buah kentang rebus', '100g tahu goreng', '100g tempe goreng', '2 butir telur rebus', 'Kerupuk untuk pelengkap', 'Saus kacang: 200g kacang tanah goreng, 3 cabai merah, 3 siung bawang putih, 2 sdm kecap manis, 1 sdm gula merah, garam, air asam, air secukupnya'],
        steps: ['Rebus kangkung dan tauge sebentar, tiriskan.', 'Haluskan kacang tanah, cabai, bawang putih.', 'Masak bumbu kacang dengan air, kecap manis, gula merah, garam, air asam hingga kental.', 'Tata sayuran, tahu, tempe, telur di piring.', 'Siram dengan saus kacang. Sajikan dengan kerupuk.'],
        cookTimeMinutes: 30,
        servings: 3,
        rating: 4.7,
        isUserCreated: false,
        imagePath: 'asset:ASET/gado gado Jakarta.jpg',
      ),
      Recipe(
        id: _uuid.v4(),
        name: 'Bakso Sapi Kuah',
        description: 'Bakso sapi kenyal gurih disajikan dengan kuah kaldu hangat yang kaya rasa, bihun, mie kuning, dan taburan seledri.',
        category: 'Makan Siang',
        ingredients: ['500g bakso sapi jadi', '2 liter air kaldu sapi', '4 siung bawang putih goreng haluskan', '2 sdt garam', '1 sdt merica bubuk', '100g bihun seduh', '100g mie kuning seduh', 'Daun seledri & bawang goreng secukupnya'],
        steps: ['Didihkan air kaldu sapi di panci.', 'Masukkan bawang putih halus, garam, merica. Aduk rata.', 'Masukkan bakso sapi, rebus hingga bakso mengapung (tanda matang).', 'Tata bihun dan mie kuning di mangkok.', 'Siram dengan kuah panas beserta bakso sapi. Taburi bawang goreng & seledri.'],
        cookTimeMinutes: 45,
        servings: 3,
        rating: 4.8,
        isUserCreated: false,
        imagePath: 'asset:ASET/Bakso Sapi Kuah.jpg',
      ),
      Recipe(
        id: _uuid.v4(),
        name: 'Sate Ayam Madura',
        description: 'Sate daging ayam empuk yang dibakar harum, disajikan dengan saus kacang gurih manis, kecap, irisan bawang merah, dan lontong.',
        category: 'Makan Malam',
        ingredients: ['500g dada ayam potong dadu', 'Tusuk sate secukupnya', '200g kacang tanah goreng', '3 siung bawang putih', '4 siung bawang merah', '2 sdm gula merah', 'Garam secukupnya', 'Kecap manis secukupnya'],
        steps: ['Tusuk potongan ayam pada tusuk sate.', 'Haluskan kacang tanah, bawang putih, bawang merah, gula merah, garam.', 'Tumis bumbu halus dengan sedikit air hingga mengental.', 'Ambil sedikit saus kacang, campur kecap manis, balurkan ke sate ayam sebelum dibakar.', 'Bakar sate hingga matang merata. Sajikan dengan sisa bumbu kacang.'],
        cookTimeMinutes: 40,
        servings: 4,
        rating: 4.9,
        isUserCreated: false,
        imagePath: 'asset:ASET/Sate ayam Madura.jpg',
      ),
      Recipe(
        id: _uuid.v4(),
        name: 'Martabak Manis',
        description: 'Martabak manis tebal berongga dengan topping keju parut melimpah, cokelat meises gurih, dan siraman susu kental manis.',
        category: 'Snack',
        ingredients: ['250g tepung terigu', '300ml air', '1/2 sdt ragi instan', '50g gula pasir', '1/2 sdt baking powder', '1 butir telur', 'Topping: Keju parut, meises, susu kental manis, margarin'],
        steps: ['Campur tepung terigu, gula, ragi, baking powder, telur, dan air. Aduk rata hingga licin.', 'Diamkan adonan selama 1 jam hingga mengembang.', 'Panaskan teflon dengan api kecil.', 'Tuang adonan, ratakan pinggirnya. Masak hingga berongga dan matang.', 'Oles margarin selagi hangat, beri keju parut, meises, dan susu kental manis.'],
        cookTimeMinutes: 30,
        servings: 6,
        rating: 4.9,
        isUserCreated: false,
        imagePath: 'asset:ASET/martabak manis.jpg',
      ),
      Recipe(
        id: _uuid.v4(),
        name: 'Es Cendol Durian',
        description: 'Minuman manis dingin berisi cendol hijau kenyal, buah durian harum, siraman gula merah cair manis legit, dan santan kelapa gurih.',
        category: 'Minuman',
        ingredients: ['150g cendol hijau matang', '200g buah durian manis', '150g gula merah sisir', '300ml santan kelapa matang', 'Es batu secukupnya', '100ml air'],
        steps: ['Rebus gula merah dengan air hingga larut dan mengental. Saring dan dinginkan.', 'Siapkan gelas saji.', 'Tuangkan gula merah cair di dasar gelas.', 'Masukkan cendol, es batu, lalu siram dengan santan kelapa.', 'Tambahkan buah durian di bagian paling atas. Sajikan dingin.'],
        cookTimeMinutes: 15,
        servings: 2,
        rating: 4.7,
        isUserCreated: false,
        imagePath: 'asset:ASET/Es Cendol Durian.jpg',
      ),
      Recipe(
        id: _uuid.v4(),
        name: 'Bubur Ayam Kuning',
        description: 'Bubur beras lembut dengan siraman kuah kuning gurih, suwiran ayam, kacang kedelai goreng, seledri, cakwe, dan kerupuk renyah.',
        category: 'Sarapan',
        ingredients: ['200g beras cuci bersih', '1.5 liter air kaldu ayam', '1 batang serai memarkan', '2 lembar daun salam', 'Kuah Kuning: Kunyit, bawang merah, bawang putih, garam tumis matang', 'Suwiran ayam goreng, cakwe, kedelai goreng, kerupuk'],
        steps: ['Masak beras dengan air kaldu ayam, serai, daun salam hingga menjadi bubur lembut.', 'Masak bumbu kuah kuning dengan sedikit kaldu ayam hingga mendidih.', 'Tata bubur hangat di mangkok.', 'Siram dengan kuah kuning.', 'Sajikan bersama suwiran ayam, cakwe, kedelai goreng, dan kerupuk.'],
        cookTimeMinutes: 35,
        servings: 2,
        rating: 4.8,
        isUserCreated: false,
        imagePath: 'asset:ASET/Bubur Ayam Kuning.jpg',
      ),
    ];

    for (final r in seeds) {
      final exists = _box.values.any((item) => item.name == r.name);
      if (!exists) {
        await _box.put(r.id, r);
      } else {
        // Update imagePath ke asset lokal jika masih pakai URL lama atau kosong
        final existing = _box.values.firstWhere((item) => item.name == r.name);
        if ((!existing.imagePath.startsWith('asset:')) && r.imagePath.isNotEmpty) {
          existing.imagePath = r.imagePath;
          await existing.save();
        }
      }
    }
    notifyListeners();
  }
}
