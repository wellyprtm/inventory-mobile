import 'package:flutter/material.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/product_repository.dart';
import 'ui/product_list/product_list_view.dart';
import 'ui/product_list/product_list_view_model.dart';

class InventoryApp extends StatelessWidget {
  final ProductRepository repository;

  const InventoryApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: ProductListView(
        viewModel: ProductListViewModel(repository: repository),
      ),
    );
  }
}
