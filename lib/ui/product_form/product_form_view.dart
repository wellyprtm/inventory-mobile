import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/product.dart';
import '../product_list/product_list_view_model.dart';

class ProductFormView extends StatefulWidget {
  final Product? productToEdit;
  final ProductListViewModel viewModel;

  const ProductFormView({
    super.key,
    this.productToEdit,
    required this.viewModel,
  });

  bool get isEditMode => productToEdit != null;

  @override
  State<ProductFormView> createState() => _ProductFormViewState();
}

class _ProductFormViewState extends State<ProductFormView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final TextEditingController _descController;
  late String _selectedCategory;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final item = widget.productToEdit;
    _nameController = TextEditingController(text: item?.name ?? '');
    _priceController = TextEditingController(
      text: item != null ? item.price.toStringAsFixed(0) : '',
    );
    _stockController = TextEditingController(
      text: item != null ? item.stock.toString() : '',
    );
    _descController = TextEditingController(text: item?.description ?? '');
    _selectedCategory = item?.category ?? AppConstants.formCategories.first;
    if (!AppConstants.formCategories.contains(_selectedCategory)) {
      _selectedCategory = AppConstants.formCategories.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final name = _nameController.text.trim();
    final price = double.parse(_priceController.text.trim());
    final stock = int.parse(_stockController.text.trim());
    final desc = _descController.text.trim();

    bool success;
    if (widget.isEditMode) {
      final updated = widget.productToEdit!.copyWith(
        name: name,
        category: _selectedCategory,
        price: price,
        stock: stock,
        description: desc,
        updatedAt: DateTime.now(),
      );
      success = await widget.viewModel.editProduct(updated);
    } else {
      final newProduct = Product(
        id: '',
        name: name,
        category: _selectedCategory,
        price: price,
        stock: stock,
        description: desc,
        updatedAt: DateTime.now(),
      );
      success = await widget.viewModel.addProduct(newProduct);
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditMode
                ? 'Produk berhasil diperbarui'
                : 'Produk berhasil ditambahkan',
          ),
          backgroundColor: Colors.green.shade700,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan: ${widget.viewModel.errorMessage}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isEditMode ? 'Edit Produk' : 'Tambah Produk Baru';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Produk *',
                hintText: 'Contoh: Wireless Mouse',
                prefixIcon: Icon(Icons.inventory),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Nama produk wajib diisi';
                }
                if (val.trim().length < 3) {
                  return 'Nama produk minimal 3 karakter';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Category Dropdown
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Kategori *',
                prefixIcon: Icon(Icons.category),
              ),
              items: AppConstants.formCategories.map((cat) {
                return DropdownMenuItem(value: cat, child: Text(cat));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCategory = val);
              },
            ),
            const SizedBox(height: 16),

            // Price & Stock
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Harga (Rp) *',
                      prefixText: 'Rp ',
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Harga wajib diisi';
                      }
                      final n = double.tryParse(val.trim());
                      if (n == null || n <= 0) return 'Harga harus > 0';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _stockController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Jumlah Stok *',
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Stok wajib diisi';
                      }
                      final n = int.tryParse(val.trim());
                      if (n == null || n < 0) return 'Stok minimal 0';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Deskripsi Produk',
                hintText: 'Spesifikasi atau catatan barang...',
                prefixIcon: Icon(Icons.description),
              ),
            ),
            const SizedBox(height: 28),

            // Submit Button
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submit,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  widget.isEditMode ? 'Simpan Perubahan' : 'Tambah ke Katalog',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
