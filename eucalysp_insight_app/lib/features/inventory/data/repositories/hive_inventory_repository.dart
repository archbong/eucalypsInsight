// lib/features/inventory/data/repositories/hive_inventory_repository.dart

import 'package:eucalysp_insight_app/features/inventory/data/repositories/inventory_repository.dart';
import 'package:eucalysp_insight_app/features/inventory/domain/entities/product.dart';
import 'package:eucalysp_insight_app/features/inventory/domain/entities/variant.dart';
import 'package:hive/hive.dart';

class HiveInventoryRepository implements InventoryRepository {
  static const String _boxName =
      'products'; // Make sure this matches the box name used in HiveService if you kept it
  late final Box<Product>
  _box; // This will be initialized exactly once by the init() method
  bool _isInitialized = false;

  HiveInventoryRepository();

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(VariantAdapter());
    }
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ProductAdapter());
    }
    _box = await Hive.openBox<Product>(_boxName);
    _isInitialized = true;
  }

  @override
  Future<List<Product>> fetchProducts(
    String businessId, {
    int page = 1,
    int limit = 20,
  }) async {
    if (!_isInitialized)
      throw Exception('HiveInventoryRepository not initialized');
    final allProducts = _box.values
        .where((p) => p.businessId == businessId)
        .toList();
    final startIndex = (page - 1) * limit;
    final endIndex = startIndex + limit;
    return allProducts.sublist(
      startIndex.clamp(0, allProducts.length),
      endIndex.clamp(0, allProducts.length),
    );
  }

  @override
  Future<void> addProduct(Product product) async {
    if (!_isInitialized)
      throw Exception('HiveInventoryRepository not initialized');
    await _box.put(product.id, product);
  }

  @override
  Future<void> updateProduct(Product product) async {
    if (!_isInitialized)
      throw Exception('HiveInventoryRepository not initialized');
    await _box.put(product.id, product);
  }

  @override
  Future<void> deleteProduct(String productId) async {
    if (!_isInitialized)
      throw Exception('HiveInventoryRepository not initialized');
    await _box.delete(productId);
  }

  @override
  Future<void> updateProductPartial(
    String productId, {
    double? price,
    int? quantity,
  }) async {
    if (!_isInitialized)
      throw Exception('HiveInventoryRepository not initialized');
    final existingProduct = _box.get(productId);
    if (existingProduct != null) {
      final updatedProduct = existingProduct.copyWith(
        price: price ?? existingProduct.price,
        quantity: quantity ?? existingProduct.quantity,
      );
      await _box.put(productId, updatedProduct);
    } else {
      throw Exception(
        'Product with ID $productId not found in Hive for partial update.',
      );
    }
  }

  // NEW METHOD: Implement method to get products directly from Hive (offline cache)
  @override
  Future<List<Product>> getOfflineProducts(String businessId) async {
    if (!_isInitialized)
      throw Exception('HiveInventoryRepository not initialized');
    return _box.values.where((p) => p.businessId == businessId).toList();
  }

  // NEW METHOD: Implement method to save/sync products to Hive (cache)
  @override
  Future<void> saveProductsToCache(List<Product> products) async {
    if (!_isInitialized)
      throw Exception('HiveInventoryRepository not initialized');
    await _box.clear(); // Clear all currently cached products
    for (final product in products) {
      await _box.put(
        product.id,
        product,
      ); // Add all products from the fresh fetch
    }
  }
}
