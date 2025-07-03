import 'package:flutter/material.dart';
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
import 'package:eucalysp_insight_app/app/app_theme.dart'; // Import your AppColors and AppRadius

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
      child: _buildScreenContent(context, isLargeScreen),
    );
  }

  Widget _buildScreenContent(BuildContext context, bool isLargeScreen) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Inventory Management',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary, // Using your defined text color
            ),
          ),
          backgroundColor:
              AppColors.backgroundLight, // Using your defined background color
          elevation: 4.0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: Container(
              color: AppColors.backgroundLight, // Match app bar background
              child: TabBar(
                isScrollable: true,
                labelColor:
                    AppColors.primary, // Using your defined primary color
                unselectedLabelColor:
                    AppColors.textMuted, // Using your defined muted text color
                indicatorColor:
                    AppColors.primaryLight, // Using primaryLight for indicator
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
          color: AppColors
              .backgroundMuted, // Using your defined muted background color
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
                      color: AppColors.textInverse,
                    ), // Using your defined inverse text color
                  ),
                  backgroundColor:
                      AppColors.error, // Using your defined error color
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
          backgroundColor:
              AppColors.primary, // Using your defined primary color
          foregroundColor:
              AppColors.textInverse, // Using your defined inverse text color
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
