import 'package:eucalysp_insight_app/features/business/bloc/business_cubit.dart';
import 'package:eucalysp_insight_app/features/sales/domain/entities/sale.dart';
import 'package:eucalysp_insight_app/features/business/bloc/business_state.dart';
import 'package:eucalysp_insight_app/features/sales/presentation/screens/add_sale_screen.dart';
import 'package:eucalysp_insight_app/features/sales/presentation/screens/edit_sale_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eucalysp_insight_app/features/sales/bloc/sales_cubit.dart';
import 'package:eucalysp_insight_app/app/core/widgets/business_data_view.dart';
import 'package:intl/intl.dart';
// Add these imports for state classes
import 'package:eucalysp_insight_app/app/core/bloc/business_data_bloc.dart'; // For BusinessDataState
// For BusinessLoaded

class SalesListScreen extends StatelessWidget {
  const SalesListScreen({super.key});

  Widget _buildSalesList(List<Sale> sales, BuildContext context) {
    sales = List.from(sales); // Force new list instance
    if (sales.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No sales recorded for this business'),
            const SizedBox(height: 16),
            FilledButton.icon(
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
          },
          child: Card(
            margin: const EdgeInsets.only(bottom: 10),
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
      body: BlocListener<SalesCubit, BusinessDataState<List<Sale>>>(
        listener: (context, state) {
          if (state is BusinessDataLoaded<List<Sale>>) {
            final businessState = context.read<BusinessCubit>().state;
            if (businessState is BusinessLoaded &&
                businessState.selectedBusiness != null) {
              context.read<SalesCubit>().refreshData(
                businessState.selectedBusiness!.id,
              );
            }
          }
        },
        child: BusinessDataView<List<Sale>>(
          successBuilder: (sales) => _buildSalesList(List.from(sales), context),
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
            );
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
