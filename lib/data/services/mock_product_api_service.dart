import 'dart:math';
import '../models/product.dart';
import 'product_api_service.dart';

class MockProductApiService implements ProductApiService {
  final Duration latency;

  MockProductApiService({
    this.latency = const Duration(milliseconds: 300),
  }) {
    _seedData();
  }

  final List<Product> _storage = [];

  void _seedData() {
    _storage.addAll([
      Product(
        id: 'PRD-101',
        name: 'MacBook Pro M3 14"',
        category: 'Elektronik',
        price: 28999000.0,
        stock: 12,
        description: 'Apple M3 Chip dengan RAM 16GB dan SSD 512GB Space Grey.',
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Product(
        id: 'PRD-102',
        name: 'Logitech MX Master 3S',
        category: 'Aksesoris',
        price: 1450000.0,
        stock: 35,
        description: 'Wireless mouse ergonomis dengan sensor Darkfield 8K DPI.',
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Product(
        id: 'PRD-103',
        name: 'Keychron Q1 Pro Mechanical Keyboard',
        category: 'Aksesoris',
        price: 2750000.0,
        stock: 18,
        description: 'Wireless custom mechanical keyboard 75% layout.',
        updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      Product(
        id: 'PRD-104',
        name: 'Dell UltraSharp 27" 4K Monitor',
        category: 'Elektronik',
        price: 8900000.0,
        stock: 7,
        description: 'Monitor IPS Black USB-C Hub 4K UHD 100% sRGB warna akurat.',
        updatedAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      Product(
        id: 'PRD-105',
        name: 'Ergonomic Desk Chair Sihoo',
        category: 'Furnitur',
        price: 4200000.0,
        stock: 5,
        description: 'Kursi kerja ergonomis jaring mesh dengan penopang pinggang.',
        updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ]);
  }

  Future<void> _delay() async {
    if (latency > Duration.zero) {
      await Future.delayed(latency);
    }
  }

  @override
  Future<List<Product>> getProducts({String? search, String? category}) async {
    await _delay();
    var result = List<Product>.from(_storage);

    if (search != null && search.trim().isNotEmpty) {
      final q = search.toLowerCase();
      result = result.where((item) {
        return item.name.toLowerCase().contains(q) ||
            item.description.toLowerCase().contains(q);
      }).toList();
    }

    if (category != null && category.isNotEmpty && category != 'Semua') {
      result = result.where((item) => item.category == category).toList();
    }

    return result;
  }

  @override
  Future<Product> getProductById(String id) async {
    await _delay();
    return _storage.firstWhere(
      (item) => item.id == id,
      orElse: () => throw Exception('Produk dengan ID $id tidak ditemukan'),
    );
  }

  @override
  Future<Product> createProduct(Product product) async {
    await _delay();
    final newId = product.id.isNotEmpty
        ? product.id
        : 'PRD-${Random().nextInt(900) + 100}';

    final created = product.copyWith(
      id: newId,
      updatedAt: DateTime.now(),
    );

    _storage.insert(0, created);
    return created;
  }

  @override
  Future<Product> updateProduct(Product product) async {
    await _delay();
    final index = _storage.indexWhere((e) => e.id == product.id);
    if (index == -1) {
      throw Exception('Produk tidak ditemukan untuk diperbarui');
    }

    final updated = product.copyWith(updatedAt: DateTime.now());
    _storage[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _delay();
    final index = _storage.indexWhere((e) => e.id == id);
    if (index == -1) {
      throw Exception('Produk tidak ditemukan untuk dihapus');
    }
    _storage.removeAt(index);
  }
}
