import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eucalysp_insight_app/features/inventory/bloc/inventory_cubit.dart';
import 'package:eucalysp_insight_app/features/inventory/bloc/inventory_state.dart';

class VariantsWidget extends StatelessWidget {
  const VariantsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InventoryCubit, InventoryState>(
      builder: (context, state) {
        if (state is InventoryLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is InventoryLoaded) {
          final products = state.filteredProducts;
          if (products.isEmpty) {
            return const Center(child: Text('No products found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  title: Text(
                    '${product.name} Variants',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  children: [
                    if (product.variants!.isNotEmpty)
                      ...product.variants!.map(
                        (variant) => ListTile(
                          leading: const Icon(Icons.category, size: 20),
                          title: Text(variant.name),
                          subtitle: Text(variant.name),
                        ),
                      )
                    else
                      const ListTile(title: Text('No variants available')),
                  ],
                ),
              );
            },
          );
        } else if (state is InventoryError) {
          return Center(child: Text(state.message));
        }
        return const Center(child: Text('Unknown state'));
      },
    );
  }
}
