import 'package:eucalysp_insight_app/app/core/bloc/business_data_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eucalysp_insight_app/features/sales/bloc/sales_cubit.dart';
import 'package:eucalysp_insight_app/features/sales/domain/entities/sale.dart';
import 'package:eucalysp_insight_app/features/sales/domain/entities/sale_item.dart';
import 'package:intl/intl.dart';

class AddSaleScreen extends StatefulWidget {
  final String businessId;
  const AddSaleScreen({super.key, required this.businessId});

  @override
  State<AddSaleScreen> createState() => _AddSaleScreenState();
}

class _AddSaleScreenState extends State<AddSaleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerController = TextEditingController();
  DateTime _saleDate = DateTime.now();
  final List<SaleItem> _items = [];
  double _totalAmount = 0.0;
  String _paymentStatus = 'Pending';
  String _notes = '';

  @override
  void dispose() {
    _customerController.dispose();
    super.dispose();
  }

  void _addItem(SaleItem item) {
    setState(() {
      _items.add(item);
      _totalAmount += item.subtotal;
    });
  }

  void _removeItem(int index) {
    setState(() {
      _totalAmount -= _items[index].subtotal;
      _items.removeAt(index);
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && _items.isNotEmpty) {
      final newSale = Sale(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        businessId: widget.businessId,
        customerName: _customerController.text,
        saleDate: _saleDate,
        totalAmount: _totalAmount,
        items: List.from(_items),
        paymentStatus: _paymentStatus,
        notes: _notes,
      );
      context.read<SalesCubit>().addSale(newSale);
      Navigator.pop(context);
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Sale'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _submitForm),
        ],
      ),
      body: BlocListener<SalesCubit, BusinessDataState<List<Sale>>>(
        listener: (context, state) {
          switch (state) {
            case BusinessDataInitial<List<Sale>>():
              break;
            case BusinessDataLoading<List<Sale>>():
              break;
            case BusinessDataLoaded<List<Sale>>():
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sale saved successfully!')),
              );
              Navigator.pop(context);
              break;
            case BusinessDataError<List<Sale>>(:final message):
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error saving sale: $message')),
              );
              break;
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _customerController,
                  decoration: const InputDecoration(
                    labelText: 'Customer Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Sale Date *',
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
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _paymentStatus,
                  decoration: const InputDecoration(
                    labelText: 'Payment Status *',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Paid', child: Text('Paid')),
                    DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                    DropdownMenuItem(
                      value: 'Refunded',
                      child: Text('Refunded'),
                    ),
                  ],
                  onChanged: (value) => setState(() => _paymentStatus = value!),
                  validator: (value) => value == null ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Items:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ..._items.map(
                  (item) => ListTile(
                    title: Text(item.productName),
                    subtitle: Text(
                      '${item.quantity} x \$${item.unitPrice} = \$${item.subtotal}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _removeItem(_items.indexOf(item)),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _showAddItemDialog(context),
                  child: const Text('Add Item'),
                ),
                TextFormField(
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => _notes = value,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showAddItemDialog(BuildContext context) async {
    final productController = TextEditingController();
    final quantityController = TextEditingController(text: '1');
    final priceController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: productController,
              decoration: const InputDecoration(labelText: 'Product Name *'),
            ),
            TextFormField(
              controller: quantityController,
              decoration: const InputDecoration(labelText: 'Quantity *'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Unit Price *'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (productController.text.isNotEmpty &&
                  quantityController.text.isNotEmpty &&
                  priceController.text.isNotEmpty) {
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
}
