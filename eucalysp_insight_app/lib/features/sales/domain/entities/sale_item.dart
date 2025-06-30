// lib/features/sales/domain/entities/sale_item.dart
import 'package:equatable/equatable.dart';

class SaleItem extends Equatable {
  final String productId; // ID of the product sold
  final String productName; // Name of the product sold (for display)
  final int quantity;
  final double unitPrice;
  final double subtotal;

  const SaleItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    return SaleItem(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      quantity: json['quantity'] as int,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'subtotal': subtotal,
    };
  }

  @override
  List<Object?> get props => [
    productId,
    productName,
    quantity,
    unitPrice,
    subtotal,
  ];
}
