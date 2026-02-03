import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../../core/constants/app_colors.dart';
import '../models/sale_model.dart';
import '../services/sales_service.dart';
import '../../inventory/services/inventory_service.dart';

class InvoiceDetailScreen extends StatefulWidget {
  final SaleModel sale;
  const InvoiceDetailScreen({super.key, required this.sale});

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  late Future<SaleModel> _saleFuture;

  @override
  void initState() {
    super.initState();
    _saleFuture = _loadData();
  }

  Future<SaleModel> _loadData() async {
    // 1. Fetch Sale Detail
    SaleModel sale = widget.sale;
    if (widget.sale.id != null) {
      final fetched = await SalesService().getSaleById(widget.sale.id!);
      if (fetched != null) sale = fetched;
    }

    // 2. Check each item. If product name/sku is missing, fetch products and map.
    bool needsEnrichment = false;
    for (var item in sale.items) {
      if (item.productName == null ||
          item.productName == 'Item' ||
          item.sku == null) {
        // Simple check, if it looks generic, try to find better info
        needsEnrichment = true;
        break;
      }
    }

    if (needsEnrichment) {
      try {
        // Fetch all products to lookup.
        final products = await InventoryService().searchProducts("");

        // Map products by ID
        // Note: product.id might be _id or id
        final productMap = {
          for (var p in products) (p.id ?? p.productId ?? ''): p,
        };

        // Enrich items
        final enrichedItems = sale.items.map((item) {
          if (productMap.containsKey(item.productId)) {
            final p = productMap[item.productId]!;
            // Logic to determine name: React says materialId.name
            String name = p.materialName;
            if (name == 'Unknown' || name == 'Unknown Material') {
              name = p.name;
            }

            return SaleItemModel(
              productId: item.productId,
              productName: name,
              sku: p.sku,
              qty: item.qty,
              price: item.price,
              lineTotal: item.lineTotal,
            );
          }
          return item;
        }).toList();

        // Return new SaleModel with enriched items
        return SaleModel(
          id: sale.id,
          customerId: sale.customerId,
          customerName: sale.customerName,
          saleType: sale.saleType,
          items: enrichedItems,
          subTotal: sale.subTotal,
          discount: sale.discount,
          grandTotal: sale.grandTotal,
          paymentMethod: sale.paymentMethod,
          paidAmount: sale.paidAmount,
          dueAmount: sale.dueAmount,
          note: sale.note,
          invoiceNo: sale.invoiceNo,
          createdAt: sale.createdAt,
        );
      } catch (e) {
        print("Failed to enrich invoice: $e");
      }
    }

    return sale;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice #${widget.sale.invoiceNo ?? "N/A"}'),
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () async {
              final sale = await _saleFuture;
              _printInvoice(context, sale);
            },
          ),
        ],
      ),
      body: FutureBuilder<SaleModel>(
        future: _saleFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text("Generating Invoice Preview..."),
                ],
              ),
            );
          }
          final sale = snapshot.data ?? widget.sale;
          return PdfPreview(
            build: (format) => _generatePdf(format, sale),
            canDebug: false,
            canChangeOrientation: false,
            canChangePageFormat: false,
            actions: [],
          );
        },
      ),
    );
  }

  Future<void> _printInvoice(BuildContext context, SaleModel sale) async {
    await Printing.layoutPdf(onLayout: (format) => _generatePdf(format, sale));
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format, SaleModel sale) async {
    final pdf = pw.Document();
    final currencyFormat = NumberFormat.currency(symbol: '', decimalDigits: 0);
    final date = sale.createdAt ?? DateTime.now();

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Black Diamond ERP',
                          style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          'Head Office: Karachi, Pakistan',
                          style: const pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.Text(
                          'Phone: +92 300 1234567',
                          style: const pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.Text(
                          'Email: info@blackdiamond.com',
                          style: const pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'INVOICE',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey400,
                        ),
                      ),
                      pw.Text(
                        '#${sale.invoiceNo ?? "-"}',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Date',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey400,
                        ),
                      ),
                      pw.Text(
                        DateFormat('dd-MM-yyyy').format(date),
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 30),

              // To
              pw.Text(
                'Issued To',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey400,
                ),
              ),
              pw.Text(
                sale.customerName ?? 'Walk-in Customer',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 20),

              // Table
              pw.Table(
                border: const pw.TableBorder(
                  bottom: pw.BorderSide(color: PdfColors.grey900, width: 1),
                ),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3), // Description
                  1: const pw.FlexColumnWidth(1), // Rate
                  2: const pw.FlexColumnWidth(1), // Qty
                  3: const pw.FlexColumnWidth(1.5), // Total
                },
                children: [
                  // Header
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(
                        bottom: pw.BorderSide(
                          color: PdfColors.grey900,
                          width: 2,
                        ),
                      ),
                    ),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(vertical: 8),
                        child: pw.Text(
                          'DESCRIPTION',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey600,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(vertical: 8),
                        child: pw.Text(
                          'RATE',
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey600,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(vertical: 8),
                        child: pw.Text(
                          'QTY',
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey600,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(vertical: 8),
                        child: pw.Text(
                          'TOTAL',
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Items
                  ...sale.items.map((item) {
                    return pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                          bottom: pw.BorderSide(color: PdfColors.grey200),
                        ),
                      ),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 8),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                item.productName ?? 'Item',
                                style: pw.TextStyle(
                                  fontSize: 12,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              if (item.sku != null)
                                pw.Text(
                                  item.sku!,
                                  style: const pw.TextStyle(
                                    fontSize: 10,
                                    color: PdfColors.grey500,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 10),
                          child: pw.Text(
                            currencyFormat.format(item.price),
                            textAlign: pw.TextAlign.right,
                            style: const pw.TextStyle(fontSize: 12),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 10),
                          child: pw.Text(
                            item.qty.toString(),
                            textAlign: pw.TextAlign.right,
                            style: const pw.TextStyle(fontSize: 12),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 10),
                          child: pw.Text(
                            currencyFormat.format(item.lineTotal),
                            textAlign: pw.TextAlign.right,
                            style: pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),

              pw.SizedBox(height: 20),

              // Totals
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    width: 200,
                    child: pw.Column(
                      children: [
                        _buildTotalRow(
                          'Subtotal',
                          currencyFormat.format(sale.subTotal),
                        ),
                        if (sale.discount > 0)
                          _buildTotalRow(
                            'Discount',
                            '- ${currencyFormat.format(sale.discount)}',
                            color: PdfColors.red,
                          ),
                        pw.Divider(),
                        _buildTotalRow(
                          'Total',
                          'Rs. ${currencyFormat.format(sale.grandTotal)}',
                          isBold: true,
                          fontSize: 14,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Footer
              pw.Spacer(),
              pw.Divider(color: PdfColors.grey900),
              pw.Center(
                child: pw.Text(
                  'Thank you for your business!',
                  style: const pw.TextStyle(
                    color: PdfColors.grey600,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
    return pdf.save();
  }

  pw.Widget _buildTotalRow(
    String label,
    String value, {
    bool isBold = false,
    double fontSize = 10,
    PdfColor? color,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? pw.FontWeight.bold : null,
              color: PdfColors.grey700,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? pw.FontWeight.bold : null,
              color: color ?? PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }
}
