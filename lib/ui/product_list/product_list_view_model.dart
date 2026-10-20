import 'package:flutter/foundation.dart';
import '../../data/models/product.dart';
import '../../data/repositories/product_repository.dart';

class ProductListViewModel extends ChangeNotifier {
  final ProductRepository repository;

  ProductListViewModel({required this.repository});

  List<Product> _products = [];
  List<Product> get products => List.unmodifiable(_products);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _search = '';
  String get search => _search;

  String _selectedCategory = 'Semua';
  String get selectedCategory => _selectedCategory;

  DataSourceMode _sourceMode = DataSourceMode.autoSync;
  DataSourceMode get sourceMode => _sourceMode;

  String get sourceModeLabel {
    switch (_sourceMode) {
      case DataSourceMode.autoSync:
        return 'Auto Sync (API + SQLite)';
      case DataSourceMode.apiOnly:
        return 'Remote API Only';
      case DataSourceMode.localSqlite:
        return 'SQLite Database HP';
    }
  }

  Future<void> fetchProducts({bool showLoading = true}) async {
    if (showLoading) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final result = await repository.getProducts(
        search: _search.trim().isEmpty ? null : _search.trim(),
        category: _selectedCategory == 'Semua' ? null : _selectedCategory,
        mode: _sourceMode,
      );
      _products = result;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void onSearchChanged(String query) {
    _search = query;
    fetchProducts(showLoading: false);
  }

  void onCategorySelected(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    fetchProducts(showLoading: true);
  }

  void onSourceModeChanged(DataSourceMode mode) {
    if (_sourceMode == mode) return;
    _sourceMode = mode;
    fetchProducts(showLoading: true);
  }

  Future<void> syncData() async {
    _isLoading = true;
    notifyListeners();
    try {
      await repository.syncRemoteToLocal();
      await fetchProducts(showLoading: false);
    } catch (e) {
      _errorMessage = 'Gagal sinkronisasi: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addProduct(Product product) async {
    try {
      final created = await repository.createProduct(product);
      _products = [created, ..._products];
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> editProduct(Product product) async {
    try {
      final updated = await repository.updateProduct(product);
      final index = _products.indexWhere((e) => e.id == updated.id);
      if (index != -1) {
        _products[index] = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduct(String id) async {
    try {
      await repository.deleteProduct(id);
      _products.removeWhere((e) => e.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
