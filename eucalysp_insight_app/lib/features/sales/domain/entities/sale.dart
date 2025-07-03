// lib/features/sales/domain/entities/sale.dart
import 'package:equatable/equatable.dart';
import 'package:eucalysp_insight_app/features/sales/domain/entities/sale_item.dart';
import 'package:intl/intl.dart';

class Sale extends Equatable {
  final String id;
  final String businessId;
  final DateTime saleDate;
  final String customerName;
  final double totalAmount;
  final List<SaleItem> items;
  final String paymentStatus;
  final String notes;

  const Sale({
    required this.id,
    required this.businessId,
    required this.saleDate,
    required this.customerName,
    required this.totalAmount,
    required this.items,
    required this.paymentStatus,
    required this.notes,
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
      paymentStatus:
          json['paymentStatus'] as String? ??
          'Pending', // Default to 'Pending' if missing
      notes: json['notes'] as String? ?? '',
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
      'paymentStatus': paymentStatus,
      'notes': notes,
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
    paymentStatus,
    notes,
  ];

  static Map<String, double> calculateMonthlyTrends(List<Sale> sales) {
    final Map<String, double> monthlySales = {};
    for (final sale in sales) {
      final month = DateFormat('MMM').format(sale.saleDate);
      monthlySales[month] = (monthlySales[month] ?? 0) + sale.totalAmount;
    }
    return monthlySales;
  }

  static Map<String, double> calculateTopProducts(List<Sale> sales) {
    final Map<String, double> productSales = {};
    for (final sale in sales) {
      for (final item in sale.items) {
        productSales[item.productName] =
            (productSales[item.productName] ?? 0) + item.subtotal;
      }
    }
    return productSales;
  }

  Sale copyWith({
    String? id,
    String? businessId,
    DateTime? saleDate,
    String? customerName,
    double? totalAmount,
    List<SaleItem>? items,
    String? paymentStatus,
    String? notes,
  }) {
    return Sale(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      saleDate: saleDate ?? this.saleDate,
      customerName: customerName ?? this.customerName,
      totalAmount: totalAmount ?? this.totalAmount,
      items: items ?? List.from(this.items),
      paymentStatus: paymentStatus ?? this.paymentStatus,
      notes: notes ?? this.notes,
    );
  }
}
