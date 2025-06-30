// lib/features/business/bloc/business_state.dart
import 'package:equatable/equatable.dart';
import 'package:eucalysp_insight_app/features/business/domain/entities/business.dart';

abstract class BusinessState extends Equatable {
  const BusinessState();

  @override
  List<Object?> get props => [];
}

class BusinessInitial extends BusinessState {}

class BusinessLoading extends BusinessState {}

class BusinessLoaded extends BusinessState {
  final List<Business> availableBusinesses;
  final Business? selectedBusiness; // Null if no business is selected yet

  const BusinessLoaded({
    required this.availableBusinesses,
    this.selectedBusiness,
  });

  @override
  List<Object?> get props => [availableBusinesses, selectedBusiness];
}

class BusinessError extends BusinessState {
  final String message;

  const BusinessError({required this.message});

  @override
  List<Object?> get props => [message];
}
