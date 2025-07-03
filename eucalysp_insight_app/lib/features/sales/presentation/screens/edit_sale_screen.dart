// lib/features/sales/presentation/screens/edit_sale_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eucalysp_insight_app/features/sales/bloc/sales_cubit.dart';
import 'package:eucalysp_insight_app/features/sales/domain/entities/sale.dart';
import 'package:eucalysp_insight_app/features/sales/domain/entities/sale_item.dart';
import 'package:intl/intl.dart';
// Don't forget to import BusinessDataState!
import 'package:eucalysp_insight_app/app/core/bloc/business_data_bloc.dart';

class EditSaleScreen extends StatefulWidget {
  final Sale sale;
  const EditSaleScreen({super.key, required this.sale});

  @override
  State<EditSaleScreen> createState() => _EditSaleScreenState();
}

class _EditSaleScreenState extends State<EditSaleScreen> {
  late final TextEditingController _customerController;
  late DateTime _saleDate;
  late List<SaleItem> _items;
  late double _totalAmount;
  final _formKey = GlobalKey<FormState>(); // Add a Form Key for validation

  @override
  void initState() {
    super.initState();
    _customerController = TextEditingController(text: widget.sale.customerName);
    _saleDate = widget.sale.saleDate;
    _items = List.from(widget.sale.items);
    _totalAmount = widget.sale.totalAmount;
  }

  @override
  void dispose() {
    _customerController.dispose();
    super.dispose();
  }

  void _updateItem(int index, SaleItem newItem) {
    setState(() {
      _totalAmount -= _items[index].subtotal;
      _items[index] = newItem;
      _totalAmount += newItem.subtotal;
    });
  }

  void _removeItem(int index) {
    setState(() {
      _totalAmount -= _items[index].subtotal;
      _items.removeAt(index);
    });
  }

  void _addItem(SaleItem item) {
    setState(() {
      _items.add(item);
      _totalAmount += item.subtotal;
    });
  }

  void _submitForm() {
    // Add form validation check
    if (_formKey.currentState!.validate() && _items.isNotEmpty) {
      final updatedSale = widget.sale.copyWith(
        customerName: _customerController.text,
        saleDate: _saleDate,
        items: _items,
        totalAmount: _totalAmount,
      );
      context.read<SalesCubit>().updateSale(updatedSale);
      // REMOVED: Navigator.pop(context) is now handled by BlocListener
    } else if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _saleDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() => _saleDate = pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Sale'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _submitForm),
        ],
      ),
      // NEW: BlocListener wraps the body content
      body: BlocListener<SalesCubit, BusinessDataState<List<Sale>>>(
        listener: (context, state) {
          switch (state) {
            case BusinessDataInitial<List<Sale>>():
              // Do nothing for initial state
              break;
            case BusinessDataLoading<List<Sale>>():
              // Optionally show a loading indicator or disable buttons while loading
              break;
            case BusinessDataLoaded<List<Sale>>():
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sale updated successfully!')),
              );
              Navigator.pop(context); // Pop ONLY on success
              break;
            case BusinessDataError<List<Sale>>(:final message):
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error updating sale: $message')),
              );
              // Don't pop, let the user retry or see the error
              break;
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            // NEW: Wrap content with Form
            key: _formKey, // NEW: Assign form key
            child: ListView(
              children: [
                TextFormField(
                  controller: _customerController,
                  decoration: const InputDecoration(
                    labelText: 'Customer Name *', // Added asterisk for required
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value?.isEmpty ?? true
                      ? 'Required field'
                      : null, // Added validator
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Sale Date *', // Added asterisk for required
                      border: OutlineInputBorder(),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(DateFormat.yMd().format(_saleDate)),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Items:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ..._items.asMap().entries.map(
                  (entry) => ListTile(
                    title: Text(entry.value.productName),
                    subtitle: Text(
                      '${entry.value.quantity} x \$${entry.value.unitPrice.toStringAsFixed(2)} = \$${entry.value.subtotal.toStringAsFixed(2)}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () =>
                              _showEditItemDialog(context, entry.key),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _removeItem(entry.key),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(),
                Text(
                  'Total: \$${_totalAmount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => _showAddItemDialog(context),
                  child: const Text('Add Item'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Item Dialogs (kept as is, but ensure text fields in dialogs also have validators if needed) ---

  Future<void> _showAddItemDialog(BuildContext context) async {
    final productController = TextEditingController();
    final quantityController = TextEditingController(text: '1');
    final priceController = TextEditingController();
    final GlobalKey<FormState> itemFormKey =
        GlobalKey<FormState>(); // New key for item dialog form

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Item'),
        content: Form(
          // Wrap content with Form
          key: itemFormKey, // Assign key
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: productController,
                decoration: const InputDecoration(labelText: 'Product Name *'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Quantity *'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value?.isEmpty ?? true || int.tryParse(value!) == null
                    ? 'Enter valid number'
                    : null,
              ),
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Unit Price *'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value?.isEmpty ?? true || double.tryParse(value!) == null
                    ? 'Enter valid price'
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (itemFormKey.currentState!.validate()) {
                // Validate item form
                final newItem = SaleItem(
                  productId: DateTime.now().millisecondsSinceEpoch.toString(),
                  productName: productController.text,
                  quantity: int.parse(quantityController.text),
                  unitPrice: double.parse(priceController.text),
                  subtotal:
                      int.parse(quantityController.text) *
                      double.parse(priceController.text),
                );
                _addItem(newItem);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditItemDialog(BuildContext context, int index) async {
    final item = _items[index];
    final productController = TextEditingController(text: item.productName);
    final quantityController = TextEditingController(
      text: item.quantity.toString(),
    );
    final priceController = TextEditingController(
      text: item.unitPrice.toString(),
    );
    final GlobalKey<FormState> itemFormKey =
        GlobalKey<FormState>(); // New key for item dialog form

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Item'),
        content: Form(
          // Wrap content with Form
          key: itemFormKey, // Assign key
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: productController,
                decoration: const InputDecoration(labelText: 'Product Name *'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Quantity *'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value?.isEmpty ?? true || int.tryParse(value!) == null
                    ? 'Enter valid number'
                    : null,
              ),
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Unit Price *'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value?.isEmpty ?? true || double.tryParse(value!) == null
                    ? 'Enter valid price'
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (itemFormKey.currentState!.validate()) {
                // Validate item form
                final updatedItem = SaleItem(
                  productId: item.productId,
                  productName: productController.text,
                  quantity: int.parse(quantityController.text),
                  unitPrice: double.parse(priceController.text),
                  subtotal:
                      int.parse(quantityController.text) *
                      double.parse(priceController.text),
                );
                _updateItem(index, updatedItem);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
