// lib/features/inventory/bloc/inventory_cubit.dart
import 'package:eucalysp_insight_app/features/inventory/domain/entities/product.dart'; // <--- Make sure this import is present!
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eucalysp_insight_app/features/inventory/bloc/inventory_state.dart';
import 'package:eucalysp_insight_app/features/inventory/data/repositories/inventory_repository.dart';
import 'package:eucalysp_insight_app/features/business/bloc/business_cubit.dart';
import 'package:eucalysp_insight_app/features/business/bloc/business_state.dart';
import 'dart:async';

class InventoryCubit extends Cubit<InventoryState> {
  final InventoryRepository _inventoryRepository;
  final BusinessCubit _businessCubit;
  late StreamSubscription _businessSubscription;
  String? _currentBusinessId;

  InventoryCubit({
    required InventoryRepository inventoryRepository,
    required BusinessCubit businessCubit,
  }) : _inventoryRepository = inventoryRepository,
       _businessCubit = businessCubit,
       super(InventoryInitial()) {
    print(
      'InventoryCubit created. Initial state: ${state.runtimeType}',
    ); // Debug print
    _businessSubscription = _businessCubit.stream.listen((businessState) {
      print(
        'BusinessCubit state changed to: ${businessState.runtimeType}',
      ); // Debug print
      if (businessState is BusinessLoaded &&
          businessState.selectedBusiness != null) {
        final newBusinessId = businessState.selectedBusiness!.id;
        if (newBusinessId != _currentBusinessId) {
          _currentBusinessId = newBusinessId;
          print(
            'Business selected: $_currentBusinessId. Fetching products...',
          ); // Debug print
          fetchProducts(newBusinessId);
        }
      } else if (businessState is BusinessLoaded &&
          businessState.selectedBusiness == null) {
        print(
          'No business selected. Emitting InventoryInitial.',
        ); // Debug print
        _currentBusinessId = null;
        emit(InventoryInitial());
      }
    });

    if (_businessCubit.state is BusinessLoaded &&
        (_businessCubit.state as BusinessLoaded).selectedBusiness != null) {
      _currentBusinessId =
          (_businessCubit.state as BusinessLoaded).selectedBusiness!.id;
      print(
        'Initial business selected: $_currentBusinessId. Fetching products...',
      ); // Debug print
      fetchProducts(_currentBusinessId!);
    }
  }

  Future<void> fetchProducts(String businessId) async {
    try {
      emit(InventoryLoading());
      print('Emitting InventoryLoading for $businessId'); // Debug print
      final products = await _inventoryRepository.fetchProducts(businessId);
      print(
        'Fetched ${products.length} products for $businessId',
      ); // Debug print
      emit(InventoryLoaded(products: products));
      print('Emitting InventoryLoaded for $businessId'); // Debug print
    } catch (e) {
      print('Error in fetchProducts for $businessId: $e'); // Debug print
      emit(InventoryError(message: 'Failed to load products: ${e.toString()}'));
    }
  }

  // <--- Ensure this addProduct method (and the Product import above) is present here!
  Future<void> addProduct(Product product) async {
    try {
      emit(InventoryLoading());
      await _inventoryRepository.addProduct(product);
      if (_currentBusinessId != null) {
        await fetchProducts(_currentBusinessId!);
      }
    } catch (e) {
      emit(InventoryError(message: 'Failed to add product: ${e.toString()}'));
    }
  }

  @override
  Future<void> close() {
    _businessSubscription.cancel();
    return super.close();
  }
}
