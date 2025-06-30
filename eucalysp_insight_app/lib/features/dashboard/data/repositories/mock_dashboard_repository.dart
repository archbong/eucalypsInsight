// lib/features/dashboard/data/repositories/mock_dashboard_repository.dart
// Remove the local Transaction class, as it's now a separate entity file.
// import 'package:eucalysp_insight_app/features/dashboard/data/models/dashboard_data.dart'; // Use domain entities instead of data/models
import 'package:eucalysp_insight_app/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:eucalysp_insight_app/features/dashboard/domain/entities/dashboard_data.dart'; // NEW import
import 'package:eucalysp_insight_app/features/dashboard/domain/entities/transaction.dart'; // NEW import

// Remove the local Transaction class here, it's now in entities/transaction.dart

class MockDashboardRepository implements DashboardRepository {
  @override
  // Implement the correct signature: fetchDashboardSummary with businessId
  Future<DashboardData> fetchDashboardSummary(String businessId) async {
    // Simulate a network delay
    await Future.delayed(const Duration(seconds: 2));

    // Return mock data that depends on the businessId
    // You can customize this logic further for each business
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
              id: 'tr1-A',
              amount: 1200.0,
              date: DateTime.now().subtract(const Duration(hours: 1)),
              description: 'SaaS Subscription',
            ),
            Transaction(
              id: 'tr2-A',
              amount: 50.0,
              date: DateTime.now().subtract(const Duration(hours: 3)),
              description: 'Consultation Fee',
            ),
          ],
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
        );
      default:
        // Fallback for unknown businessId
        return DashboardData(
          welcomeMessage: "Welcome, Generic Business!",
          totalSales: 0,
          totalCustomers: 0,
          totalInventory: 0,
          recentActivities: const ["No activities for this business."],
          recentTransactions: const [],
        );
    }
  }
}
