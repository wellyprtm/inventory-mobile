import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_apps/data/local/product_database_helper.dart';
import 'package:inventory_apps/data/models/product.dart';
import 'package:inventory_apps/data/repositories/product_repository.dart';
import 'package:inventory_apps/data/repositories/product_repository_impl.dart';
import 'package:inventory_apps/data/services/mock_product_api_service.dart';
import 'package:inventory_apps/ui/product_list/product_list_view_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late ProductListViewModel viewModel;
  late ProductDatabaseHelper localDb;
  late MockProductApiService mockService;

  setUpAll(() {
    // Initialize FFI for real SQLite engine execution during tests
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    localDb = ProductDatabaseHelper.instance;
    await localDb.clearAll();

    mockService = MockProductApiService(latency: Duration.zero);
    final repository = ProductRepositoryImpl(
      apiService: mockService,
      localDb: localDb,
    );
    viewModel = ProductListViewModel(repository: repository);
  });

  group('Product MVVM + SQLite + API Tests', () {
    test('1. READ: fetchProducts with autoSync loads data and caches to SQLite', () async {
      await viewModel.fetchProducts();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.products.isNotEmpty, isTrue);
      expect(viewModel.products.length, greaterThanOrEqualTo(5));

      // Verify data is cached in SQLite local DB
      final sqliteItems = await localDb.getProducts();
      expect(sqliteItems.isNotEmpty, isTrue);
    });

    test('2. SQLITE: fetch directly from local SQLite database', () async {
      // Seed SQLite directly
      await localDb.saveProduct(
        Product(
          id: 'SQL-001',
          name: 'Offline SQLite Item',
          category: 'Elektronik',
          price: 500000.0,
          stock: 20,
          description: 'Disimpan langsung di database HP',
          updatedAt: DateTime.now(),
        ),
      );

      viewModel.onSourceModeChanged(DataSourceMode.localSqlite);
      await viewModel.fetchProducts();

      expect(viewModel.products.any((e) => e.id == 'SQL-001'), isTrue);
      expect(viewModel.sourceMode, equals(DataSourceMode.localSqlite));
    });

    test('3. CREATE: addProduct saves to both API and SQLite', () async {
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

      // Check SQLite also received it
      final inSqlite = await localDb.getProductById(viewModel.products.first.id);
      expect(inSqlite, isNotNull);
      expect(inSqlite!.name, equals('Sony WH-1000XM5'));
    });

    test('4. UPDATE: editProduct updates SQLite and remote state', () async {
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

      // Verify update persisted in SQLite
      final sqliteUpdated = await localDb.getProductById(target.id);
      expect(sqliteUpdated?.name, equals('MacBook Pro M3 Max 16"'));
    });

    test('5. DELETE: deleteProduct removes from both state and SQLite', () async {
      await viewModel.fetchProducts();
      final targetId = viewModel.products.first.id;
      final initialCount = viewModel.products.length;

      final success = await viewModel.deleteProduct(targetId);

      expect(success, isTrue);
      expect(viewModel.products.length, equals(initialCount - 1));
      expect(viewModel.products.any((e) => e.id == targetId), isFalse);

      // Verify deleted from SQLite
      final sqliteItem = await localDb.getProductById(targetId);
      expect(sqliteItem, isNull);
    });

    test('6. SEARCH & FILTER: works across SQLite and in-memory list', () async {
      await viewModel.fetchProducts();

      // Filter category 'Elektronik'
      viewModel.onCategorySelected('Elektronik');
      await viewModel.fetchProducts();

      for (final item in viewModel.products) {
        expect(item.category, equals('Elektronik'));
      }

      // Search keyword 'Logitech'
      viewModel.onCategorySelected('Semua');
      viewModel.onSearchChanged('Logitech');
      await viewModel.fetchProducts();

      expect(viewModel.products.length, equals(1));
      expect(viewModel.products.first.name.contains('Logitech'), isTrue);
    });
  });
}
