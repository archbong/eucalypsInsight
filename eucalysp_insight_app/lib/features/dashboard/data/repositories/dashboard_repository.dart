// lib/features/dashboard/domain/repositories/dashboard_repository.dart

import 'package:eucalysp_insight_app/features/dashboard/domain/entities/dashboard_data.dart';

abstract class DashboardRepository {
  // Now returns DashboardData and accepts businessId
  Future<DashboardData> fetchDashboardSummary(String businessId);
}
