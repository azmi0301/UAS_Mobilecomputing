import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../models/recipe.dart';
import '../providers/recipe_provider.dart';
import '../theme/app_theme.dart';

class EditRecipeScreen extends StatefulWidget {
  final Recipe recipe;
  const EditRecipeScreen({super.key, required this.recipe});

  @override
  State<EditRecipeScreen> createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _cookTimeCtrl;
  late final TextEditingController _servingsCtrl;

  late String _selectedCategory;
  late String _existingImagePath;   // path/base64 yang sudah tersimpan
  Uint8List? _newImageBytes;        // bytes gambar baru yang baru dipilih
  late List<TextEditingController> _ingredientCtrls;
  late List<TextEditingController> _stepCtrls;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final r = widget.recipe;
    _nameCtrl = TextEditingController(text: r.name);
    _descCtrl = TextEditingController(text: r.description);
    _cookTimeCtrl = TextEditingController(text: r.cookTimeMinutes.toString());
    _servingsCtrl = TextEditingController(text: r.servings.toString());
    _selectedCategory = r.category;
    _existingImagePath = r.imagePath;
    _ingredientCtrls = r.ingredients.map((s) => TextEditingController(text: s)).toList();
    if (_ingredientCtrls.isEmpty) _ingredientCtrls.add(TextEditingController());
    _stepCtrls = r.steps.map((s) => TextEditingController(text: s)).toList();
    if (_stepCtrls.isEmpty) _stepCtrls.add(TextEditingController());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _cookTimeCtrl.dispose();
    _servingsCtrl.dispose();
    for (final c in _ingredientCtrls) c.dispose();
    for (final c in _stepCtrls) c.dispose();
    super.dispose();
  }

  XFile? _pickedXFile;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _newImageBytes = bytes;
        _pickedXFile = picked;
      });
    }
  }

  Future<String> _buildFinalImagePath() async {
    if (_newImageBytes != null) {
      if (kIsWeb || _pickedXFile == null) {
        final b64 = base64Encode(_newImageBytes!);
        return 'data:image/jpeg;base64,$b64';
      }
      // Mobile/Desktop: salin ke direktori permanen
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final imagesDir = Directory('${appDir.path}/recipe_images');
        if (!await imagesDir.exists()) {
          await imagesDir.create(recursive: true);
        }
        final ext = _pickedXFile!.name.split('.').last.toLowerCase();
        final fileName = 'recipe_${DateTime.now().millisecondsSinceEpoch}.$ext';
        final savedFile = await File(_pickedXFile!.path).copy('${imagesDir.path}/$fileName');
        return savedFile.path;
      } catch (_) {
        final b64 = base64Encode(_newImageBytes!);
        return 'data:image/jpeg;base64,$b64';
      }
    }
    return _existingImagePath; // path lama tidak berubah
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama resep wajib diisi!')),
      );
      return;
    }
    setState(() => _isLoading = true);

    final r = widget.recipe;
    r.name = _nameCtrl.text.trim();
    r.description = _descCtrl.text.trim();
    r.category = _selectedCategory;
    r.cookTimeMinutes = int.tryParse(_cookTimeCtrl.text) ?? r.cookTimeMinutes;
    r.servings = int.tryParse(_servingsCtrl.text) ?? r.servings;
    r.ingredients = _ingredientCtrls.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList();
    r.steps = _stepCtrls.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList();
    final imagePath = await _buildFinalImagePath();
    r.imagePath = imagePath;

    await context.read<RecipeProvider>().updateRecipe(r);

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Resep berhasil diperbarui! ✅'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Widget _buildImagePreview(Color color) {
    // Prioritas: bytes baru > existing path
    if (_newImageBytes != null) {
      return Stack(fit: StackFit.expand, children: [
        Image.memory(_newImageBytes!, fit: BoxFit.cover),
        _changePill(),
      ]);
    }

    if (_existingImagePath.isNotEmpty) {
      Widget img;
      if (_existingImagePath.startsWith('http')) {
        img = Image.network(_existingImagePath, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _placeholderBox(color));
      } else if (_existingImagePath.startsWith('data:')) {
        try {
          final bytes = base64Decode(_existingImagePath.split(',').last);
          img = Image.memory(bytes, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholderBox(color));
        } catch (_) {
          img = _placeholderBox(color);
        }
      } else if (!kIsWeb) {
        img = FutureBuilder<bool>(
          future: File(_existingImagePath).exists(),
          builder: (ctx, snap) {
            if (snap.data == true) {
              return Image.file(File(_existingImagePath), fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholderBox(color));
            }
            return _placeholderBox(color);
          },
        );
      } else {
        img = _placeholderBox(color);
      }
      return Stack(fit: StackFit.expand, children: [img, _changePill()]);
    }

    // Belum ada gambar
    return GestureDetector(
      onTap: _pickImage,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.add_photo_alternate_outlined, color: color, size: 34),
        ),
        const SizedBox(height: 10),
        const Text('Tap untuk tambah foto',
            style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        const Text('JPEG, PNG didukung',
            style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
      ]),
    );
  }

  Widget _placeholderBox(Color color) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.7), color],
        ),
      ),
      child: Center(
        child: Text(
          AppColors.categoryEmojis[widget.recipe.category] ?? '🍽️',
          style: const TextStyle(fontSize: 60),
        ),
      ),
    );
  }

  Widget _changePill() {
    return Positioned(
      bottom: 8,
      right: 8,
      child: GestureDetector(
        onTap: _pickImage,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.edit, size: 12, color: Colors.white),
            SizedBox(width: 4),
            Text('Ganti foto', style: TextStyle(color: Colors.white, fontSize: 11)),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.categoryColors[_selectedCategory] ?? AppColors.primary;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: const Text('Edit Resep'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _save,
            child: _isLoading
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Simpan', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Foto ──────────────────────────────────────────
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.bgSecondary,
              borderRadius: BorderRadius.circular(20),
            ),
            clipBehavior: Clip.antiAlias,
            child: _buildImagePreview(color),
          ),
          const SizedBox(height: 20),

          _Label('Nama Resep'),
          TextField(controller: _nameCtrl, decoration: const InputDecoration(hintText: 'Nama resep')),
          const SizedBox(height: 14),

          _Label('Deskripsi'),
          TextField(controller: _descCtrl, maxLines: 2, decoration: const InputDecoration(hintText: 'Deskripsi singkat...')),
          const SizedBox(height: 14),

          _Label('Kategori'),
          Wrap(
            spacing: 8,
            children: RecipeProvider.categories.where((c) => c != 'Semua').map((cat) {
              final c = AppColors.categoryColors[cat] ?? AppColors.primary;
              final isSelected = _selectedCategory == cat;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? c : c.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${AppColors.categoryEmojis[cat]} $cat',
                    style: TextStyle(color: isSelected ? Colors.white : c, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _Label('Waktu (menit)'),
              TextField(controller: _cookTimeCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: '30')),
            ])),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _Label('Porsi'),
              TextField(controller: _servingsCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: '2')),
            ])),
          ]),
          const SizedBox(height: 20),

          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _Label('Bahan-bahan'),
            TextButton.icon(
              onPressed: () => setState(() => _ingredientCtrls.add(TextEditingController())),
              icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
              label: const Text('Tambah', style: TextStyle(color: AppColors.primary, fontSize: 13)),
            ),
          ]),
          ..._ingredientCtrls.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Container(
                width: 26, height: 26,
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Center(child: Text('${e.key + 1}', style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700))),
              ),
              const SizedBox(width: 8),
              Expanded(child: TextField(controller: e.value, decoration: const InputDecoration(hintText: 'Contoh: 2 sdm gula pasir'))),
              if (_ingredientCtrls.length > 1)
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: AppColors.pink, size: 20),
                  onPressed: () => setState(() { e.value.dispose(); _ingredientCtrls.removeAt(e.key); }),
                ),
            ]),
          )),
          const SizedBox(height: 20),

          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _Label('Cara Membuat'),
            TextButton.icon(
              onPressed: () => setState(() => _stepCtrls.add(TextEditingController())),
              icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
              label: const Text('Tambah', style: TextStyle(color: AppColors.primary, fontSize: 13)),
            ),
          ]),
          ..._stepCtrls.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 26, height: 26,
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: Center(child: Text('${e.key + 1}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))),
              ),
              const SizedBox(width: 8),
              Expanded(child: TextField(controller: e.value, maxLines: 2, decoration: InputDecoration(hintText: 'Langkah ${e.key + 1}...'))),
              if (_stepCtrls.length > 1)
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: AppColors.pink, size: 20),
                  onPressed: () => setState(() { e.value.dispose(); _stepCtrls.removeAt(e.key); }),
                ),
            ]),
          )),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: _isLoading ? null : _save,
            child: _isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Simpan Perubahan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
    );
  }
}
