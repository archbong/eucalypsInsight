// lib/features/business/domain/entities/business.dart
import 'package:equatable/equatable.dart';

class Business extends Equatable {
  final String id;
  final String name;
  final String description;

  const Business({
    required this.id,
    required this.name,
    required this.description,
  });

  @override
  List<Object?> get props => [id, name, description];
}
