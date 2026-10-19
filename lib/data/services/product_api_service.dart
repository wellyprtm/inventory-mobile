import '../models/product.dart';

/// Abstract API Service Contract
abstract class ProductApiService {
  Future<List<Product>> getProducts({String? search, String? category});
  Future<Product> getProductById(String id);
  Future<Product> createProduct(Product product);
  Future<Product> updateProduct(Product product);
  Future<void> deleteProduct(String id);
}
