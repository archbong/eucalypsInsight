// lib/features/sales/bloc/sales_cubit.dart
import 'package:eucalysp_insight_app/features/sales/domain/entities/sale.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eucalysp_insight_app/features/sales/bloc/sales_state.dart';
import 'package:eucalysp_insight_app/features/sales/data/repositories/sales_repository.dart';
import 'package:eucalysp_insight_app/features/business/bloc/business_cubit.dart'; // Import BusinessCubit
import 'package:eucalysp_insight_app/features/business/bloc/business_state.dart'; // Import BusinessState
import 'dart:async'; // Required for StreamSubscription

class SalesCubit extends Cubit<SalesState> {
  final SalesRepository _salesRepository;
  final BusinessCubit _businessCubit;
  late StreamSubscription _businessSubscription;
  String? _currentBusinessId; // To keep track of the last fetched businessId

  SalesCubit({
    required SalesRepository salesRepository,
    required BusinessCubit businessCubit,
  }) : _salesRepository = salesRepository,
       _businessCubit = businessCubit,
       super(SalesInitial()) {
    // Listen to BusinessCubit's state changes
    _businessSubscription = _businessCubit.stream.listen((businessState) {
      if (businessState is BusinessLoaded &&
          businessState.selectedBusiness != null) {
        final newBusinessId = businessState.selectedBusiness!.id;
        // Only fetch if the business ID has actually changed, or if it's the first fetch
        if (newBusinessId != _currentBusinessId) {
          _currentBusinessId = newBusinessId;
          fetchSales(newBusinessId);
        }
      } else if (businessState is BusinessLoaded &&
          businessState.selectedBusiness == null) {
        // If no business is selected (e.g., after logout), go back to initial state
        _currentBusinessId = null;
        emit(SalesInitial());
      }
    });

    // Also trigger initial fetch if a business is already selected on cubit creation
    if (_businessCubit.state is BusinessLoaded &&
        (_businessCubit.state as BusinessLoaded).selectedBusiness != null) {
      _currentBusinessId =
          (_businessCubit.state as BusinessLoaded).selectedBusiness!.id;
      fetchSales(_currentBusinessId!);
    }
  }

  Future<void> fetchSales(String businessId) async {
    try {
      emit(SalesLoading());
      final sales = await _salesRepository.fetchSales(businessId);
      emit(SalesLoaded(sales: sales));
    } catch (e) {
      emit(SalesError(message: 'Failed to load sales: ${e.toString()}'));
    }
  }

  // Example for future: add a sale (will trigger a refresh)
  Future<void> addSale(Sale sale) async {
    try {
      emit(SalesLoading()); // Or a more specific state like SalesAdding
      await _salesRepository.addSale(sale);
      // After adding, refetch the list to update the UI
      if (_currentBusinessId != null) {
        await fetchSales(_currentBusinessId!);
      }
    } catch (e) {
      emit(SalesError(message: 'Failed to add sale: ${e.toString()}'));
    }
  }

  @override
  Future<void> close() {
    _businessSubscription.cancel();
    return super.close();
  }
}
