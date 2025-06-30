// lib/features/inventory/bloc/inventory_state.dart
import 'package:equatable/equatable.dart';
import 'package:eucalysp_insight_app/features/inventory/domain/entities/product.dart';

abstract class InventoryState extends Equatable {
  const InventoryState();

  @override
  List<Object?> get props => [];
}

class InventoryInitial extends InventoryState {}

class InventoryLoading extends InventoryState {}

class InventoryLoaded extends InventoryState {
  final List<Product> products;

  const InventoryLoaded({required this.products});

  @override
  List<Object?> get props => [products];
}

class InventoryError extends InventoryState {
  final String message;

  const InventoryError({required this.message});

  @override
  List<Object?> get props => [message];
}
