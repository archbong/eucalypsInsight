// lib/features/sales/domain/entities/sale.dart
import 'package:equatable/equatable.dart';
import 'package:eucalysp_insight_app/features/sales/domain/entities/sale_item.dart';

class Sale extends Equatable {
  final String id;
  final String businessId; // To link sale to a specific business
  final DateTime saleDate;
  final String customerName;
  final double totalAmount;
  final List<SaleItem> items;

  const Sale({
    required this.id,
    required this.businessId,
    required this.saleDate,
    required this.customerName,
    required this.totalAmount,
    required this.items,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      saleDate: DateTime.parse(json['saleDate'] as String),
      customerName: json['customerName'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      items: (json['items'] as List)
          .map(
            (itemJson) => SaleItem.fromJson(itemJson as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'businessId': businessId,
      'saleDate': saleDate.toIso8601String(),
      'customerName': customerName,
      'totalAmount': totalAmount,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    businessId,
    saleDate,
    customerName,
    totalAmount,
    items,
  ];
}
