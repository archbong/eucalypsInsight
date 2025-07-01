// lib/features/inventory/domain/entities/product.dart
import 'package:hive/hive.dart';

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
  final String? category; // Ensure this also has a field ID

  const Product({
    required this.id,
    required this.businessId,
    required this.name,
    required this.sku,
    required this.description,
    required this.quantity,
    required this.price,
    this.category,
  });

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
