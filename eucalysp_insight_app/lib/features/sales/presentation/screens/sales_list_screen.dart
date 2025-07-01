// lib/features/sales/presentation/screens/sales_list_screen.dart
import 'package:eucalysp_insight_app/features/business/bloc/business_cubit.dart'; // Keep for FAB logic
import 'package:eucalysp_insight_app/features/sales/domain/entities/sale.dart';
import 'package:eucalysp_insight_app/features/business/bloc/business_state.dart'; // For BusinessLoaded state
import 'package:eucalysp_insight_app/features/sales/presentation/screens/add_sale_screen.dart';
import 'package:eucalysp_insight_app/features/sales/presentation/screens/edit_sale_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eucalysp_insight_app/features/sales/bloc/sales_cubit.dart';
import 'package:eucalysp_insight_app/app/core/widgets/business_data_view.dart';
import 'package:intl/intl.dart';

class SalesListScreen extends StatelessWidget {
  const SalesListScreen({super.key});

  // Moved this method OUTSIDE of the build method, directly into the class
  Widget _buildSalesList(List<Sale> sales, BuildContext context) {
    // Pass context to access Theme
    if (sales.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No sales recorded for this business'),
            const SizedBox(height: 16),
            // Optional: Add a button to add first sale if the list is empty
            FilledButton.icon(
              onPressed: () {
                final businessState = context.read<BusinessCubit>().state;
                if (businessState is BusinessLoaded &&
                    businessState.selectedBusiness != null) {
                  Navigator.push(
                    // Corrected navigation to AddSaleScreen
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddSaleScreen(
                        businessId: businessState.selectedBusiness!.id,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select a business first'),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Add First Sale'),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: sales.length,
      itemBuilder: (context, index) {
        final sale = sales[index];
        return Dismissible(
          key: Key(sale.id),
          background: Container(color: Colors.red),
          confirmDismiss: (_) async {
            return await showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Delete Sale'),
                content: const Text('Are you sure?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            );
          },
          onDismissed: (_) {
            context.read<SalesCubit>().deleteSale(sale.id);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sale deleted successfully')),
            );
          },
          child: Card(
            margin: const EdgeInsets.only(bottom: 10),
            // WRAP THE ExpansionTile WITH InkWell TO MAKE IT TAPABLE
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditSaleScreen(sale: sale),
                  ),
                );
              },
              child: ExpansionTile(
                // The onTap has been REMOVED from here
                leading: CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.tertiaryContainer,
                  child: Text(
                    DateFormat.MMMd().format(sale.saleDate),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onTertiaryContainer,
                    ),
                  ),
                ),
                title: Text('Sale ID: ${sale.id}'),
                subtitle: Text(
                  'Customer: ${sale.customerName}\nTotal: \$${sale.totalAmount.toStringAsFixed(2)}',
                ),
                children: sale.items
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 4.0,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.inventory_2, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${item.productName} (x${item.quantity})',
                              ),
                            ),
                            Text('\$${item.subtotal.toStringAsFixed(2)}'),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sales')),
      body: BusinessDataView<List<Sale>>(
        successBuilder: (sales) => _buildSalesList(sales, context),
        onRefresh: () {
          final businessState = context.read<BusinessCubit>().state;
          if (businessState is BusinessLoaded &&
              businessState.selectedBusiness != null) {
            context.read<SalesCubit>().refreshData(
              businessState.selectedBusiness!.id,
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cannot refresh: no business selected'),
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final businessState = context.read<BusinessCubit>().state;
          if (businessState is BusinessLoaded &&
              businessState.selectedBusiness != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddSaleScreen(
                  businessId: businessState.selectedBusiness!.id,
                ),
              ),
            ).then((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sale added successfully')),
              );
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Select a business first')),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
