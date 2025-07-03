import 'package:eucalysp_insight_app/features/dashboard/data/repositories/dashboard_repository.dart';

import 'package:eucalysp_insight_app/features/dashboard/domain/models/dashboard_data.dart';
import 'package:eucalysp_insight_app/features/inventory/bloc/inventory_cubit.dart';
import 'package:eucalysp_insight_app/features/inventory/bloc/inventory_state.dart'; // <--- Keep this import for InventoryState
import 'package:eucalysp_insight_app/features/sales/bloc/sales_cubit.dart';
// import 'package:eucalysp_insight_app/features/sales/bloc/sales_state.dart'; // Still not needed here
import 'package:eucalysp_insight_app/features/sales/domain/entities/sale.dart';
import 'package:eucalysp_insight_app/features/inventory/domain/entities/product.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:eucalysp_insight_app/app/core/bloc/business_data_bloc.dart'; // <--- Keep this import for SalesCubit's states

class RealDashboardRepository implements DashboardRepository {
  final SalesCubit _salesCubit;
  final InventoryCubit _inventoryCubit;

  RealDashboardRepository({
    required SalesCubit salesCubit,
    required InventoryCubit inventoryCubit,
  }) : _salesCubit = salesCubit,
       _inventoryCubit = inventoryCubit;

  @override
  Future<DashboardData> fetchDashboardSummary(String businessId) async {
    // Get current sales data
    final salesState = _salesCubit.state;
    // This part is correct, as SalesCubit uses BusinessDataBloc
    final sales = salesState is BusinessDataLoaded<List<Sale>>
        ? salesState.data
        : <Sale>[];

    // Get current inventory data
    final inventoryState = _inventoryCubit.state;
    // FIX: Check for InventoryLoaded and access its 'filteredProducts'
    final inventory = inventoryState is InventoryLoaded
        ? inventoryState
              .filteredProducts // Correctly access filteredProducts
        : <Product>[]; // Default to empty list

    // Calculate totals
    final totalSales = sales.fold(0.0, (sum, sale) => sum + sale.totalAmount);
    final totalInventory = inventory.fold(
      0,
      (int sum, item) => sum + item.quantity,
    );

    // Get recent transactions (last 5 sales)
    final recentTransactions = sales
        .take(5)
        .map(
          (sale) => Transaction(
            id: sale.id,
            amount: sale.totalAmount,
            date: sale.saleDate,
            description: sale.notes ?? 'No description',
          ),
        )
        .toList();

    // Generate chart data
    final now = DateTime.now();
    final mainChartData = List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      final dailySales = sales
          .where(
            (s) =>
                s.saleDate.year == date.year &&
                s.saleDate.month == date.month &&
                s.saleDate.day == date.day,
          )
          .fold(0.0, (sum, sale) => sum + sale.totalAmount);
      return FlSpot(index.toDouble(), dailySales);
    });

    return DashboardData(
      welcomeMessage: "Live Dashboard - $businessId",
      totalSales: totalSales,
      totalCustomers: _calculateUniqueCustomers(sales),
      totalInventory: totalInventory,
      recentActivities: _generateRecentActivities(sales, inventory),
      recentTransactions: recentTransactions,
      mainChartData: mainChartData,
      salesChartData: mainChartData.map((spot) => spot.y).toList(),
      customerChartData: _generateCustomerTrend(sales),
      inventoryChartData: _generateInventoryTrend(inventory),
    );
  }

  int _calculateUniqueCustomers(List<Sale> sales) {
    return sales.map((s) => s.customerName).toSet().length;
  }

  List<String> _generateRecentActivities(
    List<Sale> sales,
    List<Product> inventory,
  ) {
    final activities = <String>[];
    if (sales.isNotEmpty) {
      final latestSale = sales.last;
      activities.add(
        'New sale: \$${latestSale.totalAmount.toStringAsFixed(2)}',
      );
    }
    if (inventory.isNotEmpty) {
      final latestInventory = inventory.last;
      activities.add('Inventory update: ${latestInventory.name}');
    }
    return activities.isNotEmpty ? activities : ['No recent activities'];
  }

  List<double> _generateCustomerTrend(List<Sale> sales) {
    return [5.0, 5.2, 5.5, 5.3, 5.8, 6.0, 5.7]; // Placeholder
  }

  List<double> _generateInventoryTrend(List<Product> inventory) {
    return [20.0, 19.5, 21.0, 20.5, 22.0, 21.5, 23.0]; // Placeholder
  }
}
