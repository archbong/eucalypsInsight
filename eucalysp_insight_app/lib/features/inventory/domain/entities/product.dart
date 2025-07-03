// lib/features/inventory/domain/entities/product.dart
import 'package:eucalysp_insight_app/features/inventory/domain/entities/variant.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

part 'product.g.dart'; // This file will be generated

@HiveType(typeId: 0) // Unique type ID for Product
class Product {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String businessId;
  @HiveField(2)
  final String name;
  @HiveField(3)
  final String sku;
  @HiveField(4)
  final String description;
  @HiveField(5)
  final int quantity;
  @HiveField(6)
  final double price;
  @HiveField(7)
  final String? category;
  @HiveField(8)
  final List<Variant>? variants;
  @HiveField(9)
  final int lowStockThreshold;
  const Product({
    required this.id,
    required this.businessId,
    required this.name,
    required this.sku,
    required this.description,
    required this.quantity,
    required this.price,
    this.category,
    this.variants = const [],
    this.lowStockThreshold = 10,
  });

  double get totalValue => price * quantity;
  bool get isLowStock => quantity <= lowStockThreshold;

  static Map<String, double> groupByCategory(List<Product> products) {
    final Map<String, double> categorySales = {};
    for (final product in products) {
      final category = product.category ?? 'Uncategorized';
      categorySales[category] =
          (categorySales[category] ?? 0) + product.totalValue;
    }
    return categorySales;
  }

  // Add copyWith method if you don't have it already
  Product copyWith({
    String? id,
    String? businessId,
    String? name,
    String? sku,
    String? description,
    int? quantity,
    double? price,
    String? category,
  }) {
    return Product(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      category: category ?? this.category,
    );
  }
}
