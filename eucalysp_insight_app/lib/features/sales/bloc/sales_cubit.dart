// lib/features/sales/bloc/sales_cubit.dart
import 'package:eucalysp_insight_app/features/sales/domain/entities/sale.dart';
import 'package:eucalysp_insight_app/app/core/bloc/business_data_bloc.dart';
import 'package:eucalysp_insight_app/app/core/utils/business_data_loader.dart';
import 'package:eucalysp_insight_app/features/sales/data/repositories/sales_repository.dart';
import 'package:eucalysp_insight_app/features/business/bloc/business_cubit.dart';
import 'package:eucalysp_insight_app/features/business/bloc/business_state.dart';

// SalesCubit must use the BusinessDataLoaderMixin as it's designed to provide executeLoad
class SalesCubit extends BusinessDataBloc<List<Sale>>
    with BusinessDataLoaderMixin<List<Sale>> {
  final SalesRepository _salesRepository;
  late final BusinessDataLoader<List<Sale>, SalesCubit> _loader;
  final BusinessCubit _businessCubit;

  SalesCubit({
    required SalesRepository salesRepository,
    required BusinessCubit businessCubit,
  }) : _salesRepository = salesRepository,
       _businessCubit = businessCubit,
       super() {
    _loader = BusinessDataLoader<List<Sale>, SalesCubit>(
      businessCubit: _businessCubit,
      dataCubit: this, // 'this' refers to SalesCubit instance
    );
  }

  // loadData is an abstract method in BusinessDataBloc, so it must be implemented.
  // It will be called by BusinessDataLoader.
  @override
  Future<void> loadData(String businessId) async {
    // Use the executeLoad helper from BusinessDataLoaderMixin
    // This handles emit(BusinessDataLoading()) and emit(BusinessDataLoaded(data))
    // or emit(BusinessDataError(...)) internally based on the loader function's outcome.
    await executeLoad(
      loader: () => _salesRepository.fetchSales(businessId),
      errorMessage: 'Failed to load sales',
    );
  }

  // refreshData is an abstract method in BusinessDataBloc, must be implemented.
  // It's used for explicit refresh calls from the UI/other parts.
  @override
  Future<void> refreshData(String businessId) async {
    // Simply call loadData, which uses executeLoad.
    // The businessId is now explicitly passed from the caller of refreshData.
    await loadData(businessId);
  }

  Future<void> addSale(Sale sale) async {
    try {
      // Temporarily emit loading state. businessId cannot be passed here.
      emit(const BusinessDataLoading());
      await _salesRepository.addSale(sale);
      await _refreshSalesAfterAction(); // Refresh data after action
    } catch (e) {
      // Emit error state. businessId cannot be passed here.
      emit(BusinessDataError('Failed to add sale: ${e.toString()}'));
    }
  }

  Future<void> updateSale(Sale sale) async {
    try {
      emit(const BusinessDataLoading());
      await _salesRepository.updateSale(sale);
      await _refreshSalesAfterAction();
    } catch (e) {
      emit(BusinessDataError('Failed to update sale: ${e.toString()}'));
    }
  }

  Future<void> deleteSale(String saleId) async {
    try {
      emit(const BusinessDataLoading());
      await _salesRepository.deleteSale(saleId);
      await _refreshSalesAfterAction();
    } catch (e) {
      emit(BusinessDataError('Failed to delete sale: ${e.toString()}'));
    }
  }

  // This method ensures the sales list is refreshed after an action (add, update, delete).
  Future<void> _refreshSalesAfterAction() async {
    final currentBusinessState = _businessCubit.state;
    if (currentBusinessState is BusinessLoaded &&
        currentBusinessState.selectedBusiness != null) {
      // Call loadData (which uses executeLoad) with the ID of the currently selected business.
      await loadData(currentBusinessState.selectedBusiness!.id);
    } else {
      // If no business is selected, emit a generic error state as businessId is not available
      emit(const BusinessDataError('No business selected to refresh sales.'));
    }
  }

  @override
  Future<void> close() {
    _loader.dispose(); // Dispose the BusinessDataLoader's stream subscription
    return super.close();
  }
}
