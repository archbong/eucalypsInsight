// lib/features/dashboard/presentation/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:eucalysp_insight_app/features/dashboard/bloc/dashboard_cubit.dart';
import 'package:eucalysp_insight_app/features/dashboard/bloc/dashboard_state.dart';
import 'package:eucalysp_insight_app/features/business/bloc/business_cubit.dart';
import 'package:eucalysp_insight_app/features/business/bloc/business_state.dart';
import 'package:eucalysp_insight_app/features/dashboard/presentation/widgets/summary_card.dart';
import 'package:eucalysp_insight_app/features/dashboard/presentation/widgets/mini_chart.dart';
import 'package:eucalysp_insight_app/app/app_theme.dart';
import 'package:eucalysp_insight_app/features/dashboard/domain/models/dashboard_metric.dart';
import 'package:eucalysp_insight_app/features/dashboard/domain/models/dashboard_data.dart'; // Explicitly import DashboardData

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Fetch dashboard data when the screen initializes.
    // Listen for BusinessLoaded state to get the selected business ID.
    // This assumes DashboardCubit depends on BusinessCubit's state.
    _fetchDashboardDataOnBusinessSelection();
  }

  void _fetchDashboardDataOnBusinessSelection() {
    context.read<BusinessCubit>().stream.listen((businessState) {
      if (businessState is BusinessLoaded &&
          businessState.selectedBusiness != null) {
        // Only fetch if a business is selected and dashboard is not already loaded
        // or if it's an initial load or error state.
        final dashboardState = context.read<DashboardCubit>().state;
        if (dashboardState is! DashboardLoaded ||
            (dashboardState is DashboardLoaded &&
                dashboardState.dashboardData.welcomeMessage.isEmpty)) {
          // A simple check to avoid refetching if data is already there.
          // You might need a more robust check based on business ID if applicable.
          context.read<DashboardCubit>().fetchDashboardData(
            businessState.selectedBusiness!.id,
          );
        }
      } else if (businessState is BusinessLoaded &&
          businessState.selectedBusiness == null) {
        // If no business is selected, you might want to clear dashboard data or show a prompt.
        // For now, it will remain in its current state (e.g., initial or loaded with previous data).
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 768.0; // Responsive breakpoint

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.read<BusinessCubit>().clearSelectedBusiness();
            context.go('/business-selection');
          },
        ),
        title: const Text('Dashboard'),
      ),
      body: BlocConsumer<DashboardCubit, DashboardState>(
        listener: (context, state) {
          // Optional: Listen for specific states, e.g., show a snackbar on error.
          if (state is DashboardError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Error loading dashboard: ${state.message}',
                  style: const TextStyle(color: AppColors.textInverse),
                ),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is DashboardInitial) {
            return const Center(child: Text('Initializing Dashboard...'));
          } else if (state is DashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DashboardLoaded) {
            final dashboardData = state.dashboardData;
            return _buildDashboardContent(context, dashboardData, isMobile);
          } else if (state is DashboardError) {
            return _buildErrorState(context, state.message);
          }
          return const Center(child: Text('Unknown Dashboard State'));
        },
      ),
    );
  }

  /// Builds the main content of the dashboard when data is loaded.
  Widget _buildDashboardContent(
    BuildContext context,
    DashboardData dashboardData,
    bool isMobile,
  ) {
    // Prepare the metric data for carousel/grid from dashboardData
    final List<DashboardMetric> keyMetrics = [
      DashboardMetric(
        title: 'Total Sales',
        value: '₦${dashboardData.totalSales.toStringAsFixed(2)}',
        icon: Icons.attach_money,
        chartData: dashboardData.salesChartData,
      ),
      DashboardMetric(
        title: 'Customers',
        value: dashboardData.totalCustomers.toString(),
        icon: Icons.people,
        chartData: dashboardData.customerChartData,
      ),
      DashboardMetric(
        title: 'Inventory',
        value: dashboardData.totalInventory.toString(),
        icon: Icons.inventory,
        chartData: dashboardData.inventoryChartData,
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dashboardData.welcomeMessage,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Responsive Business Information Section (Carousel vs Grid)
          isMobile
              ? _buildBusinessInfoCarousel(keyMetrics)
              : _buildBusinessInfoGrid(keyMetrics),

          const SizedBox(height: 20),

          // Performance Overview Section
          Text(
            'Performance Overview',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          _buildMainChart(context, dashboardData.mainChartData),

          const SizedBox(height: 20),

          // Summary Cards Section (responsive with Wrap)
          // Removed redundant LayoutBuilder as Wrap handles its children's sizing
          // more dynamically. If precise control is needed for a 2-column layout
          // on desktop with specific item widths, consider a Row with Expanded children
          // instead of Wrap, or a more complex LayoutBuilder with fixed counts.
          // For a simple fluid wrap, direct `SizedBox` for `SummaryCard` within `Wrap`
          // often leads to better flexibility. However, for 2 items taking half width,
          // LayoutBuilder is fine as implemented originally. Keeping original logic here.
          Wrap(
            spacing: 16.0,
            runSpacing: 16.0,
            alignment: WrapAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final double itemWidth = isMobile
                      ? constraints.maxWidth
                      : (constraints.maxWidth / 2) - 8.0;
                  return SizedBox(
                    width: itemWidth,
                    child: SummaryCard(
                      title: 'Avg. Order Value',
                      value: dashboardData.recentTransactions.isNotEmpty
                          ? '₦${(dashboardData.totalSales / dashboardData.recentTransactions.length).toStringAsFixed(2)}'
                          : '₦0.00',
                      icon: Icons.shopping_cart,
                    ),
                  );
                },
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  final double itemWidth = isMobile
                      ? constraints.maxWidth
                      : (constraints.maxWidth / 2) - 8.0;
                  return SizedBox(
                    width: itemWidth,
                    child: SummaryCard(
                      title: 'Inventory Turnover',
                      value: dashboardData.totalInventory > 0
                          ? (dashboardData.totalSales /
                                    dashboardData.totalInventory)
                                .toStringAsFixed(1)
                          : '0.0',
                      icon: Icons.autorenew,
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Recent Activities Section
          Text(
            'Recent Activities',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          _buildRecentActivitiesList(dashboardData.recentActivities),

          const SizedBox(height: 20),

          // Recent Transactions Section
          Text(
            'Recent Transactions',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          _buildRecentTransactionsList(dashboardData.recentTransactions),
        ],
      ),
    );
  }

  /// Builds the error state widget.
  Widget _buildErrorState(BuildContext context, String errorMessage) {
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
          const Icon(Icons.error_outline, color: AppColors.error, size: 50),
          const SizedBox(height: 10),
          Text(
            'Error: $errorMessage',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.error),
          ),
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
                      style: TextStyle(color: AppColors.textInverse),
                    ),
                    backgroundColor: AppColors.error,
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

  /// Builds the carousel view for business information metrics on mobile.
  Widget _buildBusinessInfoCarousel(List<DashboardMetric> metrics) {
    return Column(
      children: [
        SizedBox(
          height: 180, // Fixed height for carousel items
          child: PageView.builder(
            controller: _pageController,
            itemCount: metrics.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: _buildMetricCard(context, metrics[index]),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            metrics.length,
            (index) => _buildDotIndicator(index, context, _currentPage),
          ),
        ),
      ],
    );
  }

  /// Builds the grid view for business information metrics on desktop.
  Widget _buildBusinessInfoGrid(List<DashboardMetric> metrics) {
    return GridView.builder(
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(), // Prevent GridView from scrolling independently
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Display 3 cards in a grid
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 1.2, // Adjust aspect ratio for card height
      ),
      itemCount: metrics.length,
      itemBuilder: (context, index) {
        return _buildMetricCard(context, metrics[index]);
      },
    );
  }

  /// Builds a single metric card using the provided DashboardMetric data.
  Widget _buildMetricCard(BuildContext context, DashboardMetric metric) {
    return Card(
      color: Theme.of(context).cardTheme.color,
      elevation: Theme.of(context).cardTheme.elevation,
      shadowColor: Theme.of(context).cardTheme.shadowColor,
      shape: Theme.of(context).cardTheme.shape,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(metric.icon, size: 40, color: AppColors.primary),
            const SizedBox(height: 12),
            Text(
              metric.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              metric.value,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.textDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Use Expanded to make the chart take available space
            if (metric.chartData != null && metric.chartData!.isNotEmpty)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: MiniChart(values: metric.chartData!.cast<double>()),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Helper method for building the page indicator dots for the carousel.
  Widget _buildDotIndicator(int index, BuildContext context, int currentPage) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8,
      width: currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: currentPage == index ? AppColors.primary : AppColors.borderLight,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  /// Builds the main performance bar chart.
  Widget _buildMainChart(BuildContext context, List<FlSpot>? chartData) {
    final List<FlSpot> effectiveChartData = chartData ?? [];
    double maxY = 6;
    if (effectiveChartData.isNotEmpty) {
      maxY =
          effectiveChartData
              .map((spot) => spot.y)
              .reduce((value, element) => max(value, element)) *
          1.2;
      if (maxY < 5) maxY = 5;
    }

    return Container(
      height: 250,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: effectiveChartData.isNotEmpty
          ? BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                groupsSpace: 12,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                        BarTooltipItem(
                          '${rod.toY.toInt()}',
                          const TextStyle(color: Colors.white),
                        ),
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
                        final index = value.toInt();
                        return Text(
                          index >= 0 && index < dayLabels.length
                              ? dayLabels[index]
                              : '',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) => Text(
                        '₦${value.toInt()}K',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      reservedSize: 40,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: effectiveChartData.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.y,
                        width: 20,
                        color: Theme.of(context).primaryColor,
                      ),
                    ],
                  );
                }).toList(),
              ),
            )
          : Center(
              child: Text(
                'No chart data available.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
    );
  }

  /// Builds the list of recent activities.
  Widget _buildRecentActivitiesList(List<String> activities) {
    if (activities.isNotEmpty) {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: activities.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                activities[index],
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.textDark),
              ),
            ),
          );
        },
      );
    } else {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'No recent activities to display.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
          ),
        ),
      );
    }
  }

  /// Builds the list of recent transactions.
  Widget _buildRecentTransactionsList(List<Transaction> transactions) {
    if (transactions.isNotEmpty) {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8.0),
            child: ListTile(
              leading: Icon(Icons.receipt_long, color: AppColors.primary),
              title: Text(
                'ID: ${transaction.id} | Amount: ₦${transaction.amount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                '${transaction.description} on ${transaction.date.toLocal().toString().split(' ')[0]}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
              ),
            ),
          );
        },
      );
    } else {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'No recent transactions.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
          ),
        ),
      );
    }
  }
}
