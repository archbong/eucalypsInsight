// lib/features/sales/data/repositories/sales_repository.dart
import 'package:eucalysp_insight_app/features/sales/domain/entities/sale.dart';
import 'package:eucalysp_insight_app/features/sales/domain/entities/sale_item.dart';

abstract class SalesRepository {
  Future<List<Sale>> fetchSales(String businessId);
  Future<void> addSale(Sale sale); // For future "add sale" feature
}

class MockSalesRepository implements SalesRepository {
  // A simple in-memory store for mock sales data
  final Map<String, List<Sale>> _salesByBusiness = {
    'biz1': [
      Sale(
        id: 'sale1001',
        businessId: 'biz1',
        saleDate: DateTime(2025, 6, 25, 10, 30),
        customerName: 'Alice Johnson',
        totalAmount: 1225.00,
        items: [
          SaleItem(
            productId: 'p101',
            productName: 'Laptop Pro',
            quantity: 1,
            unitPrice: 1200.00,
            subtotal: 1200.00,
          ),
          SaleItem(
            productId: 'p102',
            productName: 'Wireless Mouse',
            quantity: 1,
            unitPrice: 25.00,
            subtotal: 25.00,
          ),
        ],
      ),
      Sale(
        id: 'sale1002',
        businessId: 'biz1',
        saleDate: DateTime(2025, 6, 24, 14, 0),
        customerName: 'Bob Williams',
        totalAmount: 300.00,
        items: [
          SaleItem(
            productId: 'p103',
            productName: 'External SSD 1TB',
            quantity: 2,
            unitPrice: 150.00,
            subtotal: 300.00,
          ),
        ],
      ),
    ],
    'biz2': [
      Sale(
        id: 'sale2001',
        businessId: 'biz2',
        saleDate: DateTime(2025, 6, 26, 9, 0),
        customerName: 'Charlie Brown',
        totalAmount: 31.98,
        items: [
          SaleItem(
            productId: 'p201',
            productName: 'Organic Coffee Beans',
            quantity: 2,
            unitPrice: 15.99,
            subtotal: 31.98,
          ),
        ],
      ),
    ],
    'biz3': [
      Sale(
        id: 'sale3001',
        businessId: 'biz3',
        saleDate: DateTime(2025, 6, 27, 11, 45),
        customerName: 'Diana Prince',
        totalAmount: 5000.00,
        items: [
          SaleItem(
            productId: 'p301',
            productName: 'Delivery Drone V3',
            quantity: 1,
            unitPrice: 5000.00,
            subtotal: 5000.00,
          ),
        ],
      ),
    ],
  };

  @override
  Future<List<Sale>> fetchSales(String businessId) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    // Return a deep copy to prevent external modifications to the mock data
    return _salesByBusiness[businessId]
            ?.map(
              (sale) => Sale(
                id: sale.id,
                businessId: sale.businessId,
                saleDate: sale.saleDate,
                customerName: sale.customerName,
                totalAmount: sale.totalAmount,
                items: List<SaleItem>.from(
                  sale.items,
                ), // Deep copy items if they were mutable
              ),
            )
            .toList() ??
        [];
  }

  @override
  Future<void> addSale(Sale sale) async {
    await Future.delayed(const Duration(seconds: 1));
    _salesByBusiness.putIfAbsent(sale.businessId, () => []).add(sale);
  }
}
