// lib/features/inventory/bloc/inventory_state.dart
import 'package:eucalysp_insight_app/features/inventory/domain/entities/product.dart';
import 'package:flutter/foundation.dart'; // For @immutable

@immutable
sealed class InventoryState {}

class InventoryInitial extends InventoryState {}

class InventoryLoading extends InventoryState {}

// Renamed InventoryLoaded to contain both all products and filtered products
// This allows the Cubit to manage filters without losing the original data
class InventoryLoaded extends InventoryState {
  final List<Product> allProducts;
  final List<Product> filteredProducts;
  final bool hasMore; // Optional message for UI (e.g., offline data warning)
  final String? message;

  InventoryLoaded({
    required this.allProducts,
    required this.filteredProducts,
    this.hasMore = false,
    this.message,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InventoryLoaded &&
        listEquals(allProducts, other.allProducts) &&
        listEquals(filteredProducts, other.filteredProducts) &&
        message == other.message;
  }

  @override
  int get hashCode => Object.hash(
    Object.hashAll(allProducts),
    Object.hashAll(filteredProducts),
    message,
  );
}

class InventoryError extends InventoryState {
  final String message;

  InventoryError({required this.message});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InventoryError && message == other.message;
  }

  @override
  int get hashCode => message.hashCode;
}

// Optional: Add a success state for specific feedback on CRUD operations
// class InventoryActionSuccess extends InventoryState {
//   final String message;
//   InventoryActionSuccess({required this.message});
// }
