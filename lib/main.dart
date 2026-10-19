import 'package:flutter/material.dart';
import 'app.dart';
import 'data/repositories/product_repository_impl.dart';
import 'data/services/mock_product_api_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Dependency Setup (Service -> Repository)
  final apiService = MockProductApiService();
  final repository = ProductRepositoryImpl(apiService: apiService);

  // 2. Launch Application
  runApp(InventoryApp(repository: repository));
}
