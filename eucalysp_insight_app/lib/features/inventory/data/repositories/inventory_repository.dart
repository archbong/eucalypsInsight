// business-app/eucalypsInsight/eucalysp_insight_app/lib/features/inventory/data/repositories/inventory_repository.dart
import 'package:eucalysp_insight_app/features/inventory/domain/entities/product.dart';
import 'package:hive/hive.dart'; // Import Hive for HiveInventoryRepository

abstract class InventoryRepository {
  Future<List<Product>> fetchProducts(String businessId);
  Future<void> addProduct(Product product);
  Future<void> updateProduct(Product product);
  Future<void> deleteProduct(String productId);

  // ADD THIS NEW METHOD SIGNATURE
  Future<void> updateProductPartial(
    String productId, {
    double? price,
    int? quantity,
  });
}

class MockInventoryRepository implements InventoryRepository {
  final Map<String, List<Product>> _productsByBusiness = {
    'biz1': [
      Product(
        id: 'p101',
        businessId: 'biz1',
        name: 'Laptop Pro',
        sku: 'LP-001',
        description: 'High-performance laptop',
        quantity: 50,
        price: 1200.00,
        category: 'Electronics', // Added for better filtering demo
      ),
      Product(
        id: 'p102',
        businessId: 'biz1',
        name: 'Wireless Mouse',
        sku: 'WM-005',
        description: 'Ergonomic design',
        quantity: 200,
        price: 25.00,
        category: 'Electronics', // Added for better filtering demo
      ),
      Product(
        id: 'p103',
        businessId: 'biz1',
        name: 'Office Chair',
        sku: 'OC-010',
        description: 'Ergonomic office chair',
        quantity: 15,
        price: 150.00,
        category: 'Furniture', // Added for better filtering demo
      ),
      Product(
        id: 'p104',
        businessId: 'biz1',
        name: 'Desk Lamp',
        sku: 'DL-001',
        description: 'Adjustable LED lamp',
        quantity: 70,
        price: 45.00,
        category: 'Lighting', // Added for better filtering demo
      ),
      Product(
        id: 'p105',
        businessId: 'biz1',
        name: 'Monitor Stand',
        sku: 'MS-002',
        description: 'Height adjustable stand',
        quantity: 30,
        price: 60.00,
        category: 'Furniture', // Added for better filtering demo
      ),
    ],
    'biz2': [
      Product(
        id: 'p201',
        businessId: 'biz2',
        name: 'Organic Coffee Beans',
        sku: 'OCB-K1',
        description: 'Fair-trade Arabica',
        quantity: 300,
        price: 15.99,
        category: 'Food & Beverage', // Added for better filtering demo
      ),
    ],
  };

  @override
  Future<List<Product>> fetchProducts(String businessId) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    // Simulating network error only if we're not running tests (for better dev experience)
    if (const String.fromEnvironment('FLUTTER_TEST') != 'true' &&
        DateTime.now().second % 5 == 0) {
      throw Exception('Failed to fetch inventory: Network error simulation');
    }
    return _productsByBusiness[businessId] ?? [];
  }

  @override
  Future<void> addProduct(Product product) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Shorter delay
    _productsByBusiness.putIfAbsent(product.businessId, () => []).add(product);
  }

  @override
  Future<void> updateProduct(Product product) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Shorter delay
    final products = _productsByBusiness[product.businessId];
    if (products != null) {
      final index = products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        products[index] = product;
      }
    }
  }

  @override
  Future<void> deleteProduct(String productId) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Shorter delay
    _productsByBusiness.forEach((businessId, products) {
      products.removeWhere((p) => p.id == productId);
    });
  }

  // IMPLEMENT THE NEW METHOD FOR MOCK INVENTORY REPOSITORY
  @override
  Future<void> updateProductPartial(
    String productId, {
    double? price,
    int? quantity,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate delay
    bool found = false;
    _productsByBusiness.forEach((businessId, products) {
      final index = products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        final existingProduct = products[index];
        products[index] = existingProduct.copyWith(
          price: price ?? existingProduct.price,
          quantity: quantity ?? existingProduct.quantity,
        );
        found = true;
      }
    });
    if (!found) {
      throw Exception(
        'Product with ID $productId not found for partial update.',
      );
    }
  }
}

class HiveInventoryRepository implements InventoryRepository {
  static const String _boxName = 'inventory';
  late final Box<Product> _box;

  // You might want to call init from your service locator
  Future<void> init() async {
    // Ensure Hive is initialized globally before opening boxes
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox<Product>(_boxName);
    } else {
      _box = Hive.box<Product>(_boxName);
    }
  }

  @override
  Future<List<Product>> fetchProducts(String businessId) async {
    // In a real Hive implementation, you might filter by businessId if products from multiple businesses are in the same box.
    // Or, you might have separate boxes per business. For now, assuming products can be filtered by businessId.
    return _box.values.where((p) => p.businessId == businessId).toList();
  }

  @override
  Future<void> addProduct(Product product) async {
    await _box.put(product.id, product);
  }

  @override
  Future<void> updateProduct(Product product) async {
    await _box.put(product.id, product);
  }

  @override
  Future<void> deleteProduct(String productId) async {
    await _box.delete(productId);
  }

  // IMPLEMENT THE NEW METHOD FOR HIVE INVENTORY REPOSITORY
  @override
  Future<void> updateProductPartial(
    String productId, {
    double? price,
    int? quantity,
  }) async {
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
}
