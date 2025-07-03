// lib/features/dashboard/domain/models/dashboard_data.dart (Example of updated file)
import 'package:fl_chart/fl_chart.dart'; // Import for FlSpot

/// Represents the comprehensive data displayed on the dashboard.
class DashboardData {
  final String welcomeMessage;
  final double totalSales;
  final int totalCustomers;
  final int totalInventory;
  final List<String> recentActivities;
  final List<Transaction> recentTransactions;
  final List<FlSpot>? mainChartData; // Data for the main performance chart
  final List<double>?
  salesChartData; // Data for sales mini-chart in metric card
  final List<double>?
  customerChartData; // Data for customer mini-chart in metric card
  final List<double>?
  inventoryChartData; // Data for inventory mini-chart in metric card

  DashboardData({
    required this.welcomeMessage,
    required this.totalSales,
    required this.totalCustomers,
    required this.totalInventory,
    required this.recentActivities,
    required this.recentTransactions,
    this.mainChartData,
    this.salesChartData,
    this.customerChartData,
    this.inventoryChartData,
  });

  // A dummy factory constructor for quick testing (remove in production)
  factory DashboardData.dummy() {
    return DashboardData(
      welcomeMessage: 'Welcome back, Alex!',
      totalSales: 25489.75,
      totalCustomers: 345,
      totalInventory: 1230,
      recentActivities: [
        'Processed order #1001 for \$250.00',
        'New product "Wireless Headset" added to inventory',
        'Customer support ticket #045 resolved',
        'Marketing campaign "Summer Sale" launched',
      ],
      recentTransactions: [
        Transaction(
          id: 'TXN789',
          amount: 150.75,
          description: 'Online Store Purchase',
          date: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
        Transaction(
          id: 'TXN788',
          amount: 49.99,
          description: 'Retail Store Sale',
          date: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        Transaction(
          id: 'TXN787',
          amount: 320.00,
          description: 'Wholesale Order',
          date: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ],
      mainChartData: const [
        // Example data for main chart
        FlSpot(0, 2),
        FlSpot(1, 1.5),
        FlSpot(2, 3),
        FlSpot(3, 2.5),
        FlSpot(4, 4.2),
      ],
      salesChartData: const [
        10.0,
        12.0,
        11.5,
        13.0,
        12.5,
        14.0,
        13.5,
      ], // Example mini-chart data
      customerChartData: const [5.0, 5.2, 5.5, 5.3, 5.8, 6.0, 5.7],
      inventoryChartData: const [20.0, 19.5, 21.0, 20.5, 22.0, 21.5, 23.0],
    );
  }
}

// Assuming your existing Transaction model looks something like this:
class Transaction {
  final String id;
  final double amount;
  final String description;
  final DateTime date;

  Transaction({
    required this.id,
    required this.amount,
    required this.description,
    required this.date,
  });
}
