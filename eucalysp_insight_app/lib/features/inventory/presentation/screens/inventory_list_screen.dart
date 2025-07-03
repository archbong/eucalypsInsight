import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:eucalysp_insight_app/features/inventory/utils/report_utils.dart';
import 'package:eucalysp_insight_app/features/business/bloc/business_cubit.dart';
import 'package:eucalysp_insight_app/features/business/bloc/business_state.dart';
import 'package:eucalysp_insight_app/features/inventory/bloc/inventory_cubit.dart';
import 'package:eucalysp_insight_app/features/inventory/presentation/screens/add_inventory_screen.dart';
import 'package:eucalysp_insight_app/features/inventory/presentation/screens/edit_inventory_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eucalysp_insight_app/features/inventory/bloc/inventory_state.dart';
import 'package:eucalysp_insight_app/app/app_theme.dart'; // Import your app theme for colors and text styles

class InventoryListScreen extends StatefulWidget {
  const InventoryListScreen({super.key});

  @override
  State<InventoryListScreen> createState() => _InventoryListScreenState();
}

class _InventoryListScreenState extends State<InventoryListScreen> {
  final Set<String> _selectedItems = {};
  bool _isSelectMode = false;

  String? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  final TextEditingController _bulkUpdatePriceController =
      TextEditingController();
  final TextEditingController _bulkUpdateQuantityController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _bulkUpdatePriceController.dispose();
    _bulkUpdateQuantityController.dispose();
    super.dispose();
  }

  void _applyFiltersToCubit() {
    final double? minPrice = double.tryParse(_minPriceController.text);
    final double? maxPrice = double.tryParse(_maxPriceController.text);

    final inventoryCubit = context.read<InventoryCubit>();

    inventoryCubit.searchProducts(_searchController.text);
    inventoryCubit.filterByCategory(_selectedCategory);
    inventoryCubit.filterByPriceRange(minPrice, maxPrice);
  }

  // --- Start of UI Improvements for No Products State ---
  void _navigateToAddInventoryScreen(BuildContext context) {
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
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select a business first',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(color: AppColors.textInverse),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSelectMode
            ? Text('${_selectedItems.length} selected')
            : const Text('Inventory'),
        actions: [
          if (_isSelectMode)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() {
                _selectedItems.clear();
                _isSelectMode = false;
              }),
            ),
          if (!_isSelectMode) ...[
            IconButton(
              icon: const Icon(Icons.file_download),
              onPressed: () async {
                final state = context.read<InventoryCubit>().state;
                if (state is InventoryLoaded) {
                  final productsToExport = state.filteredProducts.isNotEmpty
                      ? state.filteredProducts
                      : state.allProducts;

                  if (productsToExport.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'No products to export.',
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(color: AppColors.textInverse),
                        ),
                      ),
                    );
                    return;
                  }

                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Export Report'),
                      content: const Text('Choose export format:'),
                      actions: [
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(ctx);
                            try {
                              final filePath = await ReportUtils.generateCSV(
                                productsToExport,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('CSV Exported to $filePath'),
                                  action: SnackBarAction(
                                    label: 'SHARE',
                                    onPressed: () async {
                                      await ReportUtils.shareFile(filePath);
                                    },
                                  ),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to export CSV: $e'),
                                ),
                              );
                            }
                          },
                          child: const Text('CSV'),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(ctx);
                            try {
                              final filePath = await ReportUtils.generatePDF(
                                productsToExport,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('PDF Exported to $filePath'),
                                  action: SnackBarAction(
                                    label: 'SHARE',
                                    onPressed: () async {
                                      await ReportUtils.shareFile(filePath);
                                    },
                                  ),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to export PDF: $e'),
                                ),
                              );
                            }
                          },
                          child: const Text('PDF'),
                        ),
                      ],
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'No products available for export.',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: AppColors.textInverse,
                        ),
                      ),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.checklist),
              onPressed: () => setState(() => _isSelectMode = true),
            ),
          ],
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppRadius.lg,
                      ), // Using AppRadius
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _applyFiltersToCubit();
                            },
                          )
                        : null,
                  ),
                  onChanged: (query) => _applyFiltersToCubit(),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: BlocBuilder<InventoryCubit, InventoryState>(
                        builder: (context, state) {
                          List<String> categories = [];
                          if (state is InventoryLoaded) {
                            categories = context
                                .read<InventoryCubit>()
                                .categories;
                          }
                          return DropdownButtonHideUnderline(
                            child: DropdownButton2<String>(
                              hint: Text(
                                'Category',
                                style: Theme.of(context).textTheme.bodyMedium!
                                    .copyWith(color: AppColors.textMuted),
                              ),
                              value: _selectedCategory,
                              items: [
                                DropdownMenuItem(
                                  value: null,
                                  child: Text(
                                    'All Categories',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ),
                                ...categories.map(
                                  (category) => DropdownMenuItem(
                                    value: category,
                                    child: Text(
                                      category,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: (category) {
                                setState(() {
                                  _selectedCategory = category;
                                });
                                _applyFiltersToCubit();
                              },
                              buttonStyleData: ButtonStyleData(
                                height: 40,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.lg,
                                  ), // Using AppRadius
                                  border: Border.all(
                                    color: AppColors.border,
                                  ), // Using AppColors
                                ),
                              ),
                              menuItemStyleData: const MenuItemStyleData(
                                height: 40,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _minPriceController,
                        decoration: InputDecoration(
                          hintText: 'Min Price',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppRadius.lg,
                            ), // Using AppRadius
                          ),
                          suffixIcon: _minPriceController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _minPriceController.clear();
                                    _applyFiltersToCubit();
                                  },
                                )
                              : null,
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => _applyFiltersToCubit(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _maxPriceController,
                        decoration: InputDecoration(
                          hintText: 'Max Price',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppRadius.lg,
                            ), // Using AppRadius
                          ),
                          suffixIcon: _maxPriceController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _maxPriceController.clear();
                                    _applyFiltersToCubit();
                                  },
                                )
                              : null,
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => _applyFiltersToCubit(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: BlocListener<InventoryCubit, InventoryState>(
        listener: (context, state) {
          if (state is InventoryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Error: ${state.message}',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: AppColors.textInverse,
                  ),
                ),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is InventoryLoaded && state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message!,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: AppColors.textInverse,
                  ),
                ),
                backgroundColor: AppColors.info, // Use info color for warnings
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: BlocBuilder<InventoryCubit, InventoryState>(
          builder: (context, state) {
            if (state is InventoryInitial || state is InventoryLoading) {
              return Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary, // Use primary color for loader
                ),
              );
            } else if (state is InventoryLoaded) {
              final products = state.filteredProducts;
              if (products.isEmpty) {
                final bool isFilteredEmpty =
                    state.allProducts.isNotEmpty &&
                    state.filteredProducts.isEmpty;
                return Center(
                  // Added a FadeTransition for a smoother appearance
                  child: FadeTransition(
                    opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: ModalRoute.of(context)!.animation!,
                        curve: Curves.easeIn,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isFilteredEmpty
                              ? Icons.filter_alt_off
                              : Icons.inventory_2_outlined,
                          size: 80, // Larger icon
                          color: AppColors.textMuted, // Muted color from theme
                        ),
                        const SizedBox(height: 24), // More vertical space
                        Text(
                          isFilteredEmpty
                              ? 'No products found matching your criteria.'
                              : 'Your inventory is empty.',
                          style: Theme.of(context).textTheme.titleLarge!
                              .copyWith(
                                color: AppColors
                                    .textDark, // Use dark text for prominence
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isFilteredEmpty
                              ? 'Try clearing your filters or adjusting them.'
                              : 'Add your first product to get started.',
                          style: Theme.of(context).textTheme.bodyLarge!
                              .copyWith(
                                color: AppColors
                                    .textLight, // Lighter text for subtitle
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        if (isFilteredEmpty)
                          ElevatedButton.icon(
                            onPressed: () {
                              _searchController.clear();
                              _minPriceController.clear();
                              _maxPriceController.clear();
                              setState(() {
                                _selectedCategory = null;
                              });
                              context.read<InventoryCubit>().resetFilters();
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Clear Filters'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors
                                  .accent3, // A neutral button for clearing filters
                              foregroundColor: AppColors.textInverse,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.lg,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                          )
                        else // If truly empty, offer to add product
                          ElevatedButton.icon(
                            onPressed: () =>
                                _navigateToAddInventoryScreen(context),
                            icon: const Icon(Icons.add_circle_outline),
                            label: const Text('Add Your First Product'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors
                                  .primary, // Primary button for adding
                              foregroundColor: AppColors.textInverse,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.lg,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 14,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Dismissible(
                    key: Key(product.id),
                    background: Container(
                      color: AppColors.error, // Use theme error color
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(
                        Icons.delete,
                        color: AppColors.textInverse,
                      ), // Use inverse text color
                    ),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(
                            'Confirm Deletion',
                            style: Theme.of(context).textTheme.titleMedium!
                                .copyWith(color: AppColors.textDark),
                          ),
                          content: Text(
                            'Are you sure you want to delete ${product.name}?',
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(color: AppColors.textLight),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: Text(
                                'Cancel',
                                style: TextStyle(color: AppColors.textLight),
                              ),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text('Delete'),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.error,
                                foregroundColor: AppColors.textInverse,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    onDismissed: (direction) {
                      context.read<InventoryCubit>().deleteProduct(product.id);
                    },
                    child: InkWell(
                      onTap: () {
                        if (_isSelectMode) {
                          setState(() {
                            if (_selectedItems.contains(product.id)) {
                              _selectedItems.remove(product.id);
                              if (_selectedItems.isEmpty) _isSelectMode = false;
                            } else {
                              _selectedItems.add(product.id);
                            }
                          });
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BlocProvider.value(
                                value: context.read<InventoryCubit>(),
                                child: EditInventoryScreen(product: product),
                              ),
                            ),
                          );
                        }
                      },
                      child: Container(
                        color: _selectedItems.contains(product.id)
                            ? AppColors.primary.withOpacity(
                                0.1,
                              ) // Use primary color for selection
                            : null,
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppRadius.lg,
                            ), // Use AppRadius
                            side: BorderSide(
                              color: _selectedItems.contains(product.id)
                                  ? AppColors
                                        .primary // Highlight border when selected
                                  : AppColors.cardBorder,
                              width: _selectedItems.contains(product.id)
                                  ? 1.5
                                  : 1.0,
                            ),
                          ),
                          elevation: _selectedItems.contains(product.id)
                              ? 4
                              : 2, // Higher elevation when selected
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              child: Text(
                                product.name[0].toUpperCase(),
                                style: Theme.of(context).textTheme.titleMedium!
                                    .copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimaryContainer,
                                    ),
                              ),
                            ),
                            title: Text(
                              product.name,
                              style: Theme.of(context).textTheme.titleMedium!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'SKU: ${product.sku} | Qty: ${product.quantity} | \$${product.price.toStringAsFixed(2)}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                if (product.variants!.isNotEmpty)
                                  Text(
                                    'Variants: ${product.variants?.map((v) => v.name).join(', ')}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(color: AppColors.textMuted),
                                  ),
                                if (product.quantity <=
                                    product.lowStockThreshold)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      'LOW STOCK!',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall!
                                          .copyWith(
                                            color: AppColors
                                                .error, // Use theme error color
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                    ),
                                  ),
                              ],
                            ),
                            trailing: _isSelectMode
                                ? Checkbox(
                                    value: _selectedItems.contains(product.id),
                                    onChanged: (bool? checked) {
                                      setState(() {
                                        if (checked == true) {
                                          _selectedItems.add(product.id);
                                        } else {
                                          _selectedItems.remove(product.id);
                                          if (_selectedItems.isEmpty) {
                                            _isSelectMode = false;
                                          }
                                        }
                                      });
                                    },
                                    activeColor: AppColors
                                        .primary, // Use primary for active checkbox
                                  )
                                : const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16.0,
                                    color:
                                        AppColors.textMuted, // Muted icon color
                                  ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }
            return Center(
              child: Text(
                'Unknown state',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            );
          },
        ),
      ),
      floatingActionButton: _isSelectMode
          ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_selectedItems.isNotEmpty)
                  FloatingActionButton.extended(
                    // Use extended for clarity
                    heroTag: 'bulk_update',
                    onPressed: () {
                      if (_selectedItems.isEmpty) return;

                      _bulkUpdatePriceController.clear();
                      _bulkUpdateQuantityController.clear();

                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Bulk Update Selected Items'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: _bulkUpdatePriceController,
                                decoration: const InputDecoration(
                                  labelText: 'New Price (optional)',
                                  hintText: 'Enter new price',
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: _bulkUpdateQuantityController,
                                decoration: const InputDecoration(
                                  labelText: 'New Quantity (optional)',
                                  hintText: 'Enter new quantity',
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () async {
                                final double? price = double.tryParse(
                                  _bulkUpdatePriceController.text,
                                );
                                final int? quantity = int.tryParse(
                                  _bulkUpdateQuantityController.text,
                                );

                                if (price == null && quantity == null) {
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Please enter a price or quantity to update.',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                              color: AppColors.textInverse,
                                            ),
                                      ),
                                      backgroundColor: AppColors.warning,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                  return;
                                }

                                final int itemsToUpdateCount =
                                    _selectedItems.length;
                                Navigator.pop(ctx);

                                await context.read<InventoryCubit>().bulkUpdate(
                                  _selectedItems.toList(),
                                  price: price,
                                  quantity: quantity,
                                );

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Bulk update for $itemsToUpdateCount items initiated.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                            color: AppColors.textInverse,
                                          ),
                                    ),
                                    backgroundColor: AppColors.info,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );

                                setState(() {
                                  _selectedItems.clear();
                                  _isSelectMode = false;
                                });
                              },
                              child: const Text('Apply Update'),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.textInverse,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    label: const Text('Update'),
                    icon: const Icon(Icons.edit),
                    backgroundColor: AppColors.primaryLight,
                    foregroundColor: AppColors.textInverse,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                const SizedBox(width: 16),
                if (_selectedItems.isNotEmpty)
                  FloatingActionButton.extended(
                    // Use extended for clarity
                    heroTag: 'bulk_delete',
                    onPressed: () async {
                      if (_selectedItems.isEmpty) return;

                      final bool confirm =
                          await showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Confirm Bulk Delete'),
                              content: Text(
                                'Are you sure you want to delete ${_selectedItems.length} selected items?',
                                style: Theme.of(context).textTheme.bodyMedium!
                                    .copyWith(color: AppColors.textLight),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                      color: AppColors.textLight,
                                    ),
                                  ),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: const Text('Delete All'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.error,
                                    foregroundColor: AppColors.textInverse,
                                  ),
                                ),
                              ],
                            ),
                          ) ??
                          false; // Handle null if dialog is dismissed

                      if (confirm) {
                        final int itemsToDeleteCount = _selectedItems.length;
                        await context.read<InventoryCubit>().bulkDelete(
                          _selectedItems.toList(),
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${itemsToDeleteCount} items deleted.',
                              style: Theme.of(context).textTheme.bodyMedium!
                                  .copyWith(color: AppColors.textInverse),
                            ),
                            backgroundColor:
                                AppColors.success, // Success color for deletion
                            behavior: SnackBarBehavior.floating,
                          ),
                        );

                        setState(() {
                          _selectedItems.clear();
                          _isSelectMode = false;
                        });
                      }
                    },
                    label: const Text('Delete'),
                    icon: const Icon(Icons.delete_forever),
                    backgroundColor: AppColors.error,
                    foregroundColor: AppColors.textInverse,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
              ],
            )
          : FloatingActionButton.extended(
              onPressed: () => _navigateToAddInventoryScreen(context),
              label: const Text('Add Product'),
              icon: const Icon(Icons.add_shopping_cart), // More relevant icon
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textInverse,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppRadius.lg,
                ), // Consistent radius
              ),
              elevation: 6.0,
            ),
    );
  }
}
