import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eucalysp_insight_app/app/core/utils/pagination_wrapper.dart';
import 'package:eucalysp_insight_app/features/inventory/bloc/inventory_cubit.dart';
import 'package:eucalysp_insight_app/features/inventory/bloc/inventory_state.dart';
import 'package:eucalysp_insight_app/features/business/bloc/business_cubit.dart';
import 'package:eucalysp_insight_app/features/business/bloc/business_state.dart';
import 'package:eucalysp_insight_app/features/inventory/presentation/screens/edit_inventory_screen.dart';

class ProductsListWidget extends StatelessWidget {
  const ProductsListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InventoryCubit, InventoryState>(
      builder: (context, state) {
        if (state is InventoryLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is InventoryLoaded) {
          final cubit = context.read<InventoryCubit>();
          if (state.filteredProducts.isEmpty) {
            return const Center(
              child: Text(
                'No products found. Add a product to get started!',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }
          return PaginationWrapper(
            hasMore: state.hasMore,
            onLoadMore: cubit.loadMoreProducts,
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.filteredProducts.length,
              itemBuilder: (context, index) {
                final product = state.filteredProducts[index];
                return Dismissible(
                  key: Key(product.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirm Delete'),
                        content: const Text(
                          'Are you sure you want to delete this product?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (direction) {
                    cubit.deleteProduct(product.id);
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: const Icon(
                        Icons.shopping_bag,
                        color: Colors.blue,
                      ),
                      title: Text(product.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (product.sku.isNotEmpty)
                            Text('SKU: ${product.sku}'),
                          Text('\$${product.price.toStringAsFixed(2)}'),
                          if (product.category != null)
                            Text('Category: ${product.category}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditInventoryScreen(product: product),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        } else if (state is InventoryError) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(state.message),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
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
          );
        }
        return const Center(child: Text('Unknown state'));
      },
    );
  }
}
