// lib/features/inventory/bloc/inventory_cubit.dart

import 'package:bloc/bloc.dart';
import 'package:eucalysp_insight_app/features/business/bloc/business_cubit.dart';
import 'package:eucalysp_insight_app/features/business/bloc/business_state.dart';
import 'package:eucalysp_insight_app/features/inventory/bloc/inventory_state.dart';
import 'package:eucalysp_insight_app/features/inventory/data/repositories/inventory_repository.dart';
import 'package:eucalysp_insight_app/features/inventory/domain/entities/product.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';

class InventoryCubit extends Cubit<InventoryState> {
  final InventoryRepository _inventoryRepository;
  final BusinessCubit _businessCubit;
  late StreamSubscription _businessSubscription;
  int _currentPage = 1;
  final int _itemsPerPage = 20;
  // Filters
  String _currentSearchQuery = '';
  String? _currentCategoryFilter;
  double? _currentMinPriceFilter;
  double? _currentMaxPriceFilter;
  String? _currentBusinessId; // To keep track of the selected business

  final _searchController = BehaviorSubject<String>(); // For search debounce

  InventoryCubit({
    required InventoryRepository inventoryRepository,
    required BusinessCubit businessCubit,
  }) : _inventoryRepository = inventoryRepository,
       _businessCubit = businessCubit,
       super(InventoryInitial()) {
    print('InventoryCubit created. Initial state: ${state.runtimeType}');

    _businessSubscription = _businessCubit.stream.listen((businessState) {
      if (businessState is BusinessLoaded &&
          businessState.selectedBusiness != null) {
        _currentBusinessId = businessState.selectedBusiness!.id;
        print('Business selected: $_currentBusinessId. Fetching inventory.');
        fetchProducts(_currentBusinessId!);
      } else if (businessState is BusinessLoaded &&
          businessState.selectedBusiness == null) {
        _currentBusinessId = null;
        emit(
          InventoryLoaded(allProducts: [], filteredProducts: []),
        ); // Clear inventory if no business selected
        print('No business selected. Clearing inventory.');
      }
    });

    _searchController.debounceTime(const Duration(milliseconds: 300)).listen((
      query,
    ) {
      _currentSearchQuery = query;
      _applyFilters(); // Apply filters when search query changes (debounced)
    });

    // Handle initial business state if already loaded (from a previous session or if BlocProvider is initialized late)
    if (_businessCubit.state is BusinessLoaded &&
        (_businessCubit.state as BusinessLoaded).selectedBusiness != null) {
      _currentBusinessId =
          (_businessCubit.state as BusinessLoaded).selectedBusiness!.id;
      print(
        'Initial business selected: $_currentBusinessId. Fetching inventory.',
      );
      fetchProducts(_currentBusinessId!);
    }
  }

  // Getter for categories (derived from allProducts in the current state)
  List<String> get categories {
    if (state is InventoryLoaded) {
      final loadedState = state as InventoryLoaded;
      return loadedState.allProducts
          .map((p) => p.category) // This is Iterable<String?>
          .where(
            (category) => category?.isNotEmpty ?? false,
          ) // Filters out nulls and empty strings, still Iterable<String?>
          .map(
            (category) => category!,
          ) // Converts Iterable<String?> to Iterable<String>
          .toSet() // Now Set<String>
          .toList() // Now List<String>
        ..sort(); // Sort categories alphabetically (works on List<String>)
    }
    return [];
  }

  // --- Core CRUD Operations ---

  Future<void> addProduct(Product product) async {
    try {
      emit(InventoryLoading());
      print('DEBUG: Attempting to add product: ${product.name}');
      await _inventoryRepository.addProduct(product);
      print('DEBUG: Product added to repository: ${product.name}');
      if (_currentBusinessId != null) {
        print(
          'DEBUG: Re-fetching products after adding: ${_currentBusinessId!}',
        );
        await fetchProducts(
          _currentBusinessId!,
        ); // Re-fetch to update list and re-apply filters
        print('DEBUG: fetchProducts completed after adding product.');
      } else {
        emit(InventoryError(message: 'No business selected to add product.'));
        print('DEBUG: No business selected when trying to add product.');
      }
    } catch (e) {
      print('DEBUG: Error adding product: $e');
      emit(InventoryError(message: 'Failed to add product: ${e.toString()}'));
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      emit(InventoryLoading());
      print('DEBUG: Attempting to update product: ${product.name}');
      await _inventoryRepository.updateProduct(product);
      print('DEBUG: Product updated in repository: ${product.name}');
      if (_currentBusinessId != null) {
        print(
          'DEBUG: Re-fetching products after updating: ${_currentBusinessId!}',
        );
        await fetchProducts(_currentBusinessId!);
      }
    } catch (e) {
      print('DEBUG: Error updating product: $e');
      emit(
        InventoryError(message: 'Failed to update product: ${e.toString()}'),
      );
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      emit(InventoryLoading());
      print('DEBUG: Attempting to delete product with ID: $productId');
      await _inventoryRepository.deleteProduct(productId);
      print('DEBUG: Product deleted from repository: $productId');
      if (_currentBusinessId != null) {
        print(
          'DEBUG: Re-fetching products after deleting: ${_currentBusinessId!}',
        );
        await fetchProducts(_currentBusinessId!);
      }
    } catch (e) {
      print('DEBUG: Error deleting product: $e');
      emit(
        InventoryError(message: 'Failed to delete product: ${e.toString()}'),
      );
    }
  }

  // --- Bulk Operations ---
  // THESE METHODS ARE INCLUDED IN THIS CUBIT VERSION
  Future<void> bulkDelete(List<String> productIds) async {
    if (productIds.isEmpty) return; // Prevent unnecessary operations
    try {
      emit(InventoryLoading()); // Or InventoryBulkDeleting
      print('DEBUG: Attempting bulk delete for ${productIds.length} products.');
      await Future.wait(
        productIds.map((id) => _inventoryRepository.deleteProduct(id)),
      );
      print('DEBUG: Bulk delete completed in repository.');
      if (_currentBusinessId != null) {
        print(
          'DEBUG: Re-fetching products after bulk delete: ${_currentBusinessId!}',
        );
        await fetchProducts(
          _currentBusinessId!,
        ); // Re-fetch to update list and re-apply filters
      }
    } catch (e) {
      print('DEBUG: Bulk delete failed: $e');
      emit(InventoryError(message: 'Bulk delete failed: ${e.toString()}'));
    }
  }

  // THESE METHODS ARE INCLUDED IN THIS CUBIT VERSION
  Future<void> bulkUpdate(
    List<String> productIds, {
    double? price,
    int? quantity,
  }) async {
    if (productIds.isEmpty || (price == null && quantity == null)) {
      print(
        'DEBUG: Bulk update skipped: empty productIds or no price/quantity specified.',
      );
      return; // Prevent unnecessary ops
    }
    try {
      emit(InventoryLoading()); // Or InventoryBulkUpdating
      print('DEBUG: Attempting bulk update for ${productIds.length} products.');
      await Future.wait(
        productIds.map(
          (id) => _inventoryRepository.updateProductPartial(
            id,
            price: price,
            quantity: quantity,
          ),
        ),
      );
      print('DEBUG: Bulk update completed in repository.');
      if (_currentBusinessId != null) {
        print(
          'DEBUG: Re-fetching products after bulk update: ${_currentBusinessId!}',
        );
        await fetchProducts(
          _currentBusinessId!,
        ); // Re-fetch to update list and re-apply filters
      }
    } catch (e) {
      print('DEBUG: Bulk update failed: $e');
      emit(InventoryError(message: 'Bulk update failed: ${e.toString()}'));
    }
  }

  Future<void> loadMoreProducts() async {
    if (_currentBusinessId == null || state is! InventoryLoaded) return;

    final currentState = state as InventoryLoaded;
    if (!currentState.hasMore) return; // No more items to load

    try {
      _currentPage++;
      final newProducts = await _inventoryRepository.fetchProducts(
        _currentBusinessId!,
        page: _currentPage,
        limit: _itemsPerPage,
      );

      emit(
        InventoryLoaded(
          allProducts: [...currentState.allProducts, ...newProducts],
          filteredProducts: _applyFilters([
            ...currentState.allProducts,
            ...newProducts,
          ]),
          hasMore:
              newProducts.length >= _itemsPerPage, // More items if full page
        ),
      );
    } catch (e) {
      _currentPage--; // Revert page on error
      print('Failed to load more products: $e');
    }
  }

  // --- Fetching and Filtering ---

  Future<void> fetchProducts(String businessId) async {
    _currentPage = 1; // Reset pagination on new fetch
    emit(InventoryLoading());
    print('DEBUG: Emitting InventoryLoading for $businessId');
    try {
      final products = await _inventoryRepository.fetchProducts(
        businessId,
        page: _currentPage,
        limit: _itemsPerPage,
      );
      print(
        'DEBUG: Products returned by _inventoryRepository.fetchProducts (count: ${products.length}):',
      );
      for (var p in products) {
        print('  - Product ID: ${p.id}, Name: ${p.name}, Qty: ${p.quantity}');
      } // Detailed print

      await _inventoryRepository.saveProductsToCache(products);

      final filteredProducts = _applyFilters(products);
      print(
        'DEBUG: After _applyFilters. Original count: ${products.length}, Filtered count: ${filteredProducts.length}',
      );

      emit(
        InventoryLoaded(
          allProducts: products, // `products` is the fresh list from repository
          filteredProducts: filteredProducts,
          hasMore: products.length > _itemsPerPage,
        ),
      );
      print(
        'DEBUG: Emitting InventoryLoaded. allProducts count: ${products.length}, filteredProducts count: ${filteredProducts.length}',
      );
    } catch (e) {
      print('DEBUG: Error fetching products for $businessId: $e');
      try {
        final offlineProducts = await _inventoryRepository.getOfflineProducts(
          businessId,
        );
        print(
          'DEBUG: Retrieved ${offlineProducts.length} offline products after fetch error.',
        );
        if (offlineProducts.isNotEmpty) {
          final filteredOfflineProducts = _applyFilters(offlineProducts);
          print(
            'DEBUG: Filtered offline products count: ${filteredOfflineProducts.length}',
          );
          emit(
            InventoryLoaded(
              allProducts: offlineProducts,
              filteredProducts: filteredOfflineProducts,
              message: 'Showing offline data due to network error.',
            ),
          );
        } else {
          emit(
            InventoryError(message: 'Failed to load products: ${e.toString()}'),
          );
        }
      } catch (offlineError) {
        emit(
          InventoryError(
            message:
                'Failed to load products (offline also failed): ${offlineError.toString()}',
          ),
        );
      }
    }
  }

  // Helper method to apply all active filters
  List<Product> _applyFilters([List<Product>? productsToFilter]) {
    final List<Product> sourceProducts = (state is InventoryLoaded)
        ? (state as InventoryLoaded).allProducts
        : (productsToFilter ?? []); // Use provided list or current allProducts

    List<Product> filtered = List.from(sourceProducts); // Create a mutable copy

    print(
      'DEBUG: _applyFilters called. Source products count: ${sourceProducts.length}',
    );
    print('DEBUG: Current search query: "$_currentSearchQuery"');
    print('DEBUG: Current category filter: "$_currentCategoryFilter"');
    print('DEBUG: Current min price filter: "$_currentMinPriceFilter"');
    print('DEBUG: Current max price filter: "$_currentMaxPriceFilter"');

    // Apply search query filter
    if (_currentSearchQuery.isNotEmpty) {
      filtered = filtered.where((product) {
        final query = _currentSearchQuery.toLowerCase();
        return product.name.toLowerCase().contains(query) ||
            product.sku.toLowerCase().contains(query) ||
            (product.description.toLowerCase().contains(query) ??
                false); // Handle null description
      }).toList();
    }

    // Apply category filter
    if (_currentCategoryFilter != null && _currentCategoryFilter!.isNotEmpty) {
      filtered = filtered
          .where(
            (product) =>
                product.category?.toLowerCase() ==
                _currentCategoryFilter!.toLowerCase(),
          ) // Handle null category
          .toList();
    }

    // Apply price range filter
    if (_currentMinPriceFilter != null) {
      filtered = filtered
          .where((product) => product.price >= _currentMinPriceFilter!)
          .toList();
    }
    if (_currentMaxPriceFilter != null) {
      filtered = filtered
          .where((product) => product.price <= _currentMaxPriceFilter!)
          .toList();
    }

    // This block is only for when filters are applied WITHOUT a fresh fetchProducts call
    // (e.g., user types in search bar, or selects a category)
    if (productsToFilter == null && state is InventoryLoaded) {
      // If we're applying filters without a new fetch,
      // we need to re-emit the state with the same allProducts
      // but updated filteredProducts.
      final currentLoadedState = state as InventoryLoaded;
      emit(
        InventoryLoaded(
          allProducts: currentLoadedState.allProducts,
          filteredProducts: filtered,
          message: currentLoadedState.message,
        ),
      );
    }
    print('DEBUG: _applyFilters returning filtered count: ${filtered.length}');
    return filtered;
  }

  // Individual filter methods
  void searchProducts(String query) => _searchController.add(query);

  void filterByCategory(String? category) {
    _currentCategoryFilter = category;
    _applyFilters();
  }

  void filterByPriceRange(double? min, double? max) {
    _currentMinPriceFilter = min;
    _currentMaxPriceFilter = max;
    _applyFilters();
  }

  void resetFilters() {
    _currentSearchQuery = '';
    _currentCategoryFilter = null;
    _currentMinPriceFilter = null;
    _currentMaxPriceFilter = null;
    _searchController.add(
      '',
    ); // Clear the search field internally to ensure debounce picks it up
    _applyFilters(); // Re-apply with cleared filters
  }

  @override
  Future<void> close() {
    _businessSubscription.cancel();
    _searchController.close(); // Don't forget to close the BehaviorSubject
    print('InventoryCubit closed.');
    return super.close();
  }
}
