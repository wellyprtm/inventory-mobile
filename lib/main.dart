import 'package:flutter/material.dart';
import 'app.dart';
import 'data/local/product_database_helper.dart';
import 'data/repositories/product_repository_impl.dart';
import 'data/services/http_product_api_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inisialisasi Data Sources:
  // - Remote Data Source: Fetch API via HTTP
  final apiService = HttpProductApiService();

  // - Local Data Source: SQLite Database di HP
  final localDb = ProductDatabaseHelper.instance;

  // 2. Repository Pattern (Menggabungkan Remote API + Local SQLite Cache)
  final repository = ProductRepositoryImpl(
    apiService: apiService,
    localDb: localDb,
  );

  // 3. Launch App
  runApp(InventoryApp(repository: repository));
}
