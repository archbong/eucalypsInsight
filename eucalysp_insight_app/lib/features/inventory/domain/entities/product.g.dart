// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductAdapter extends TypeAdapter<Product> {
  @override
  final int typeId = 0;

  @override
  Product read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Product(
      id: fields[0] as String,
      businessId: fields[1] as String,
      name: fields[2] as String,
      sku: fields[3] as String,
      description: fields[4] as String,
      quantity: (fields[5] as int?) ?? 0,
      price: (fields[6] as double?) ?? 0.0,
      category: fields[7] as String?,
      variants: (fields[8] as List?)?.cast<Variant>(),
      lowStockThreshold: (fields[9] as int?) ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, Product obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.businessId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.sku)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.quantity)
      ..writeByte(6)
      ..write(obj.price)
      ..writeByte(7)
      ..write(obj.category)
      ..writeByte(8)
      ..write(obj.variants)
      ..writeByte(9)
      ..write(obj.lowStockThreshold);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
