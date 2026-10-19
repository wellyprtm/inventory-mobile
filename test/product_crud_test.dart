import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_apps/data/models/product.dart';
import 'package:inventory_apps/data/repositories/product_repository_impl.dart';
import 'package:inventory_apps/data/services/mock_product_api_service.dart';
import 'package:inventory_apps/ui/product_list/product_list_view_model.dart';

void main() {
  late ProductListViewModel viewModel;

  setUp(() {
    final mockService = MockProductApiService(latency: Duration.zero);
    final repository = ProductRepositoryImpl(apiService: mockService);
    viewModel = ProductListViewModel(repository: repository);
  });

  group('Product MVVM CRUD Tests', () {
    test('1. READ: fetchProducts loads initial product list successfully', () async {
      await viewModel.fetchProducts();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.products.isNotEmpty, isTrue);
      expect(viewModel.products.length, greaterThanOrEqualTo(5));
    });

    test('2. CREATE: addProduct adds a new item to the list', () async {
      await viewModel.fetchProducts();
      final initialCount = viewModel.products.length;

      final success = await viewModel.addProduct(
        Product(
          id: '',
          name: 'Sony WH-1000XM5',
          category: 'Aksesoris',
          price: 4999000.0,
          stock: 10,
          description: 'Noise cancelling premium headphone',
          updatedAt: DateTime.now(),
        ),
      );

      expect(success, isTrue);
      expect(viewModel.products.length, equals(initialCount + 1));
      expect(viewModel.products.first.name, equals('Sony WH-1000XM5'));
    });

    test('3. UPDATE: editProduct modifies existing product data', () async {
      await viewModel.fetchProducts();
      final target = viewModel.products.first;

      final updated = target.copyWith(
        name: 'MacBook Pro M3 Max 16"',
        price: 45000000.0,
        stock: 4,
      );

      final success = await viewModel.editProduct(updated);

      expect(success, isTrue);
      final found = viewModel.products.firstWhere((e) => e.id == target.id);
      expect(found.name, equals('MacBook Pro M3 Max 16"'));
      expect(found.price, equals(45000000.0));
      expect(found.stock, equals(4));
    });

    test('4. DELETE: deleteProduct removes product by ID', () async {
      await viewModel.fetchProducts();
      final targetId = viewModel.products.first.id;
      final initialCount = viewModel.products.length;

      final success = await viewModel.deleteProduct(targetId);

      expect(success, isTrue);
      expect(viewModel.products.length, equals(initialCount - 1));
      expect(viewModel.products.any((e) => e.id == targetId), isFalse);
    });

    test('5. SEARCH & FILTER: onSearchChanged and category filter work properly', () async {
      await viewModel.fetchProducts();

      // Filter category 'Elektronik'
      viewModel.onCategorySelected('Elektronik');
      await Future.delayed(const Duration(milliseconds: 10));

      for (final item in viewModel.products) {
        expect(item.category, equals('Elektronik'));
      }

      // Search keyword 'Logitech'
      viewModel.onCategorySelected('Semua');
      viewModel.onSearchChanged('Logitech');
      await Future.delayed(const Duration(milliseconds: 10));

      expect(viewModel.products.length, equals(1));
      expect(viewModel.products.first.name.contains('Logitech'), isTrue);
    });
  });
}
