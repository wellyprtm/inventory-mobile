import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import 'product_api_service.dart';

/// Real HTTP implementation of ProductApiService using package:http.
/// Communicates with a remote REST API backend.
class HttpProductApiService implements ProductApiService {
  final String baseUrl;
  final http.Client client;

  HttpProductApiService({
    this.baseUrl = 'https://jsonplaceholder.typicode.com',
    http.Client? client,
  }) : client = client ?? http.Client();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  @override
  Future<List<Product>> getProducts({String? search, String? category}) async {
    try {
      final uri = Uri.parse('$baseUrl/posts');
      final response = await client.get(uri, headers: _headers).timeout(
            const Duration(seconds: 8),
          );

      if (response.statusCode == 200) {
        final List list = jsonDecode(response.body);

        // Map remote JSON placeholder posts to Product domain format
        var products = list.take(15).map((item) {
          final id = 'PRD-${item['id']}';
          final title = item['title'] as String? ?? 'Item';
          final body = item['body'] as String? ?? '';
          final intId = item['id'] as int? ?? 1;

          // Assign realistic prices & categories based on remote ID
          final categories = ['Elektronik', 'Aksesoris', 'Furnitur', 'Lainnya'];
          final assignedCat = categories[intId % categories.length];
          final price = (intId * 250000.0) + 150000.0;
          final stock = (intId * 3) % 40 + 2;

          return Product(
            id: id,
            name: title.length > 30 ? '${title.substring(0, 30)}...' : title,
            category: assignedCat,
            price: price,
            stock: stock,
            description: body,
            updatedAt: DateTime.now().subtract(Duration(hours: intId * 2)),
          );
        }).toList();

        if (search != null && search.trim().isNotEmpty) {
          final q = search.toLowerCase();
          products = products.where((p) => p.name.toLowerCase().contains(q) || p.description.toLowerCase().contains(q)).toList();
        }

        if (category != null && category.isNotEmpty && category != 'Semua') {
          products = products.where((p) => p.category == category).toList();
        }

        return products;
      } else {
        throw Exception('API Server Error (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Gagal menghubungi Remote API: $e');
    }
  }

  @override
  Future<Product> getProductById(String id) async {
    final cleanId = id.replaceAll('PRD-', '');
    final uri = Uri.parse('$baseUrl/posts/$cleanId');
    final response = await client.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Product(
        id: id,
        name: json['title'] ?? 'Product $id',
        category: 'Elektronik',
        price: 1500000.0,
        stock: 10,
        description: json['body'] ?? '',
        updatedAt: DateTime.now(),
      );
    } else {
      throw Exception('Produk tidak ditemukan di API (404)');
    }
  }

  @override
  Future<Product> createProduct(Product product) async {
    final uri = Uri.parse('$baseUrl/posts');
    final response = await client.post(
      uri,
      headers: _headers,
      body: jsonEncode({
        'title': product.name,
        'body': product.description,
        'userId': 1,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final newId = product.id.isNotEmpty ? product.id : 'PRD-${data['id'] ?? DateTime.now().millisecondsSinceEpoch % 1000}';
      return product.copyWith(id: newId, updatedAt: DateTime.now());
    } else {
      throw Exception('Gagal membuat data di API');
    }
  }

  @override
  Future<Product> updateProduct(Product product) async {
    final cleanId = product.id.replaceAll('PRD-', '');
    final uri = Uri.parse('$baseUrl/posts/$cleanId');
    final response = await client.put(
      uri,
      headers: _headers,
      body: jsonEncode({
        'title': product.name,
        'body': product.description,
      }),
    );

    if (response.statusCode == 200) {
      return product.copyWith(updatedAt: DateTime.now());
    } else {
      throw Exception('Gagal memperbarui data di API');
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    final cleanId = id.replaceAll('PRD-', '');
    final uri = Uri.parse('$baseUrl/posts/$cleanId');
    final response = await client.delete(uri, headers: _headers);

    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus data di API');
    }
  }
}
