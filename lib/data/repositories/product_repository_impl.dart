import '../models/product.dart';
import '../services/product_api_service.dart';
import 'product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductApiService apiService;

  ProductRepositoryImpl({required this.apiService});

  @override
  Future<List<Product>> getProducts({String? search, String? category}) {
    return apiService.getProducts(search: search, category: category);
  }

  @override
  Future<Product> getProductById(String id) {
    return apiService.getProductById(id);
  }

  @override
  Future<Product> createProduct(Product product) {
    return apiService.createProduct(product);
  }

  @override
  Future<Product> updateProduct(Product product) {
    return apiService.updateProduct(product);
  }

  @override
  Future<void> deleteProduct(String id) {
    return apiService.deleteProduct(id);
  }
}
