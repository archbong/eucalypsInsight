// lib/features/dashboard/bloc/dashboard_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eucalysp_insight_app/features/dashboard/bloc/dashboard_state.dart';
import 'package:eucalysp_insight_app/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:eucalysp_insight_app/features/business/bloc/business_cubit.dart';
import 'package:eucalysp_insight_app/features/business/bloc/business_state.dart';
import 'dart:async';

class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository _dashboardRepository;
  final BusinessCubit _businessCubit;
  late StreamSubscription _businessSubscription;
  String? _currentBusinessId;

  DashboardCubit({
    required DashboardRepository dashboardRepository,
    required BusinessCubit businessCubit,
  }) : _dashboardRepository = dashboardRepository,
       _businessCubit = businessCubit,
       super(DashboardInitial()) {
    print('DashboardCubit created. Initial state: ${state.runtimeType}');
    _businessSubscription = _businessCubit.stream.listen((businessState) {
      print('BusinessCubit state changed to: ${businessState.runtimeType}');
      if (businessState is BusinessLoaded &&
          businessState.selectedBusiness != null) {
        final newBusinessId = businessState.selectedBusiness!.id;
        if (newBusinessId != _currentBusinessId) {
          _currentBusinessId = newBusinessId;
          print('Business selected: $_currentBusinessId. Fetching products...');
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
  }

  Future<void> fetchDashboardData(String businessId) async {
    try {
      emit(DashboardLoading());
      print('Emitting DasboardLoading for $businessId'); // Debug print
      // Call the repository method, which now returns DashboardData
      final dashboardData = await _dashboardRepository.fetchDashboardSummary(
        businessId,
      );
      // Emit the loaded state with the DashboardData object
      emit(DashboardLoaded(dashboardData: dashboardData));
    } catch (e) {
      print('Error in fetchDashboardData for $businessId: $e'); // Debug print
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
    return super.close();
  }
}
