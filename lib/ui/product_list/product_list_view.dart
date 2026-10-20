import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/product.dart';
import '../../data/repositories/product_repository.dart';
import '../product_detail/product_detail_view.dart';
import '../product_form/product_form_view.dart';
import 'product_list_view_model.dart';
import 'widgets/category_chips.dart';
import 'widgets/product_card.dart';

class ProductListView extends StatefulWidget {
  final ProductListViewModel viewModel;

  const ProductListView({super.key, required this.viewModel});

  @override
  State<ProductListView> createState() => _ProductListViewState();
}

class _ProductListViewState extends State<ProductListView> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.viewModel.fetchProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToAdd() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductFormView(viewModel: widget.viewModel),
      ),
    );
  }

  void _navigateToDetail(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailView(
          product: product,
          viewModel: widget.viewModel,
        ),
      ),
    );
  }

  void _navigateToEdit(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductFormView(
          productToEdit: product,
          viewModel: widget.viewModel,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: Text('Hapus "${product.name}" dari katalog?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await widget.viewModel.deleteProduct(product.id);
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produk berhasil dihapus')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus: ${widget.viewModel.errorMessage}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.inventory_2, color: Colors.indigo),
            SizedBox(width: 10),
            Text('Katalog Produk', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          // Tombol Pilih Sumber Data (API vs SQLite vs AutoSync)
          PopupMenuButton<DataSourceMode>(
            icon: const Icon(Icons.storage_rounded, color: Colors.indigo),
            tooltip: 'Pilih Sumber Data (API / SQLite)',
            onSelected: (mode) => widget.viewModel.onSourceModeChanged(mode),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: DataSourceMode.autoSync,
                child: Row(
                  children: [
                    Icon(Icons.sync_alt, color: Colors.indigo),
                    SizedBox(width: 10),
                    Text('Auto Sync (API + SQLite)'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: DataSourceMode.apiOnly,
                child: Row(
                  children: [
                    Icon(Icons.cloud_outlined, color: Colors.blue),
                    SizedBox(width: 10),
                    Text('Fetch dari Remote API'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: DataSourceMode.localSqlite,
                child: Row(
                  children: [
                    Icon(Icons.phone_android, color: Colors.teal),
                    SizedBox(width: 10),
                    Text('Fetch dari SQLite HP'),
                  ],
                ),
              ),
            ],
          ),
          // Sinkronisasi Manual
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Sinkronisasi API ke SQLite HP',
            onPressed: () => widget.viewModel.syncData(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Banner Status Sumber Data
          ListenableBuilder(
            listenable: widget.viewModel,
            builder: (context, _) {
              final mode = widget.viewModel.sourceMode;
              Color bg;
              Color textCol;
              IconData icon;

              switch (mode) {
                case DataSourceMode.autoSync:
                  bg = Colors.indigo.shade50;
                  textCol = Colors.indigo.shade800;
                  icon = Icons.sync_alt;
                  break;
                case DataSourceMode.apiOnly:
                  bg = Colors.blue.shade50;
                  textCol = Colors.blue.shade800;
                  icon = Icons.cloud_outlined;
                  break;
                case DataSourceMode.localSqlite:
                  bg = Colors.teal.shade50;
                  textCol = Colors.teal.shade800;
                  icon = Icons.phone_android;
                  break;
              }

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                color: bg,
                child: Row(
                  children: [
                    Icon(icon, size: 16, color: textCol),
                    const SizedBox(width: 8),
                    Text(
                      'Sumber Data: ${widget.viewModel.sourceModeLabel}',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textCol),
                    ),
                    const Spacer(),
                    Text(
                      '${widget.viewModel.products.length} Item',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textCol),
                    ),
                  ],
                ),
              );
            },
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: widget.viewModel.onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Cari produk atau deskripsi...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          widget.viewModel.onSearchChanged('');
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
            ),
          ),

          // Category Chips
          ListenableBuilder(
            listenable: widget.viewModel,
            builder: (context, _) {
              return CategoryChips(
                categories: AppConstants.categories,
                selectedCategory: widget.viewModel.selectedCategory,
                onSelected: widget.viewModel.onCategorySelected,
              );
            },
          ),
          const SizedBox(height: 8),

          // Product List Area
          Expanded(
            child: ListenableBuilder(
              listenable: widget.viewModel,
              builder: (context, _) {
                final vm = widget.viewModel;

                if (vm.isLoading && vm.products.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (vm.errorMessage != null && vm.products.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline, size: 54, color: Colors.redAccent),
                          const SizedBox(height: 12),
                          Text(vm.errorMessage!, textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => vm.fetchProducts(),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (vm.products.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            vm.search.isNotEmpty || vm.selectedCategory != 'Semua'
                                ? 'Tidak ada produk yang cocok'
                                : 'Database masih kosong',
                            style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
                          ),
                          if (vm.search.isNotEmpty || vm.selectedCategory != 'Semua') ...[
                            const SizedBox(height: 12),
                            TextButton.icon(
                              onPressed: () {
                                _searchController.clear();
                                vm.onSearchChanged('');
                                vm.onCategorySelected('Semua');
                              },
                              icon: const Icon(Icons.filter_alt_off),
                              label: const Text('Reset Filter'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => vm.fetchProducts(showLoading: false),
                  child: ListView.builder(
                    itemCount: vm.products.length,
                    padding: const EdgeInsets.only(bottom: 80),
                    itemBuilder: (context, index) {
                      final product = vm.products[index];
                      return ProductCard(
                        product: product,
                        onTap: () => _navigateToDetail(product),
                        onEdit: () => _navigateToEdit(product),
                        onDelete: () => _confirmDelete(product),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAdd,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Produk'),
      ),
    );
  }
}
