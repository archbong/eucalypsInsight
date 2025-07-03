// lib/features/dashboard/data/repositories/mock_dashboard_repository.dart

// 1. Ensure NO import from data/models/dashboard_data.dart exists here.
//    The line below should NOT be present or should be commented out:
// // import 'package:eucalysp_insight_app/features/dashboard/data/models/dashboard_data.dart'; // This line is problematic if still active

import 'package:eucalysp_insight_app/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:eucalysp_insight_app/features/dashboard/domain/entities/transaction.dart'
    hide Transaction; // Canonical Transaction
import 'package:eucalysp_insight_app/features/dashboard/domain/models/dashboard_data.dart';
import 'package:fl_chart/fl_chart.dart'; // For FlSpot

// Remove any local Transaction class here, it's now in entities/transaction.dart
// (Confirm there isn't a 'class Transaction { ... }' definition directly in this file)

class MockDashboardRepository implements DashboardRepository {
  @override
  Future<DashboardData> fetchDashboardSummary(String businessId) async {
    await Future.delayed(const Duration(seconds: 2));

    const List<FlSpot> commonMainChartData = [
      FlSpot(0, 2),
      FlSpot(1, 1.8),
      FlSpot(2, 2.5),
      FlSpot(3, 2.2),
      FlSpot(4, 3.0),
      FlSpot(5, 2.7),
      FlSpot(6, 3.5),
    ];
    const List<double> commonSalesChartData = [
      10.0,
      12.0,
      11.5,
      13.0,
      12.5,
      14.0,
      13.5,
    ];
    const List<double> commonCustomerChartData = [
      5.0,
      5.2,
      5.5,
      5.3,
      5.8,
      6.0,
      5.7,
    ];
    const List<double> commonInventoryChartData = [
      20.0,
      19.5,
      21.0,
      20.5,
      22.0,
      21.5,
      23.0,
    ];

    switch (businessId) {
      case 'biz1':
        return DashboardData(
          welcomeMessage: "Welcome, Alpha Solutions!",
          totalSales: 100000,
          totalCustomers: 1200,
          totalInventory: 500,
          recentActivities: const [
            "Alpha: New SaaS subscription added.",
            "Alpha: Support ticket #789 resolved.",
            "Alpha: Quarterly report generated.",
          ],
          recentTransactions: [
            Transaction(
              // This is the Transaction being called
              id: 'tr1-A',
              amount: 1200.0,
              date: DateTime.now().subtract(const Duration(hours: 1)),
              description: 'SaaS Subscription',
            ),
            Transaction(
              // This is the Transaction being called
              id: 'tr2-A',
              amount: 50.0,
              date: DateTime.now().subtract(const Duration(hours: 3)),
              description: 'Consultation Fee',
            ),
          ],
          mainChartData: commonMainChartData,
          salesChartData: commonSalesChartData,
          customerChartData: commonCustomerChartData,
          inventoryChartData: commonInventoryChartData,
        );
      case 'biz2':
        return DashboardData(
          welcomeMessage: "Welcome, Beta Retail Stores!",
          totalSales: 50000,
          totalCustomers: 600,
          totalInventory: 1200,
          recentActivities: const [
            "Beta: New product line received.",
            "Beta: Daily sales reconciled.",
            "Beta: Loyalty program update.",
          ],
          recentTransactions: [
            Transaction(
              id: 'tr1-B',
              amount: 150.0,
              date: DateTime.now().subtract(const Duration(hours: 2)),
              description: 'Retail Sale',
            ),
            Transaction(
              id: 'tr2-B',
              amount: 300.0,
              date: DateTime.now().subtract(const Duration(hours: 5)),
              description: 'Wholesale Order',
            ),
          ],
          mainChartData: const [
            FlSpot(0, 1.5),
            FlSpot(1, 1.2),
            FlSpot(2, 1.8),
            FlSpot(3, 1.4),
            FlSpot(4, 2.0),
            FlSpot(5, 1.7),
            FlSpot(6, 2.3),
          ],
          salesChartData: const [8.0, 9.0, 8.5, 9.5, 9.0, 10.0, 9.8],
          customerChartData: commonCustomerChartData,
          inventoryChartData: commonInventoryChartData,
        );
      case 'biz3':
        return DashboardData(
          welcomeMessage: "Welcome, Gamma Logistics Ltd.!",
          totalSales: 25000,
          totalCustomers: 300,
          totalInventory: 200,
          recentActivities: const [
            "Gamma: Shipments dispatched.",
            "Gamma: Route optimization completed.",
            "Gamma: New client onboarding.",
          ],
          recentTransactions: [
            Transaction(
              id: 'tr1-G',
              amount: 800.0,
              date: DateTime.now().subtract(const Duration(hours: 4)),
              description: 'Shipping Fee',
            ),
            Transaction(
              id: 'tr2-G',
              amount: 120.0,
              date: DateTime.now().subtract(const Duration(hours: 6)),
              description: 'Customs Duty',
            ),
          ],
          mainChartData: const [
            FlSpot(0, 0.5),
            FlSpot(1, 0.7),
            FlSpot(2, 0.6),
            FlSpot(3, 0.9),
            FlSpot(4, 0.8),
            FlSpot(5, 1.1),
            FlSpot(6, 1.0),
          ],
          salesChartData: const [5.0, 6.0, 5.5, 6.5, 6.0, 7.0, 6.8],
          customerChartData: commonCustomerChartData,
          inventoryChartData: commonInventoryChartData,
        );
      default:
        return DashboardData(
          welcomeMessage: "Welcome, Generic Business!",
          totalSales: 0,
          totalCustomers: 0,
          totalInventory: 0,
          recentActivities: const ["No activities for this business."],
          recentTransactions: const [],
          mainChartData: const [],
          salesChartData: const [],
          customerChartData: const [],
          inventoryChartData: const [],
        );
    }
  }
}
