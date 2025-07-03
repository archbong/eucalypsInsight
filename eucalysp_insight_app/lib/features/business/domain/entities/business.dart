import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'business.g.dart';

@HiveType(typeId: 1)
class Business extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String description;

  const Business({
    required this.id,
    required this.name,
    required this.description,
  });

  @override
  List<Object?> get props => [id, name, description];
}
