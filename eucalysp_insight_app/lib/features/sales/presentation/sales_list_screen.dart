// lib/features/sales/presentation/screens/sales_list_screen.dart
import 'package:eucalysp_insight_app/features/business/bloc/business_cubit.dart';
import 'package:eucalysp_insight_app/features/business/bloc/business_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eucalysp_insight_app/features/sales/bloc/sales_cubit.dart';
import 'package:eucalysp_insight_app/features/sales/bloc/sales_state.dart';
import 'package:intl/intl.dart'; // For date formatting, add intl dependency if not already

class SalesListScreen extends StatelessWidget {
  const SalesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sales')),
      body: BlocBuilder<SalesCubit, SalesState>(
        builder: (context, state) {
          if (state is SalesInitial) {
            return const Center(child: Text('Initializing Sales...'));
          } else if (state is SalesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SalesLoaded) {
            if (state.sales.isEmpty) {
              return const Center(
                child: Text('No sales recorded for this business.'),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: state.sales.length,
              itemBuilder: (context, index) {
                final sale = state.sales[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ExpansionTile(
                    // Using ExpansionTile to show sale items
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.tertiaryContainer,
                      child: Text(
                        DateFormat.MMMd().format(
                          sale.saleDate,
                        ), // Month and Day
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(
                            context,
                          ).colorScheme.onTertiaryContainer,
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
                                Icon(Icons.inventory_2, size: 16),
                                SizedBox(width: 8),
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
                );
              },
            );
          } else if (state is SalesError) {
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
                      final businessState = context.read<BusinessCubit>().state;
                      if (businessState is BusinessLoaded &&
                          businessState.selectedBusiness != null) {
                        context.read<SalesCubit>().fetchSales(
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
          return const Center(child: Text('Unknown Sales State'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to Add Sale Screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add Sale button clicked!')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
