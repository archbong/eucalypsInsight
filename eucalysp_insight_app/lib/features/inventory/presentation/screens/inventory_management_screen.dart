import 'package:flutter/material.dart';
import 'package:eucalysp_insight_app/app/app_theme.dart'; // Import your AppThemeColors and AppRadius
import 'package:eucalysp_insight_app/features/inventory/bloc/inventory_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eucalysp_insight_app/features/business/bloc/business_cubit.dart';
import 'package:eucalysp_insight_app/features/business/bloc/business_state.dart';
import 'package:eucalysp_insight_app/features/inventory/bloc/inventory_cubit.dart';
import 'package:eucalysp_insight_app/features/inventory/presentation/widgets/products_list.dart';
import 'package:eucalysp_insight_app/features/inventory/presentation/widgets/stock_levels.dart';
import 'package:eucalysp_insight_app/features/inventory/presentation/widgets/categories.dart';
import 'package:eucalysp_insight_app/features/inventory/presentation/widgets/variants.dart';
import 'package:eucalysp_insight_app/features/inventory/presentation/screens/add_inventory_screen.dart';
// import 'package:eucalysp_insight_app/app/app_theme.dart'; // This import is duplicated and not needed if the first one is sufficient

class InventoryManagementScreen extends StatelessWidget {
  const InventoryManagementScreen({super.key});

  void _onInventoryUpdated(BuildContext context) {
    final businessState = context.read<BusinessCubit>().state;
    if (businessState is BusinessLoaded &&
        businessState.selectedBusiness != null) {
      context.read<InventoryCubit>().fetchProducts(
        businessState.selectedBusiness!.id,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth > 600;

    // Access the custom theme colors once at the top of the build method
    // This is the CORRECT way to get your custom AppThemeColors
    final AppThemeColors appColors = Theme.of(
      context,
    ).extension<AppThemeColors>()!;
    // Also get the standard ColorScheme for general Material 3 colors
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return BlocListener<InventoryCubit, InventoryState>(
      listener: (context, state) {
        if (state is InventoryLoaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Inventory updated successfully'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      child: _buildScreenContent(
        context,
        isLargeScreen,
        appColors,
        colorScheme,
      ),
    );
  }

  Widget _buildScreenContent(
    BuildContext context,
    bool isLargeScreen,
    AppThemeColors appColors,
    ColorScheme colorScheme,
  ) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Inventory Management',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              // Use appColors.textPrimary from your custom extension
              color: appColors.textPrimary,
            ),
          ),
          // Use appColors.background from your custom extension
          backgroundColor: appColors.background,
          elevation: 4.0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: Container(
              // Use appColors.background from your custom extension
              color: appColors.background,
              child: TabBar(
                isScrollable: true,
                // Use appColors.primary from your custom extension
                labelColor: appColors.primary,
                // Use appColors.textSecondary from your custom extension
                unselectedLabelColor: appColors.textSecondary,
                // Using colorScheme.primaryContainer as it was already in your ColorScheme definition
                indicatorColor: colorScheme.primaryContainer,
                indicatorWeight: 4.0,
                indicatorSize: TabBarIndicatorSize.label,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.normal,
                ),
                tabs: const [
                  Tab(icon: Icon(Icons.inventory_2_outlined), text: 'Products'),
                  Tab(icon: Icon(Icons.bar_chart), text: 'Stock Levels'),
                  Tab(icon: Icon(Icons.folder_open), text: 'Categories'),
                  Tab(icon: Icon(Icons.code), text: 'Variants'),
                ],
              ),
            ),
          ),
        ),
        body: Container(
          // Use appColors.surface from your custom extension, or colorScheme.surface
          color: appColors
              .background, // It's better to use appColors.background or colorScheme.background for the body directly to ensure consistency with the scaffold
          child: TabBarView(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ProductsListWidget(),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: StockLevelsWidget(),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: CategoriesWidget(),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: VariantsWidget(),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            final businessState = context.read<BusinessCubit>().state;
            if (businessState is BusinessLoaded &&
                businessState.selectedBusiness != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddInventoryScreen(
                    businessId: businessState.selectedBusiness!.id,
                  ),
                ),
              ).then((_) => _onInventoryUpdated(context));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Please select a business first',
                    style: TextStyle(
                      // Use appColors.textInverse from your custom extension
                      color: appColors.textInverse,
                    ),
                  ),
                  // Use appColors.error from your custom extension
                  backgroundColor: appColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          label: const Text(
            'Add Item',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          icon: const Icon(Icons.add_circle_outline),
          // Use appColors.primary from your custom extension
          backgroundColor: appColors.primary,
          // Use appColors.textInverse from your custom extension
          foregroundColor: appColors.textInverse,
          elevation: 6.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppRadius.lg,
            ), // Using AppRadius for consistency
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}
