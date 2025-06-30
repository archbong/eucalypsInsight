// lib/features/dashboard/domain/entities/transaction.dart
import 'package:equatable/equatable.dart';

class Transaction extends Equatable {
  final String id;
  final double amount;
  final DateTime date;
  final String description; // Added for more realism

  const Transaction({
    required this.id,
    required this.amount,
    required this.date,
    this.description = 'General Transaction', // Default description
  });

  @override
  List<Object?> get props => [id, amount, date, description];
}
