// lib/features/sales/data/repositories/sales_repository.dart
import 'package:eucalysp_insight_app/features/sales/domain/entities/sale.dart';
import 'package:eucalysp_insight_app/features/sales/domain/entities/sale_item.dart';

abstract class SalesRepository {
  Future<List<Sale>> fetchSales(String businessId);
  Future<void> addSale(Sale sale);
  Future<void> updateSale(Sale sale);
  Future<void> deleteSale(String saleId);
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
        paymentStatus: 'Paid',
        notes: 'Delivered to office',
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
        paymentStatus: 'Pending',
        notes: 'Delivered to office',
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
        paymentStatus: 'failed',
        notes: 'Payment failed',
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
        paymentStatus: 'Paid',
        notes: 'Recieved payment in cash',
      ),
    ],
  };

  @override
  Future<List<Sale>> fetchSales(String businessId) async {
    print('[SalesRepository] Fetching sales for business: $businessId');
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    // REMOVED/COMMENTED OUT THE ERROR SIMULATION LINE BELOW
    // if (DateTime.now().second % 5 == 0) {
    //   throw Exception('Failed to fetch sales: Network error');
    // }
    final sales =
        _salesByBusiness[businessId]
            ?.map(
              (sale) => Sale(
                id: sale.id,
                businessId: sale.businessId,
                saleDate: sale.saleDate,
                customerName: sale.customerName,
                totalAmount: sale.totalAmount,
                items: List<SaleItem>.from(sale.items),
                paymentStatus: sale.paymentStatus,
                notes: sale.notes,
              ),
            )
            .toList() ??
        [];
    print(
      '[SalesRepository] Found ${sales.length} sales for business: $businessId',
    );
    return sales;
  }

  @override
  Future<void> addSale(Sale sale) async {
    print('[SalesRepository] Adding sale: ${sale.id}'); // Added for clarity
    await Future.delayed(const Duration(seconds: 1));
    // REMOVED/COMMENTED OUT THE ERROR SIMULATION LINE BELOW
    // if (DateTime.now().second % 5 == 0) {
    //   throw Exception('Failed to add sale: Server unavailable');
    // }
    _salesByBusiness.putIfAbsent(sale.businessId, () => []).add(sale);
    print('[SalesRepository] Sale added: ${sale.id}'); // Added for clarity
  }

  @override
  Future<void> updateSale(Sale sale) async {
    print('[SalesRepository] Updating sale: ${sale.id}'); // Added for clarity
    await Future.delayed(const Duration(seconds: 1));
    // REMOVED/COMMENTED OUT THE ERROR SIMULATION LINE BELOW
    // if (DateTime.now().second % 5 == 0) {
    //   throw Exception('Failed to update sale: Version conflict');
    // }
    final sales = _salesByBusiness[sale.businessId];
    if (sales != null) {
      final index = sales.indexWhere((s) => s.id == sale.id);
      if (index != -1) sales[index] = sale;
      print('[SalesRepository] Sale updated: ${sale.id}'); // Added for clarity
    } else {
      print(
        '[SalesRepository] Sale not found for update: ${sale.id}',
      ); // Added for clarity
    }
  }

  @override
  Future<void> deleteSale(String saleId) async {
    print('[SalesRepository] Deleting sale: $saleId'); // Added for clarity
    await Future.delayed(const Duration(seconds: 1));
    // REMOVED/COMMENTED OUT THE ERROR SIMULATION LINE BELOW
    // if (DateTime.now().second % 5 == 0) {
    //   throw Exception('Failed to delete sale: Permission denied');
    // }
    _salesByBusiness.forEach(
      (_, sales) => sales.removeWhere((s) => s.id == saleId),
    );
    print('[SalesRepository] Sale deleted: $saleId'); // Added for clarity
  }
}
