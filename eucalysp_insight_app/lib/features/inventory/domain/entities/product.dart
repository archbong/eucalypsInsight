// lib/features/inventory/domain/entities/product.dart
import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String businessId; // To link product to a specific business
  final String name;
  final String sku; // Stock Keeping Unit
  final String description;
  final int quantity; // Current stock quantity
  final double price;

  const Product({
    required this.id,
    required this.businessId,
    required this.name,
    required this.sku,
    required this.description,
    required this.quantity,
    required this.price,
  });

  // Factory constructor for creating a Product from a map (e.g., from JSON)
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      name: json['name'] as String,
      sku: json['sku'] as String,
      description: json['description'] as String,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
    );
  }

  // Method for converting a Product to a map (e.g., for JSON serialization)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'businessId': businessId,
      'name': name,
      'sku': sku,
      'description': description,
      'quantity': quantity,
      'price': price,
    };
  }

  // Method to create a copy with updated fields
  Product copyWith({
    String? id,
    String? businessId,
    String? name,
    String? sku,
    String? description,
    int? quantity,
    double? price,
  }) {
    return Product(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
    );
  }

  @override
  List<Object?> get props => [
    id,
    businessId,
    name,
    sku,
    description,
    quantity,
    price,
  ];
}
