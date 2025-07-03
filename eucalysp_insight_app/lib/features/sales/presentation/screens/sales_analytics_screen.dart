import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eucalysp_insight_app/features/sales/bloc/sales_cubit.dart';
import 'package:eucalysp_insight_app/app/core/bloc/business_data_bloc.dart';
import 'package:eucalysp_insight_app/features/sales/domain/entities/sale.dart';

import 'package:intl/intl.dart';

class SalesAnalyticsScreen extends StatelessWidget {
  const SalesAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SalesCubit, BusinessDataState<List<Sale>>>(
      builder: (context, state) {
        if (state is BusinessDataLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is BusinessDataError) {
          return Center(
            child: Text('Error: ${(state as BusinessDataError).message}'),
          );
        } else if (state is BusinessDataLoaded<List<Sale>>) {
          final sales = state.data;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSalesTrendChart(sales.monthlySales),
                const SizedBox(height: 24),
                _buildTopProductsChart(sales.productSales),
              ],
            ),
          );
        }
        return const Center(child: Text('No data available'));
      },
    );
  }

  Widget _buildSalesTrendChart(Map<String, double> monthlySales) {
    final chartData = monthlySales.entries
        .map(
          (entry) => FlSpot(
            monthlySales.keys.toList().indexOf(entry.key).toDouble(),
            entry.value,
          ),
        )
        .toList();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sales Trend',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            monthlySales.keys.elementAt(value.toInt()),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('\$${value.toInt()}');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: chartData.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value.y);
                      }).toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 4,
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProductsChart(Map<String, double> productSales) {
    final totalSales = productSales.values.fold(
      0.0,
      (sum, value) => sum + value,
    );
    final chartData = productSales.entries.map((entry) {
      final percentage = (entry.value / totalSales * 100).round();
      return PieChartSectionData(
        value: entry.value,
        color: _getRandomColor(),
        title: '${entry.key} ($percentage%)',
        radius: 60,
      );
    }).toList();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Products',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: chartData.map((product) {
                    return PieChartSectionData(
                      value: product.value,
                      color: _getRandomColor(),
                      title: product.title,
                      radius: 60,
                    );
                  }).toList(),
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRandomColor() {
    final random = Random();
    return Colors.primaries[random.nextInt(Colors.primaries.length)];
  }
}

// Helper extension for analytics
extension SaleAnalytics on List<Sale> {
  Map<String, double> get monthlySales {
    final monthlySales = <String, double>{};
    for (final sale in this) {
      final month = DateFormat('MMM').format(sale.saleDate);
      monthlySales[month] = (monthlySales[month] ?? 0) + sale.totalAmount;
    }
    return monthlySales;
  }

  Map<String, double> get productSales {
    final productSales = <String, double>{};
    for (final sale in this) {
      for (final item in sale.items) {
        productSales[item.productName] =
            (productSales[item.productName] ?? 0) + item.subtotal;
      }
    }
    return productSales;
  }
}
