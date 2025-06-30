// lib/features/inventory/data/repositories/inventory_repository.dart
import 'package:eucalysp_insight_app/features/inventory/domain/entities/product.dart';

abstract class InventoryRepository {
  Future<List<Product>> fetchProducts(String businessId);
  Future<void> addProduct(Product product); // For future "add product" feature
  Future<void> updateProduct(
    Product product,
  ); // For future "edit product" feature
  Future<void> deleteProduct(
    String productId,
  ); // For future "delete product" feature
}

class MockInventoryRepository implements InventoryRepository {
  // A simple in-memory store for mock data
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
      ),
      Product(
        id: 'p102',
        businessId: 'biz1',
        name: 'Wireless Mouse',
        sku: 'WM-005',
        description: 'Ergonomic design',
        quantity: 200,
        price: 25.00,
      ),
      Product(
        id: 'p103',
        businessId: 'biz1',
        name: 'External SSD 1TB',
        sku: 'SSD-1T',
        description: 'Fast portable storage',
        quantity: 80,
        price: 150.00,
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
      ),
      Product(
        id: 'p202',
        businessId: 'biz2',
        name: 'Handcrafted Soap',
        sku: 'HS-LVN',
        description: 'Lavender scented',
        quantity: 150,
        price: 7.50,
      ),
    ],
    'biz3': [
      Product(
        id: 'p301',
        businessId: 'biz3',
        name: 'Delivery Drone V3',
        sku: 'DD-V3',
        description: 'Autonomous delivery vehicle',
        quantity: 10,
        price: 5000.00,
      ),
    ],
  };

  @override
  Future<List<Product>> fetchProducts(String businessId) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    return _productsByBusiness[businessId] ??
        []; // Return products for the given businessId
  }

  @override
  Future<void> addProduct(Product product) async {
    await Future.delayed(const Duration(seconds: 1));
    _productsByBusiness.putIfAbsent(product.businessId, () => []).add(product);
  }

  @override
  Future<void> updateProduct(Product product) async {
    await Future.delayed(const Duration(seconds: 1));
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
    await Future.delayed(const Duration(seconds: 1));
    // This simplified mock removes product from ALL businesses,
    // in real app, you'd delete from specific business's list.
    _productsByBusiness.forEach((key, value) {
      value.removeWhere((p) => p.id == productId);
    });
  }
}
