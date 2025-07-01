// business-app/eucalypsInsight/eucalysp_insight_app/lib/features/inventory/presentation/screens/inventory_dashboard_screen.dart
import 'package:eucalysp_insight_app/features/inventory/bloc/inventory_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eucalysp_insight_app/features/inventory/bloc/inventory_cubit.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:eucalysp_insight_app/features/inventory/domain/entities/product.dart'; // Import Product entity

class InventoryDashboardScreen extends StatelessWidget {
  const InventoryDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory Analytics')),
      body: BlocBuilder<InventoryCubit, InventoryState>(
        builder: (context, state) {
          if (state is InventoryInitial || state is InventoryLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is InventoryLoaded) {
            final products = state.allProducts;

            if (products.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.analytics_outlined,
                      size: 48,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text('No inventory data available for analytics.'),
                  ],
                ),
              );
            }

            final totalItems = products.length;
            final totalValue = products.fold(
              0.0,
              (sum, item) => sum + (item.price ?? 0.0) * (item.quantity ?? 0),
            );
            final lowStockItems = products
                .where((item) => (item.quantity ?? 0) < 10)
                .length;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildMetricCard(
                          'Total Items',
                          totalItems.toString(),
                          Colors.blue,
                        ),
                        const SizedBox(width: 16),
                        _buildMetricCard(
                          'Total Value',
                          '\$${totalValue.toStringAsFixed(2)}',
                          Colors.green,
                        ),
                        const SizedBox(width: 16),
                        _buildMetricCard(
                          'Low Stock',
                          lowStockItems.toString(),
                          Colors.orange,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  AspectRatio(
                    aspectRatio: 1.5,
                    child: Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SfCircularChart(
                          title: ChartTitle(text: 'Product Categories'),
                          legend: const Legend(
                            isVisible: true,
                            overflowMode: LegendItemOverflowMode.wrap,
                          ),
                          series: <CircularSeries>[
                            PieSeries<MapEntry<String, dynamic>, String>(
                              dataSource: _groupByCategory(products),
                              xValueMapper: (entry, _) => entry.key,
                              yValueMapper: (entry, _) => entry.value,
                              dataLabelSettings: const DataLabelSettings(
                                isVisible: true,
                              ),
                              enableTooltip: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  AspectRatio(
                    aspectRatio: 1.5,
                    child: Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SfCartesianChart(
                          title: ChartTitle(text: 'Price Distribution'),
                          primaryXAxis: CategoryAxis(),
                          series: <ChartSeries>[
                            ColumnSeries<MapEntry<String, dynamic>, String>(
                              dataSource: _groupByPriceRange(products),
                              xValueMapper: (entry, _) => entry.key,
                              yValueMapper: (entry, _) => entry.value,
                              dataLabelSettings: const DataLabelSettings(
                                isVisible: true,
                              ),
                              enableTooltip: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  AspectRatio(
                    aspectRatio: 1.5,
                    child: Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SfCartesianChart(
                          title: ChartTitle(text: 'Quantity Distribution'),
                          primaryXAxis: CategoryAxis(),
                          series: <ChartSeries>[
                            BarSeries<MapEntry<String, dynamic>, String>(
                              dataSource: _groupByQuantityRange(products),
                              xValueMapper: (entry, _) => entry.key,
                              yValueMapper: (entry, _) => entry.value,
                              dataLabelSettings: const DataLabelSettings(
                                isVisible: true,
                              ),
                              enableTooltip: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          } else if (state is InventoryError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 50),
                  const SizedBox(height: 10),
                  Text('Error: ${state.message}', textAlign: TextAlign.center),
                ],
              ),
            );
          }
          return const Center(child: Text('Unknown state'));
        },
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<MapEntry<String, dynamic>> _groupByCategory(List<Product> products) {
    final Map<String, int> categoryCounts = {};
    for (final product in products) {
      final category = product.category?.isNotEmpty == true
          ? product.category!
          : 'Uncategorized';
      categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
    }
    return categoryCounts.entries.toList();
  }

  List<MapEntry<String, dynamic>> _groupByPriceRange(List<Product> products) {
    final List<Product> safeProducts = products
        .where((p) => p.price != null)
        .toList();

    // EXPLICITLY TYPING THE MAPS' VALUES TO dynamic
    const ranges = <Map<String, dynamic>>[
      // <-- Change here
      {'min': 0.0, 'max': 50.0, 'label': '\$0-\$50'},
      {'min': 50.01, 'max': 100.0, 'label': '\$51-\$100'},
      {'min': 100.01, 'max': 200.0, 'label': '\$101-\$200'},
      {'min': 200.01, 'max': double.infinity, 'label': '\$200+'},
    ];

    return ranges.map((range) {
      final count = safeProducts
          .where(
            (p) =>
                (p.price! >= (range['min'] ?? 0.0)) &&
                (p.price! <= (range['max'] ?? double.infinity)),
          ) // Added null check for range values
          .length;
      return MapEntry<String, dynamic>(range['label']! as String, count);
    }).toList();
  }

  List<MapEntry<String, dynamic>> _groupByQuantityRange(
    List<Product> products,
  ) {
    final List<Product> safeProducts = products
        .where((p) => p.quantity != null)
        .toList();

    // EXPLICITLY TYPING THE MAPS' VALUES TO dynamic
    const ranges = <Map<String, dynamic>>[
      // <-- Change here
      {'min': 0, 'max': 5, 'label': '0-5'},
      {'min': 6, 'max': 20, 'label': '6-20'},
      {'min': 21, 'max': 50, 'label': '21-50'},
      {'min': 51, 'max': double.infinity, 'label': '51+'},
    ];

    return ranges.map((range) {
      final count = safeProducts
          .where(
            (p) =>
                (p.quantity! >= (range['min'] ?? 0)) &&
                (p.quantity! <=
                    (range['max'] ??
                        double.infinity
                            .toInt())), // Added null check for range values
          )
          .length;
      return MapEntry<String, dynamic>(range['label']! as String, count);
    }).toList();
  }
}
