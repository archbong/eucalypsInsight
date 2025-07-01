// lib/features/inventory/utils/report_utils.dart
import 'dart:ui';

import 'package:eucalysp_insight_app/features/inventory/domain/entities/product.dart';
import 'package:csv/csv.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ReportUtils {
  /// Generates a CSV file from a list of products and returns the file path.
  static Future<String> generateCSV(List<Product> products) async {
    final List<List<dynamic>> csvData = [
      ['ID', 'Name', 'Category', 'SKU', 'Quantity', 'Price'],
      ...products.map(
        (product) => [
          product.id,
          product.name,
          product.category ?? 'N/A',
          product.sku,
          product.quantity,
          product.price,
        ],
      ),
    ];

    final csvString = const ListToCsvConverter().convert(csvData);
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/inventory_export.csv');
    await file.writeAsString(csvString);
    return file.path;
  }

  /// Generates a PDF file from a list of products and returns the file path.
  static Future<String> generatePDF(List<Product> products) async {
    final PdfDocument document = PdfDocument();
    final PdfPage page = document.pages.add();
    final PdfGrid grid = PdfGrid();

    grid.columns.add(count: 6);
    grid.headers.add(1);
    grid.headers[0].cells[0].value = 'ID';
    grid.headers[0].cells[1].value = 'Name';
    grid.headers[0].cells[2].value = 'Category';
    grid.headers[0].cells[3].value = 'SKU';
    grid.headers[0].cells[4].value = 'Quantity';
    grid.headers[0].cells[5].value = 'Price';

    for (final product in products) {
      final PdfGridRow row = grid.rows.add();
      row.cells[0].value = product.id;
      row.cells[1].value = product.name;
      row.cells[2].value = product.category ?? 'N/A';
      row.cells[3].value = product.sku;
      row.cells[4].value = product.quantity.toString();
      row.cells[5].value = product.price.toStringAsFixed(2);
    }

    grid.draw(page: page, bounds: const Rect.fromLTWH(0, 0, 500, 0));

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/inventory_export.pdf');
    await file.writeAsBytes(await document.save());
    document.dispose();
    return file.path;
  }

  /// Opens a file picker to share the exported file (CSV/PDF).
  /// Note: Requires platform-specific implementation (e.g., `share_plus` package).
  static Future<void> shareFile(String filePath) async {
    // Platform-specific implementation would go here.
    // Example using `share_plus`:
    // await Share.shareXFiles([XFile(filePath)]);
    throw UnimplementedError('Platform-specific sharing not implemented.');
  }
}
