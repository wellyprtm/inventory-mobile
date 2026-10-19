import '../models/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts({String? search, String? category});
  Future<Product> getProductById(String id);
  Future<Product> createProduct(Product product);
  Future<Product> updateProduct(Product product);
  Future<void> deleteProduct(String id);
}
