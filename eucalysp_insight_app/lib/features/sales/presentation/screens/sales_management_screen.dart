import 'package:eucalysp_insight_app/features/business/bloc/business_cubit.dart';
import 'package:eucalysp_insight_app/features/sales/domain/entities/sale.dart';
import 'package:eucalysp_insight_app/features/business/bloc/business_state.dart';
import 'package:eucalysp_insight_app/features/sales/presentation/screens/add_sale_screen.dart';
import 'package:flutter/material.dart';
import 'package:eucalysp_insight_app/features/sales/presentation/screens/sales_list_screen.dart';
import 'package:eucalysp_insight_app/features/sales/presentation/screens/sales_analytics_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eucalysp_insight_app/features/sales/bloc/sales_cubit.dart';
import 'package:eucalysp_insight_app/app/core/bloc/business_data_bloc.dart';

class SalesManagementScreen extends StatelessWidget {
  const SalesManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SalesCubit, BusinessDataState<List<Sale>>>(
      listener: (context, state) {
        // Correctly cast to BusinessDataError to access 'message'
        if (state is BusinessDataError<List<Sale>>) {
          // Specify the generic type
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message), // Now 'message' is accessible
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Sales Management'),
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.list_alt), text: 'Transactions'),
                Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
              ],
            ),
          ),
          body: const TabBarView(
            children: [SalesListScreen(), SalesAnalyticsScreen()],
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: 'sales_management_fab',
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
                  // After adding a sale, trigger a refresh of data.
                  // You need to pass the businessId to refreshData.
                  // Since the AddSaleScreen has finished, we know the businessId.
                  final currentBusinessStateAfterPop = context
                      .read<BusinessCubit>()
                      .state;
                  if (currentBusinessStateAfterPop is BusinessLoaded &&
                      currentBusinessStateAfterPop.selectedBusiness != null) {
                    context.read<SalesCubit>().refreshData(
                      currentBusinessStateAfterPop.selectedBusiness!.id,
                    );
                  } else {
                    // Handle case where business might have become unselected during navigation
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Could not refresh sales: No business selected.',
                        ),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please select a business first.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
