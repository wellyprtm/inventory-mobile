import '../models/product.dart';

enum DataSourceMode {
  autoSync,   // Coba API, lalu cache ke SQLite (fallback ke SQLite jika offline)
  apiOnly,    // Langsung tembak Remote API
  localSqlite // Murni dari database SQLite di memori HP
}

abstract class ProductRepository {
  Future<List<Product>> getProducts({
    String? search,
    String? category,
    DataSourceMode mode = DataSourceMode.autoSync,
  });
  Future<Product> getProductById(String id);
  Future<Product> createProduct(Product product);
  Future<Product> updateProduct(Product product);
  Future<void> deleteProduct(String id);
  Future<void> syncRemoteToLocal();
}
