// lib/features/inventory/utils/hive_service.dart
import 'package:hive/hive.dart';
import 'package:eucalysp_insight_app/features/inventory/domain/entities/product.dart';

class HiveService {
  static const String _productBoxName = 'products';

  static Future<void> init() async {
    await Hive.openBox<Product>(_productBoxName);
  }

  static Future<void> saveProducts(List<Product> products) async {
    final box = Hive.box<Product>(_productBoxName);
    await box.clear();
    for (final product in products) {
      await box.put(product.id, product);
    }
  }

  static Future<List<Product>> getProducts() async {
    final box = Hive.box<Product>(_productBoxName);
    return box.values.toList();
  }

  static Future<void> addProduct(Product product) async {
    final box = Hive.box<Product>(_productBoxName);
    await box.put(product.id, product);
  }

  static Future<void> updateProduct(Product product) async {
    final box = Hive.box<Product>(_productBoxName);
    await box.put(product.id, product);
  }

  static Future<void> deleteProduct(String productId) async {
    final box = Hive.box<Product>(_productBoxName);
    await box.delete(productId);
  }

  static Future<void> clearProducts() async {
    final box = Hive.box<Product>(_productBoxName);
    await box.clear();
  }
}
