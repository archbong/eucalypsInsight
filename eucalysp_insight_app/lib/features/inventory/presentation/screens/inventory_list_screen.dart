// lib/features/inventory/presentation/screens/inventory_list_screen.dart
import 'package:eucalysp_insight_app/features/business/bloc/business_cubit.dart';
import 'package:eucalysp_insight_app/features/business/bloc/business_state.dart';
import 'package:eucalysp_insight_app/features/inventory/bloc/inventory_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eucalysp_insight_app/features/inventory/bloc/inventory_state.dart';

class InventoryListScreen extends StatelessWidget {
  const InventoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory')),
      body: BlocBuilder<InventoryCubit, InventoryState>(
        builder: (context, state) {
          if (state is InventoryInitial) {
            // Should transition quickly to loading as BusinessCubit listener fires
            return const Center(child: Text('Initializing Inventory...'));
          } else if (state is InventoryLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is InventoryLoaded) {
            if (state.products.isEmpty) {
              return const Center(
                child: Text('No products in inventory for this business.'),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: state.products.length,
              itemBuilder: (context, index) {
                final product = state.products[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                      child: Text(
                        product.name[0], // First letter of product name
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    title: Text(product.name),
                    subtitle: Text(
                      'SKU: ${product.sku} | Qty: ${product.quantity} | \$${product.price.toStringAsFixed(2)}',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16.0),
                    onTap: () {
                      // TODO: Navigate to Product Detail/Edit Screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Tapped on ${product.name}')),
                      );
                    },
                  ),
                );
              },
            );
          } else if (state is InventoryError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 50),
                  const SizedBox(height: 10),
                  Text('Error: ${state.message}', textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // The InventoryCubit listens to BusinessCubit,
                      // so re-triggering business selection would re-fetch products.
                      // For a simple retry, we could ask BusinessCubit to re-emit its state
                      // or get the businessId from BusinessCubit directly to call fetchProducts.
                      final businessState = context.read<BusinessCubit>().state;
                      if (businessState is BusinessLoaded &&
                          businessState.selectedBusiness != null) {
                        context.read<InventoryCubit>().fetchProducts(
                          businessState.selectedBusiness!.id,
                        );
                      }
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('Unknown Inventory State'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to Add Product Screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add Product button clicked!')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
