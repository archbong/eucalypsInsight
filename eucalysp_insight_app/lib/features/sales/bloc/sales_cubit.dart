// lib/features/sales/bloc/sales_cubit.dart
import 'package:eucalysp_insight_app/features/sales/domain/entities/sale.dart';
import 'package:eucalysp_insight_app/app/core/bloc/business_data_bloc.dart';
import 'package:eucalysp_insight_app/app/core/utils/business_data_loader.dart';
import 'package:eucalysp_insight_app/features/sales/data/repositories/sales_repository.dart';
import 'package:eucalysp_insight_app/features/business/bloc/business_cubit.dart';
import 'package:eucalysp_insight_app/features/business/bloc/business_state.dart';
import 'package:eucalysp_insight_app/features/sales/domain/entities/sale_item.dart';

// REMOVE THESE OLD SALES STATE DEFINITIONS ENTIRELY (if still present)
/*
abstract class SalesState {}
class SalesInitial extends SalesState {}
class SalesLoading extends SalesState {}
class SalesLoaded extends SalesState {
  final List<Sale> sales;
  SalesLoaded({required this.sales});
}
class SalesError extends SalesState {
  final String message;
  SalesError({required this.message});
}
*/

class SalesCubit extends BusinessDataBloc<List<Sale>> {
  final SalesRepository _salesRepository;
  // CHANGE 1: Add 'late' keyword here
  late final BusinessDataLoader<List<Sale>, SalesCubit> _loader;
  final BusinessCubit _businessCubit;

  SalesCubit({
    required SalesRepository salesRepository,
    required BusinessCubit businessCubit,
  }) : _salesRepository = salesRepository,
       _businessCubit = businessCubit,
       super() {
    // Call the super constructor first
    // CHANGE 2: Move the initialization of _loader into the constructor body
    _loader = BusinessDataLoader<List<Sale>, SalesCubit>(
      businessCubit: businessCubit, // Use the parameter directly
      dataCubit: this, // 'this' is now valid here
    );
  }

  @override
  Future<void> loadData(String businessId) async {
    try {
      emit(BusinessDataLoading());
      final sales = await _salesRepository.fetchSales(businessId);
      emit(BusinessDataLoaded(sales));
    } catch (e) {
      emit(BusinessDataError('Failed to load sales: ${e.toString()}'));
    }
  }

  Future<void> addSale(Sale sale) async {
    try {
      await _salesRepository.addSale(sale);

      final currentBusinessState = _businessCubit.state;
      if (currentBusinessState is BusinessLoaded &&
          currentBusinessState.selectedBusiness != null) {
        await loadData(currentBusinessState.selectedBusiness!.id);
      } else {
        emit(
          BusinessDataError(
            'Sale added, but no business selected to refresh list.',
          ),
        );
      }
    } catch (e) {
      emit(BusinessDataError('Failed to add sale: ${e.toString()}'));
    }
  }

  Future<void> updateSale(Sale sale) async {
    try {
      emit(BusinessDataLoading());
      await _salesRepository.updateSale(sale);
      final currentBusinessState = _businessCubit.state;
      if (currentBusinessState is BusinessLoaded &&
          currentBusinessState.selectedBusiness != null) {
        await loadData(currentBusinessState.selectedBusiness!.id);
      }
    } catch (e) {
      emit(BusinessDataError('Failed to update sale: ${e.toString()}'));
    }
  }

  Future<void> deleteSale(String saleId) async {
    try {
      emit(BusinessDataLoading());
      await _salesRepository.deleteSale(saleId);
      final currentBusinessState = _businessCubit.state;
      if (currentBusinessState is BusinessLoaded &&
          currentBusinessState.selectedBusiness != null) {
        await loadData(currentBusinessState.selectedBusiness!.id);
      }
    } catch (e) {
      emit(BusinessDataError('Failed to delete sale: ${e.toString()}'));
    }
  }

  @override
  Future<void> close() {
    _loader.dispose();
    return super.close();
  }
}
