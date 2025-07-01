// lib/app/core/bloc/business_data_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';

/// Base state for all business data loading
// CHANGE THIS LINE: Add the 'sealed' keyword
sealed class BusinessDataState {}

/// Initial state before any data loading
class BusinessDataInitial extends BusinessDataState {}

/// Data loading in progress
class BusinessDataLoading extends BusinessDataState {}

/// Data successfully loaded
class BusinessDataLoaded<T> extends BusinessDataState {
  final T data;
  BusinessDataLoaded(this.data);
}

/// Error state with message
class BusinessDataError extends BusinessDataState {
  final String message;
  BusinessDataError(this.message);
}

/// Base bloc for business data loading functionality
abstract class BusinessDataBloc<T> extends Cubit<BusinessDataState> {
  BusinessDataBloc() : super(BusinessDataInitial());

  /// Load data for specific business ID
  Future<void> loadData(String businessId);

  /// Refresh current data
  Future<void> refreshData(String businessId) async {
    await loadData(businessId);
  }
}

/// Mixin for business data loader functionality
mixin BusinessDataLoaderMixin<T> on BusinessDataBloc<T> {
  /// Helper method to handle standard loading flow
  Future<void> executeLoad({
    required Future<T> Function() loader,
    required String errorMessage,
  }) async {
    try {
      emit(BusinessDataLoading());
      final data = await loader();
      emit(BusinessDataLoaded(data));
    } catch (e) {
      emit(BusinessDataError('$errorMessage: ${e.toString()}'));
      rethrow;
    }
  }
}
