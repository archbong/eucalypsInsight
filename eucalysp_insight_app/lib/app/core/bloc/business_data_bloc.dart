// lib/app/core/bloc/business_data_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart'; // IMPORTANT: Add this import for Equatable

/// Base state for all business data loading
// FIX: Add the generic type parameter <T> here and make it extend Equatable
sealed class BusinessDataState<T> extends Equatable {
  const BusinessDataState(); // Add a const constructor

  @override
  List<Object?> get props => [];
}

/// Initial state before any data loading
class BusinessDataInitial<T> extends BusinessDataState<T> {
  const BusinessDataInitial(); // Add a const constructor
}

/// Data loading in progress
class BusinessDataLoading<T> extends BusinessDataState<T> {
  const BusinessDataLoading(); // Add a const constructor
}

/// Data successfully loaded
class BusinessDataLoaded<T> extends BusinessDataState<T> {
  final T data;
  const BusinessDataLoaded(this.data); // Add const constructor

  @override
  List<Object?> get props => [data]; // Implement props for Equatable
}

/// Error state with message
class BusinessDataError<T> extends BusinessDataState<T> {
  final String message;
  const BusinessDataError(this.message); // Add const constructor

  @override
  List<Object?> get props => [message]; // Implement props for Equatable
}

/// Base bloc for business data loading functionality
abstract class BusinessDataBloc<T> extends Cubit<BusinessDataState<T>> {
  // Update Cubit type
  BusinessDataBloc()
    : super(const BusinessDataInitial()); // Use const constructor

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
      emit(const BusinessDataLoading()); // Use const constructor
      final data = await loader();
      emit(BusinessDataLoaded(data));
    } catch (e) {
      emit(BusinessDataError('$errorMessage: ${e.toString()}'));
      rethrow;
    }
  }
}
