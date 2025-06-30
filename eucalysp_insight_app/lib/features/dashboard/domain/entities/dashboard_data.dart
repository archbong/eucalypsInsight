// lib/features/dashboard/domain/entities/dashboard_data.dart
import 'package:equatable/equatable.dart';
import 'package:eucalysp_insight_app/features/dashboard/domain/entities/transaction.dart';

class DashboardData extends Equatable {
  final String welcomeMessage;
  final int totalSales;
  final int totalCustomers;
  final int totalInventory; // New field from your mock
  final List<String> recentActivities; // Keep this for now, or replace with List<Transaction> if preferred
  final List<Transaction> recentTransactions; // New field from your mock

  const DashboardData({
    required this.welcomeMessage,
    required this.totalSales,
    required this.totalCustomers,
    required this.totalInventory,
    required this.recentActivities,
    required this.recentTransactions,
  });

  @override
  List<Object?> get props => [
        welcomeMessage,
        totalSales,
        totalCustomers,
        totalInventory,
        recentActivities,
        recentTransactions,
      ];
}