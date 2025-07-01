import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eucalysp_insight_app/features/sales/bloc/sales_cubit.dart';
import 'package:eucalysp_insight_app/features/sales/domain/entities/sale.dart';
import 'package:eucalysp_insight_app/features/sales/domain/entities/sale_item.dart';
import 'package:intl/intl.dart';

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
    final updatedSale = widget.sale.copyWith(
      customerName: _customerController.text,
      saleDate: _saleDate,
      items: _items,
      totalAmount: _totalAmount,
    );
    context.read<SalesCubit>().updateSale(updatedSale);
    Navigator.pop(context);
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextFormField(
              controller: _customerController,
              decoration: const InputDecoration(
                labelText: 'Customer Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Sale Date',
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
            const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
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
                      onPressed: () => _showEditItemDialog(context, entry.key),
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
              decoration: const InputDecoration(labelText: 'Product Name'),
            ),
            TextFormField(
              controller: quantityController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Unit Price'),
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

  Future<void> _showEditItemDialog(BuildContext context, int index) async {
    final item = _items[index];
    final productController = TextEditingController(text: item.productName);
    final quantityController = TextEditingController(
      text: item.quantity.toString(),
    );
    final priceController = TextEditingController(
      text: item.unitPrice.toString(),
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: productController,
              decoration: const InputDecoration(labelText: 'Product Name'),
            ),
            TextFormField(
              controller: quantityController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Unit Price'),
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
