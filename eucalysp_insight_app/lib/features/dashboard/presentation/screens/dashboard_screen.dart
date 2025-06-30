// lib/features/dashboard/presentation/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eucalysp_insight_app/features/dashboard/bloc/dashboard_cubit.dart';
import 'package:eucalysp_insight_app/features/dashboard/bloc/dashboard_state.dart';
import 'package:eucalysp_insight_app/features/business/bloc/business_cubit.dart';
import 'package:eucalysp_insight_app/features/business/bloc/business_state.dart';
import 'package:eucalysp_insight_app/features/dashboard/domain/entities/transaction.dart'; // NEW import for Transaction

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          if (state is DashboardInitial) {
            return const Center(child: Text('Initializing Dashboard...'));
          } else if (state is DashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DashboardLoaded) {
            final dashboardData =
                state.dashboardData; // Get the DashboardData object

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dashboardData.welcomeMessage, // Access from dashboardData
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Key Metrics',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildMetricCard(
                                context,
                                'Total Sales',
                                '\$${dashboardData.totalSales.toStringAsFixed(2)}', // Access from dashboardData
                                Icons.attach_money,
                              ),
                              _buildMetricCard(
                                context,
                                'Customers',
                                dashboardData.totalCustomers
                                    .toString(), // Access from dashboardData
                                Icons.people,
                              ),
                              _buildMetricCard(
                                // NEW: Display Total Inventory
                                context,
                                'Inventory',
                                dashboardData.totalInventory
                                    .toString(), // Access from dashboardData
                                Icons.inventory,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Recent Activities',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 10),
                  if (dashboardData
                      .recentActivities
                      .isNotEmpty) // Access from dashboardData
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: dashboardData
                          .recentActivities
                          .length, // Access from dashboardData
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              dashboardData.recentActivities[index],
                            ), // Access from dashboardData
                          ),
                        );
                      },
                    )
                  else
                    const Center(
                      child: Text('No recent activities to display.'),
                    ),

                  const SizedBox(height: 20), // Spacer for transactions
                  Text(
                    'Recent Transactions', // NEW section for transactions
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 10),
                  if (dashboardData.recentTransactions.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: dashboardData.recentTransactions.length,
                      itemBuilder: (context, index) {
                        final transaction =
                            dashboardData.recentTransactions[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8.0),
                          child: ListTile(
                            leading: const Icon(Icons.money),
                            title: Text(
                              'ID: ${transaction.id} | Amount: \$${transaction.amount.toStringAsFixed(2)}',
                            ),
                            subtitle: Text(
                              '${transaction.description} on ${transaction.date.toLocal().toString().split(' ')[0]}',
                            ),
                          ),
                        );
                      },
                    )
                  else
                    const Center(child: Text('No recent transactions.')),
                ],
              ),
            );
          } else if (state is DashboardError) {
            final businessState = context.watch<BusinessCubit>().state;
            String? currentBusinessId;
            if (businessState is BusinessLoaded &&
                businessState.selectedBusiness != null) {
              currentBusinessId = businessState.selectedBusiness!.id;
            }

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
                      if (currentBusinessId != null) {
                        context.read<DashboardCubit>().fetchDashboardData(
                          currentBusinessId,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'No business selected to retry dashboard data.',
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('Unknown Dashboard State'));
        },
      ),
    );
  }

  // _buildMetricCard helper method remains the same
  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    return Expanded(
      child: Card(
        color: Theme.of(context).colorScheme.secondaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Icon(
                icon,
                size: 30,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
        ),
      ),
    );
  }
}
