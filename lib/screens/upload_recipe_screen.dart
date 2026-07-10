import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/recipe_provider.dart';
import '../theme/app_theme.dart';

class UploadRecipeScreen extends StatefulWidget {
  const UploadRecipeScreen({super.key});

  @override
  State<UploadRecipeScreen> createState() => _UploadRecipeScreenState();
}

class _UploadRecipeScreenState extends State<UploadRecipeScreen> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _cookTimeCtrl = TextEditingController();
  final _servingsCtrl = TextEditingController();

  String _selectedCategory = 'Sarapan';
  XFile? _pickedImage;
  Uint8List? _imageBytes;
  final List<TextEditingController> _ingredientCtrls = [TextEditingController()];
  final List<TextEditingController> _stepCtrls = [TextEditingController()];
  bool _isLoading = false;

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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _pickedImage = picked;
        _imageBytes = bytes;
      });
    }
  }

  /// Menyalin gambar ke direktori internal app (permanen) dan mengembalikan path-nya.
  /// - Web → base64 data URL
  /// - Mobile/Desktop → salin ke getApplicationDocumentsDirectory
  Future<String> _buildImagePath() async {
    if (_imageBytes == null) return '';
    if (kIsWeb || _pickedImage == null) {
      // Web: simpan sebagai data URL base64
      final b64 = base64Encode(_imageBytes!);
      return 'data:image/jpeg;base64,$b64';
    }
    // Mobile/Desktop: salin ke direktori permanen agar tidak hilang setelah restart
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${appDir.path}/recipe_images');
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }
      final ext = _pickedImage!.name.split('.').last.toLowerCase();
      final fileName = 'recipe_${DateTime.now().millisecondsSinceEpoch}.$ext';
      final savedFile = await File(_pickedImage!.path).copy('${imagesDir.path}/$fileName');
      return savedFile.path;
    } catch (_) {
      // Fallback ke base64 jika gagal copy
      final b64 = base64Encode(_imageBytes!);
      return 'data:image/jpeg;base64,$b64';
    }
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama resep wajib diisi!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final ingredients = _ingredientCtrls
        .map((c) => c.text.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final steps = _stepCtrls
        .map((c) => c.text.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final imagePath = await _buildImagePath();

    if (!mounted) return;

    await context.read<RecipeProvider>().addRecipe(
          name: _nameCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          category: _selectedCategory,
          ingredients: ingredients.isEmpty ? ['Tidak ada bahan'] : ingredients,
          steps: steps.isEmpty ? ['Tidak ada langkah'] : steps,
          cookTimeMinutes: int.tryParse(_cookTimeCtrl.text) ?? 30,
          servings: int.tryParse(_servingsCtrl.text) ?? 2,
          imagePath: imagePath,
          isUserCreated: true,
        );

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Resep berhasil ditambahkan! 🎉'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Widget _buildImagePreview() {
    if (_imageBytes != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.memory(_imageBytes!, fit: BoxFit.cover),
          Positioned(
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
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit, size: 12, color: Colors.white),
                    SizedBox(width: 4),
                    Text('Ganti foto',
                        style: TextStyle(color: Colors.white, fontSize: 11)),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: _pickImage,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.camera_alt_outlined,
                color: AppColors.primary, size: 32),
          ),
          const SizedBox(height: 10),
          const Text('Tap untuk tambah foto',
              style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          const Text('JPEG, PNG didukung',
              style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: const Text('Upload Resep'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _save,
            child: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Simpan',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Foto ──────────────────────────────────────────
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: AppColors.bgSecondary,
              borderRadius: BorderRadius.circular(20),
            ),
            clipBehavior: Clip.antiAlias,
            child: _buildImagePreview(),
          ),
          const SizedBox(height: 20),

          _Label('Nama Resep'),
          TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                  hintText: 'Contoh: Soto Ayam Lamongan')),
          const SizedBox(height: 14),

          _Label('Deskripsi'),
          TextField(
              controller: _descCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                  hintText: 'Ceritakan resep ini...')),
          const SizedBox(height: 14),

          _Label('Kategori'),
          Wrap(
            spacing: 8,
            children: RecipeProvider.categories
                .where((c) => c != 'Semua')
                .map((cat) {
              final color =
                  AppColors.categoryColors[cat] ?? AppColors.primary;
              final isSelected = _selectedCategory == cat;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? color : color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${AppColors.categoryEmojis[cat]} $cat',
                    style: TextStyle(
                        color: isSelected ? Colors.white : color,
                        fontWeight: FontWeight.w600,
                        fontSize: 13),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Label('Waktu Masak (menit)'),
                    TextField(
                        controller: _cookTimeCtrl,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(hintText: '30')),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Label('Porsi'),
                    TextField(
                        controller: _servingsCtrl,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(hintText: '2')),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Label('Bahan-bahan'),
              TextButton.icon(
                onPressed: () => setState(
                    () => _ingredientCtrls.add(TextEditingController())),
                icon: const Icon(Icons.add,
                    size: 16, color: AppColors.primary),
                label: const Text('Tambah',
                    style: TextStyle(
                        color: AppColors.primary, fontSize: 13)),
              ),
            ],
          ),
          ..._ingredientCtrls.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                          color:
                              AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle),
                      child: Center(
                          child: Text('${e.key + 1}',
                              style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700))),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                          controller: e.value,
                          decoration: const InputDecoration(
                              hintText: 'Contoh: 2 sdm gula pasir')),
                    ),
                    if (_ingredientCtrls.length > 1)
                      IconButton(
                        icon: const Icon(
                            Icons.remove_circle_outline,
                            color: AppColors.pink,
                            size: 20),
                        onPressed: () => setState(() {
                          e.value.dispose();
                          _ingredientCtrls.removeAt(e.key);
                        }),
                      ),
                  ],
                ),
              )),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Label('Cara Membuat'),
              TextButton.icon(
                onPressed: () => setState(
                    () => _stepCtrls.add(TextEditingController())),
                icon: const Icon(Icons.add,
                    size: 16, color: AppColors.primary),
                label: const Text('Tambah',
                    style: TextStyle(
                        color: AppColors.primary, fontSize: 13)),
              ),
            ],
          ),
          ..._stepCtrls.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle),
                      child: Center(
                          child: Text('${e.key + 1}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700))),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: e.value,
                        maxLines: 2,
                        decoration: InputDecoration(
                            hintText: 'Langkah ${e.key + 1}...'),
                      ),
                    ),
                    if (_stepCtrls.length > 1)
                      IconButton(
                        icon: const Icon(
                            Icons.remove_circle_outline,
                            color: AppColors.pink,
                            size: 20),
                        onPressed: () => setState(() {
                          e.value.dispose();
                          _stepCtrls.removeAt(e.key);
                        }),
                      ),
                  ],
                ),
              )),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: _isLoading ? null : _save,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Text('Simpan Resep',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
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
      child: Text(text,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary)),
    );
  }
}
