// lib/features/inventory/domain/entities/variant.dart
import 'package:hive/hive.dart';

part 'variant.g.dart';

@HiveType(typeId: 2) // Unique Hive ID
class Variant {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name; // e.g., "Size: Large", "Color: Red"
  @HiveField(2)
  final int stock;

  const Variant({required this.id, required this.name, required this.stock});
}
