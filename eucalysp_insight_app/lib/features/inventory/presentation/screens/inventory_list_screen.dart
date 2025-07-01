// business-app/eucalypsInsight/eucalysp_insight_app/lib/features/inventory/presentation/screens/inventory_list_screen.dart
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:eucalysp_insight_app/features/inventory/utils/report_utils.dart';
import 'package:eucalysp_insight_app/features/business/bloc/business_cubit.dart'; // Used for fetching business ID if needed
import 'package:eucalysp_insight_app/features/business/bloc/business_state.dart';
import 'package:eucalysp_insight_app/features/inventory/bloc/inventory_cubit.dart';
import 'package:eucalysp_insight_app/features/inventory/presentation/screens/add_inventory_screen.dart';
import 'package:eucalysp_insight_app/features/inventory/presentation/screens/edit_inventory_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eucalysp_insight_app/features/inventory/bloc/inventory_state.dart';
import 'package:eucalysp_insight_app/features/inventory/domain/entities/product.dart';

class InventoryListScreen extends StatefulWidget {
  const InventoryListScreen({super.key});

  @override
  State<InventoryListScreen> createState() => _InventoryListScreenState();
}

class _InventoryListScreenState extends State<InventoryListScreen> {
  final Set<String> _selectedItems = {};
  bool _isSelectMode = false;

  // Local filter states that will be passed to Cubit
  String?
  _selectedCategory; // This should be updated based on cubit's current filter
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  // Temporary controllers for bulk update dialog
  final TextEditingController _bulkUpdatePriceController =
      TextEditingController();
  final TextEditingController _bulkUpdateQuantityController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    // REMOVED: context.read<InventoryCubit>().fetchProducts("biz1");
    // The InventoryCubit's constructor already listens to BusinessCubit
    // and fetches products when a business is selected.
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

  // Helper to re-apply all current filters to the Cubit
  void _applyFiltersToCubit() {
    final double? minPrice = double.tryParse(_minPriceController.text);
    final double? maxPrice = double.tryParse(_maxPriceController.text);

    context.read<InventoryCubit>().filterProducts(
      _searchController.text,
      category: _selectedCategory,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );
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
                  // Use filteredProducts if active, otherwise allProducts
                  final productsToExport = state.filteredProducts.isNotEmpty
                      ? state.filteredProducts
                      : state.allProducts;

                  if (productsToExport.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No products to export.')),
                    );
                    return;
                  }

                  // Show a dialog for CSV or PDF
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
                    const SnackBar(
                      content: Text('No products available for export.'),
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
          preferredSize: const Size.fromHeight(
            120,
          ), // Adjusted height for clarity
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ), // Added vertical padding
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _applyFiltersToCubit(); // Re-apply filters after clearing
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
                        // Use BlocBuilder to get updated categories list
                        builder: (context, state) {
                          List<String> categories = [];
                          if (state is InventoryLoaded) {
                            categories = context
                                .read<InventoryCubit>()
                                .categories;
                          }
                          return DropdownButtonHideUnderline(
                            child: DropdownButton2<String>(
                              hint: const Text('Category'),
                              value:
                                  _selectedCategory, // Set initial value from local state
                              items: [
                                // Option to clear category filter
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('All Categories'),
                                ),
                                ...categories.map(
                                  (category) => DropdownMenuItem(
                                    value: category,
                                    child: Text(category),
                                  ),
                                ),
                              ],
                              onChanged: (category) {
                                setState(() {
                                  _selectedCategory = category;
                                });
                                _applyFiltersToCubit(); // Re-apply all filters
                              },
                              buttonStyleData: ButtonStyleData(
                                height: 40,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey),
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
                            borderRadius: BorderRadius.circular(10),
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
                            borderRadius: BorderRadius.circular(10),
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
        // Listen for specific states for SnackBar/Dialog feedback
        listener: (context, state) {
          if (state is InventoryError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
          } else if (state is InventoryLoaded && state.message != null) {
            // For offline data warning
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message!)));
          }
          // You could also add InventoryActionSuccess here if you implement it
        },
        child: BlocBuilder<InventoryCubit, InventoryState>(
          builder: (context, state) {
            if (state is InventoryInitial || state is InventoryLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is InventoryLoaded) {
              // Use filteredProducts for display
              final products = state.filteredProducts;
              if (products.isEmpty) {
                // Determine if no products found due to filters or genuinely empty
                final bool isFilteredEmpty =
                    state.allProducts.isNotEmpty &&
                    state.filteredProducts.isEmpty;
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.inventory_2,
                        size: 48,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isFilteredEmpty
                            ? 'No products match your filters.'
                            : 'No products found for this business.',
                      ),
                      if (isFilteredEmpty)
                        TextButton(
                          onPressed: () {
                            // Clear all filter controllers and reset Cubit filters
                            _searchController.clear();
                            _minPriceController.clear();
                            _maxPriceController.clear();
                            setState(() {
                              _selectedCategory = null;
                            });
                            context.read<InventoryCubit>().resetFilters();
                          },
                          child: const Text('Clear Filters'),
                        ),
                    ],
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
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    direction: DismissDirection
                        .endToStart, // Only swipe left to delete
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Confirm Deletion'),
                          content: Text(
                            'Are you sure you want to delete ${product.name}?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    },
                    onDismissed: (direction) {
                      context.read<InventoryCubit>().deleteProduct(product.id);
                      // SnackBar feedback is now handled by BlocListener
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   SnackBar(content: Text('Product deleted')),
                      // );
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
                                // <--- ADD THIS LINE
                                value: context
                                    .read<
                                      InventoryCubit
                                    >(), // <--- AND THIS LINE
                                child: EditInventoryScreen(product: product),
                              ),
                            ),
                          );
                        }
                      },
                      child: Container(
                        color: _selectedItems.contains(product.id)
                            ? Colors.blue.withOpacity(0.2)
                            : null,
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              child: Text(
                                product.name[0]
                                    .toUpperCase(), // Ensure uppercase
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                            title: Text(product.name),
                            subtitle: Text(
                              'SKU: ${product.sku} | Qty: ${product.quantity} | \$${product.price.toStringAsFixed(2)}',
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
                                  )
                                : const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16.0,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            } else if (state is InventoryError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 50,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Error: ${state.message}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Re-fetch products when retry is pressed
                        final businessState = context
                            .read<BusinessCubit>()
                            .state;
                        if (businessState is BusinessLoaded &&
                            businessState.selectedBusiness != null) {
                          context.read<InventoryCubit>().fetchProducts(
                            businessState.selectedBusiness!.id,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'No business selected to fetch inventory.',
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
            return const Center(child: Text('Unknown state'));
          },
        ),
      ),
      floatingActionButton: _isSelectMode
          ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_selectedItems
                    .isNotEmpty) // Only show if items are selected
                  FloatingActionButton(
                    heroTag: 'bulk_update',
                    onPressed: () {
                      if (_selectedItems.isEmpty)
                        return; // Should not happen with the check above

                      _bulkUpdatePriceController
                          .clear(); // Clear previous values
                      _bulkUpdateQuantityController
                          .clear(); // Clear previous values

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
                              onPressed: () {
                                Navigator.pop(ctx);
                              },
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
                                    const SnackBar(
                                      content: Text(
                                        'Please enter a price or quantity to update.',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                final int itemsToUpdateCount = _selectedItems
                                    .length; // Capture count before clearing
                                Navigator.pop(
                                  ctx,
                                ); // Dismiss dialog immediately

                                await context.read<InventoryCubit>().bulkUpdate(
                                  _selectedItems.toList(),
                                  price: price,
                                  quantity: quantity,
                                );

                                // The Cubit will emit a new state, and BlocListener can show general success/error.
                                // However, for immediate user feedback on THIS action:
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Bulk update for $itemsToUpdateCount items initiated.',
                                    ),
                                  ),
                                );

                                setState(() {
                                  _selectedItems.clear();
                                  _isSelectMode = false;
                                });
                              },
                              child: const Text('Apply Update'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Icon(Icons.attach_money),
                  ),
                const SizedBox(width: 16),
                if (_selectedItems
                    .isNotEmpty) // Only show if items are selected
                  FloatingActionButton(
                    heroTag: 'bulk_delete',
                    onPressed: () async {
                      if (_selectedItems.isEmpty)
                        return; // Should not happen with the check above

                      final bool confirm = await showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Confirm Bulk Delete'),
                          content: Text(
                            'Are you sure you want to delete ${_selectedItems.length} selected items?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );

                      if (confirm) {
                        final int itemsToDeleteCount = _selectedItems
                            .length; // Capture count before clearing
                        await context.read<InventoryCubit>().bulkDelete(
                          _selectedItems.toList(),
                        );

                        // Cubit will emit new state; BlocListener handles general feedback.
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Bulk delete for $itemsToDeleteCount items initiated.',
                            ),
                          ),
                        );
                        setState(() {
                          _selectedItems.clear();
                          _isSelectMode = false;
                        });
                      }
                    },
                    child: const Icon(Icons.delete_forever),
                  ),
              ],
            )
          : FloatingActionButton(
              onPressed: () async {
                // Optionally pass current business ID if AddInventoryScreen needs it
                final businessState = context.read<BusinessCubit>().state;
                String? currentBusinessId;
                if (businessState is BusinessLoaded &&
                    businessState.selectedBusiness != null) {
                  currentBusinessId = businessState.selectedBusiness!.id;
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please select a business first to add inventory.',
                      ),
                    ),
                  );
                  return; // Don't proceed if no business selected
                }

                // Push and await result to trigger SnackBar only if product was successfully added
                final bool? productAdded = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      // <--- ADD THIS LINE
                      value: context
                          .read<InventoryCubit>(), // <--- AND THIS LINE
                      child: AddInventoryScreen(
                        // <-- Your AddInventoryScreen
                        businessId: currentBusinessId!,
                      ),
                    ),
                  ),
                );
                if (productAdded == true) {
                  // No need for a SnackBar here, AddInventoryScreen should handle its own success feedback
                  // and the list will automatically update via Cubit's fetchProducts.
                  // If you still want one, consider a more specific message or a global success listener.
                }
              },
              child: const Icon(Icons.add),
            ),
    );
  }
}
