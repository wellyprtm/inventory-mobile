import '../local/product_database_helper.dart';
import '../models/product.dart';
import '../services/product_api_service.dart';
import 'product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductApiService apiService;
  final ProductDatabaseHelper localDb;

  ProductRepositoryImpl({
    required this.apiService,
    ProductDatabaseHelper? localDb,
  }) : localDb = localDb ?? ProductDatabaseHelper.instance;

  @override
  Future<List<Product>> getProducts({
    String? search,
    String? category,
    DataSourceMode mode = DataSourceMode.autoSync,
  }) async {
    // 1. Mode Murni SQLite Lokal HP
    if (mode == DataSourceMode.localSqlite) {
      final localData = await localDb.getProducts(search: search, category: category);
      if (localData.isNotEmpty) return localData;

      // Jika database SQLite masih kosong pertama kali, isi dari API lalu simpan ke SQLite
      final initialData = await apiService.getProducts();
      await localDb.saveProducts(initialData);
      return localDb.getProducts(search: search, category: category);
    }

    // 2. Mode Murni Remote API
    if (mode == DataSourceMode.apiOnly) {
      return await apiService.getProducts(search: search, category: category);
    }

    // 3. Mode Auto Sync (Offline-First):
    // Coba ambil dari Remote API. Jika berhasil, simpan/cache ke SQLite HP.
    // Jika gagal (misal tidak ada koneksi internet), ambil dari SQLite HP sebagai fallback.
    try {
      final remoteProducts = await apiService.getProducts(search: search, category: category);
      // Cache ke SQLite secara background
      await localDb.saveProducts(remoteProducts);
      return remoteProducts;
    } catch (_) {
      // Fallback ke SQLite lokal di HP jika API error / offline
      final cachedProducts = await localDb.getProducts(search: search, category: category);
      if (cachedProducts.isNotEmpty) {
        return cachedProducts;
      }
      rethrow;
    }
  }

  @override
  Future<Product> getProductById(String id) async {
    // Cek SQLite dulu
    final local = await localDb.getProductById(id);
    if (local != null) return local;

    // Kalau tidak ada di SQLite, cari di API
    final remote = await apiService.getProductById(id);
    await localDb.saveProduct(remote);
    return remote;
  }

  @override
  Future<Product> createProduct(Product product) async {
    // 1. Kirim ke Remote API
    final created = await apiService.createProduct(product);

    // 2. Simpan juga ke database SQLite lokal HP
    await localDb.saveProduct(created);
    return created;
  }

  @override
  Future<Product> updateProduct(Product product) async {
    // 1. Update ke Remote API
    final updated = await apiService.updateProduct(product);

    // 2. Update di database SQLite lokal HP
    await localDb.updateProduct(updated);
    return updated;
  }

  @override
  Future<void> deleteProduct(String id) async {
    // 1. Hapus dari SQLite lokal
    await localDb.deleteProduct(id);

    // 2. Hapus dari Remote API
    try {
      await apiService.deleteProduct(id);
    } catch (_) {
      // Abaikan jika remote gagal saat offline
    }
  }

  @override
  Future<void> syncRemoteToLocal() async {
    final remoteData = await apiService.getProducts();
    await localDb.saveProducts(remoteData);
  }
}
