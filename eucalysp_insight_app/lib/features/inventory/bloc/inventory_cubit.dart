// lib/features/inventory/bloc/inventory_cubit.dart
import 'package:hive/hive.dart';
import 'package:eucalysp_insight_app/features/inventory/domain/entities/product.dart';
import 'package:eucalysp_insight_app/features/inventory/utils/hive_service.dart'; // Ensure this is still needed and correctly implemented
import 'package:flutter/material.dart'; // This import is only temporarily here to highlight the removed SnackBar dependency. It should be removed once you complete the UI changes for displaying errors.
import 'package:eucalysp_insight_app/features/inventory/bloc/inventory_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:eucalysp_insight_app/features/inventory/bloc/inventory_state.dart'; // Duplicate import, removed
import 'package:eucalysp_insight_app/features/inventory/data/repositories/inventory_repository.dart';
import 'package:eucalysp_insight_app/features/business/bloc/business_cubit.dart';
import 'package:eucalysp_insight_app/features/business/bloc/business_state.dart';
import 'dart:async';

class InventoryCubit extends Cubit<InventoryState> {
  final InventoryRepository _inventoryRepository;
  final BusinessCubit _businessCubit;
  late StreamSubscription _businessSubscription;
  String? _currentBusinessId;
  late final Box<Product> _hiveBox; // Marked as late final

  // New properties to store current filter criteria
  String _currentSearchQuery = '';
  String? _currentCategoryFilter;
  double? _currentMinPriceFilter;
  double? _currentMaxPriceFilter;

  // Categories are derived from the loaded products,
  // making it a getter ensures it's always up-to-date with the full product list.
  List<String> get categories {
    if (state is InventoryLoaded) {
      return (state as InventoryLoaded)
          .allProducts // Use allProducts to get all categories, not just filtered ones
          .map((p) => p.category ?? '')
          .where((c) => c.isNotEmpty)
          .toSet() // Use Set to get unique categories
          .toList();
    }
    return [];
  }

  InventoryCubit({
    required InventoryRepository inventoryRepository,
    required BusinessCubit businessCubit,
  }) : _inventoryRepository = inventoryRepository,
       _businessCubit = businessCubit,
       super(InventoryInitial()) {
    _initHive(); // Ensure Hive is initialized
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
        // Reset filters when no business is selected
        _resetFilters();
      }
    });

    // Handle initial business state if already loaded
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
    // Moved the outer try-catch for simplicity, now one main try-catch
    emit(InventoryLoading());
    print('Emitting InventoryLoading for $businessId'); // Debug print
    try {
      final products = await _inventoryRepository.fetchProducts(businessId);
      print(
        'Fetched ${products.length} products for $businessId',
      ); // Debug print

      // Apply current filters to the fetched products before emitting
      final filteredProducts = _applyFilters(products);
      emit(
        InventoryLoaded(
          allProducts: products,
          filteredProducts: filteredProducts,
        ),
      );
      print('Emitting InventoryLoaded for $businessId'); // Debug print

      await _syncWithHive(products); // Sync all fetched products to Hive
    } catch (e) {
      print('Error fetching products for $businessId: $e'); // Debug print
      final offlineProducts = await _getFromHive();
      if (offlineProducts.isNotEmpty) {
        // Apply filters to offline products if they exist
        final filteredOfflineProducts = _applyFilters(offlineProducts);
        emit(
          InventoryLoaded(
            allProducts:
                offlineProducts, // offline products become the 'allProducts'
            filteredProducts: filteredOfflineProducts,
            message:
                'Showing offline data due to network error.', // Add a message for UI
          ),
        );
        // Removed ScaffoldMessenger.of(context).showSnackBar - Cubits shouldn't directly interact with UI
        // The UI (InventoryListScreen) will listen for the InventoryLoaded state with a message
        // and display the SnackBar or other feedback.
      } else {
        emit(
          InventoryError(message: 'Failed to load products: ${e.toString()}'),
        );
      }
    }
  }

  // Helper method to apply all active filters
  List<Product> _applyFilters(List<Product> products) {
    var filtered = List<Product>.from(products); // Create a mutable copy

    if (_currentSearchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (p) => p.name.toLowerCase().contains(
              _currentSearchQuery.toLowerCase(),
            ),
          )
          .toList();
    }

    if (_currentCategoryFilter != null && _currentCategoryFilter!.isNotEmpty) {
      filtered = filtered
          .where(
            (p) =>
                p.category?.toLowerCase() ==
                _currentCategoryFilter!.toLowerCase(),
          )
          .toList();
    }

    if (_currentMinPriceFilter != null) {
      filtered = filtered
          .where((p) => p.price >= _currentMinPriceFilter!)
          .toList();
    }

    if (_currentMaxPriceFilter != null) {
      filtered = filtered
          .where((p) => p.price <= _currentMaxPriceFilter!)
          .toList();
    }

    return filtered;
  }

  // Update filterProducts to store the filter criteria
  void filterProducts(
    String query, {
    String? category,
    double? minPrice,
    double? maxPrice,
  }) {
    _currentSearchQuery = query;
    _currentCategoryFilter = category;
    _currentMinPriceFilter = minPrice;
    _currentMaxPriceFilter = maxPrice;

    if (state is InventoryLoaded) {
      final currentLoadedState = state as InventoryLoaded;
      final filtered = _applyFilters(currentLoadedState.allProducts);
      emit(
        InventoryLoaded(
          allProducts: currentLoadedState.allProducts,
          filteredProducts: filtered,
        ),
      );
    }
    // If not in InventoryLoaded, it means products haven't been fetched yet
    // The fetchProducts method will apply filters once data is available.
  }

  // New method to reset all filters
  void resetFilters() {
    _resetFilters();
    if (state is InventoryLoaded) {
      // Re-emit with original products if filters are reset
      final currentLoadedState = state as InventoryLoaded;
      emit(
        InventoryLoaded(
          allProducts: currentLoadedState.allProducts,
          filteredProducts: currentLoadedState.allProducts,
        ),
      );
    }
  }

  void _resetFilters() {
    _currentSearchQuery = '';
    _currentCategoryFilter = null;
    _currentMinPriceFilter = null;
    _currentMaxPriceFilter = null;
  }

  Future<void> addProduct(Product product) async {
    try {
      emit(InventoryLoading()); // Or a more specific state like InventoryAdding
      await _inventoryRepository.addProduct(product);
      if (_currentBusinessId != null) {
        await fetchProducts(
          _currentBusinessId!,
        ); // Re-fetch to update list and re-apply filters
      }
      // Optionally emit a success state here, if you want specific UI feedback for adding.
      // e.g., emit(InventoryActionSuccess(message: 'Product added successfully!'));
    } catch (e) {
      emit(InventoryError(message: 'Failed to add product: ${e.toString()}'));
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      emit(InventoryLoading()); // Or InventoryUpdating
      await _inventoryRepository.updateProduct(product);
      if (_currentBusinessId != null) {
        await fetchProducts(
          _currentBusinessId!,
        ); // Re-fetch to update list and re-apply filters
      }
      // emit(InventoryActionSuccess(message: 'Product updated successfully!'));
    } catch (e) {
      emit(
        InventoryError(message: 'Failed to update product: ${e.toString()}'),
      );
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      emit(InventoryLoading()); // Or InventoryDeleting
      await _inventoryRepository.deleteProduct(productId);
      if (_currentBusinessId != null) {
        await fetchProducts(
          _currentBusinessId!,
        ); // Re-fetch to update list and re-apply filters
      }
      // emit(InventoryActionSuccess(message: 'Product deleted successfully!'));
    } catch (e) {
      emit(
        InventoryError(message: 'Failed to delete product: ${e.toString()}'),
      );
    }
  }

  Future<void> bulkDelete(List<String> productIds) async {
    if (productIds.isEmpty) return; // Prevent unnecessary operations
    try {
      emit(InventoryLoading()); // Or InventoryBulkDeleting
      await Future.wait(
        productIds.map((id) => _inventoryRepository.deleteProduct(id)),
      );
      if (_currentBusinessId != null) {
        await fetchProducts(
          _currentBusinessId!,
        ); // Re-fetch to update list and re-apply filters
      }
      // emit(InventoryActionSuccess(message: 'Bulk delete completed!'));
    } catch (e) {
      emit(InventoryError(message: 'Bulk delete failed: ${e.toString()}'));
    }
  }

  Future<void> bulkUpdate(
    List<String> productIds, {
    double? price,
    int? quantity,
  }) async {
    if (productIds.isEmpty || (price == null && quantity == null))
      return; // Prevent unnecessary ops
    try {
      emit(InventoryLoading()); // Or InventoryBulkUpdating
      await Future.wait(
        productIds.map(
          (id) => _inventoryRepository.updateProductPartial(
            id,
            price: price,
            quantity: quantity,
          ),
        ),
      );
      if (_currentBusinessId != null) {
        await fetchProducts(
          _currentBusinessId!,
        ); // Re-fetch to update list and re-apply filters
      }
      // emit(InventoryActionSuccess(message: 'Bulk update completed!'));
    } catch (e) {
      emit(InventoryError(message: 'Bulk update failed: ${e.toString()}'));
    }
  }

  Future<void> _initHive() async {
    _hiveBox = await Hive.openBox<Product>('inventory');
    print('Hive box opened: inventory'); // Debug print
  }

  Future<void> _syncWithHive(List<Product> products) async {
    // Consider adding a check to only sync if there's an internet connection
    // or if the repository explicitly confirms a successful backend sync.
    await _hiveBox.clear();
    for (final product in products) {
      await _hiveBox.put(product.id, product);
    }
    print('Synced ${products.length} products to Hive'); // Debug print
  }

  Future<List<Product>> _getFromHive() async {
    final products = _hiveBox.values.toList();
    print('Retrieved ${products.length} products from Hive'); // Debug print
    return products;
  }

  @override
  Future<void> close() {
    _businessSubscription.cancel();
    _hiveBox.close();
    print('InventoryCubit closed.'); // Debug print
    return super.close();
  }
}
