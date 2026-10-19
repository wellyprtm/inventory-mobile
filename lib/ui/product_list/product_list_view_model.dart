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
