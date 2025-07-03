// lib/features/dashboard/bloc/dashboard_cubit.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eucalysp_insight_app/features/dashboard/bloc/dashboard_state.dart';
import 'package:eucalysp_insight_app/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:eucalysp_insight_app/features/business/bloc/business_cubit.dart';
import 'package:eucalysp_insight_app/features/business/bloc/business_state.dart';
import 'package:eucalysp_insight_app/features/inventory/bloc/inventory_cubit.dart';
import 'package:eucalysp_insight_app/features/sales/bloc/sales_cubit.dart';
import 'dart:async';

class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository _dashboardRepository;
  final BusinessCubit _businessCubit;
  final InventoryCubit _inventoryCubit;
  final SalesCubit _salesCubit;
  late StreamSubscription _businessSubscription;
  late StreamSubscription _inventorySubscription;
  late StreamSubscription _salesSubscription;
  String? _currentBusinessId;

  DashboardCubit({
    required DashboardRepository dashboardRepository,
    required BusinessCubit businessCubit,
    required InventoryCubit inventoryCubit,
    required SalesCubit salesCubit,
  }) : _dashboardRepository = dashboardRepository,
       _businessCubit = businessCubit,
       _inventoryCubit = inventoryCubit,
       _salesCubit = salesCubit,
       super(DashboardInitial()) {
    debugPrint('[DashboardCubit] Created. Initial state: ${state.runtimeType}');
    _businessSubscription = _businessCubit.stream.listen((businessState) {
      debugPrint(
        '[DashboardCubit] Business state changed: ${businessState.runtimeType}',
      );
      if (businessState is BusinessLoaded &&
          businessState.selectedBusiness != null) {
        final newBusinessId = businessState.selectedBusiness!.id;
        if (newBusinessId != _currentBusinessId) {
          _currentBusinessId = newBusinessId;
          debugPrint(
            '[DashboardCubit] Business selected: $_currentBusinessId. Fetching dashboard data...',
          );
          fetchDashboardData(newBusinessId);
        }
      } else if (businessState is BusinessLoaded &&
          businessState.selectedBusiness == null) {
        emit(DashboardInitial());
      }
    });

    if (_businessCubit.state is BusinessLoaded &&
        (_businessCubit.state as BusinessLoaded).selectedBusiness != null) {
      _currentBusinessId =
          (_businessCubit.state as BusinessLoaded).selectedBusiness!.id;
      fetchDashboardData(_currentBusinessId!);
    }

    _inventorySubscription = _inventoryCubit.stream.listen((inventoryState) {
      if (_currentBusinessId != null) {
        fetchDashboardData(_currentBusinessId!);
      }
    });

    _salesSubscription = _salesCubit.stream.listen((salesState) {
      if (_currentBusinessId != null) {
        fetchDashboardData(_currentBusinessId!);
      }
    });
  }

  Future<void> fetchDashboardData(String businessId) async {
    try {
      emit(DashboardLoading());
      debugPrint('[DashboardCubit] Loading data for business: $businessId');
      final dashboardData = await _dashboardRepository.fetchDashboardSummary(
        businessId,
      );
      debugPrint('''
      [DashboardCubit] Data loaded:
      - Total Sales: \$${dashboardData.totalSales}
      - Total Inventory: ${dashboardData.totalInventory}
      - Recent Transactions: ${dashboardData.recentTransactions.length}
      ''');
      emit(DashboardLoaded(dashboardData: dashboardData));
    } catch (e) {
      debugPrint(
        '[DashboardCubit] Error fetching data for $businessId: $e\n$e',
      );

      emit(
        DashboardError(
          message: 'Failed to load dashboard data: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _businessSubscription.cancel();
    _inventorySubscription.cancel();
    _salesSubscription.cancel();
    return super.close();
  }
}
