import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../models/supplier_model.dart';
import '../controllers/supplier_controller.dart';
import 'package:intl/intl.dart';

class SupplierLedgerScreen extends StatefulWidget {
  final SupplierModel supplier;
  const SupplierLedgerScreen({super.key, required this.supplier});

  @override
  State<SupplierLedgerScreen> createState() => _SupplierLedgerScreenState();
}

class _SupplierLedgerScreenState extends State<SupplierLedgerScreen>
    with SingleTickerProviderStateMixin {
  final controller = Get.find<SupplierController>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    controller.fetchLedger(widget.supplier.id!);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showPaymentDialog() {
    final amountController = TextEditingController();
    final noteController = TextEditingController();

    Get.defaultDialog(
      title: 'Pay Supplier',
      content: Column(
        children: [
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Amount'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: noteController,
            decoration: const InputDecoration(labelText: 'Note (Optional)'),
          ),
        ],
      ),
      confirm: ElevatedButton(
        onPressed: () {
          final amt = double.tryParse(amountController.text);
          if (amt != null && amt > 0) {
            controller.paySupplier(
              widget.supplier.id!,
              amt,
              noteController.text,
            );
          } else {
            Get.snackbar('Error', 'Invalid amount');
          }
        },
        child: const Text('Pay'),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text('Cancel'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('${widget.supplier.name} Ledger'),
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.payment),
            tooltip: 'Make Payment',
            onPressed: _showPaymentDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Unpaid Purchases'),
            Tab(text: 'Payments'),
          ],
        ),
      ),
      body: Obx(() {
        if (controller.isLedgerLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = controller.ledgerData.value;
        if (data == null) {
          return const Center(child: Text('No data available'));
        }

        final totalDue = data['totalDue'] ?? 0;
        final walletBalance = data['supplier']['walletBalance'] ?? 0;
        final unpaidPurchases = data['unpaidPurchases'] as List? ?? [];
        final payments = data['payments'] as List? ?? [];

        return Column(
          children: [
            // Ledger Summary Header
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat(
                    'Total Due',
                    '\$${totalDue.toStringAsFixed(2)}',
                    AppColors.error,
                  ),
                  _buildStat(
                    'Wallet Balance',
                    '\$${walletBalance.toStringAsFixed(2)}',
                    Colors.green,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Unpaid Purchases Tab
                  _buildUnpaidPurchasesList(unpaidPurchases),
                  // Payments Tab
                  _buildPaymentsList(payments),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildUnpaidPurchasesList(List purchases) {
    if (purchases.isEmpty) {
      return const Center(child: Text('No unpaid purchases.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: purchases.length,
      itemBuilder: (context, index) {
        final p = purchases[index];
        final due = p['dueAmount'] ?? 0;
        final total = p['totalAmount'] ?? 0;
        return Card(
          child: ListTile(
            title: Text('Purchase #${p['purchaseNo'] ?? 'N/A'}'),
            subtitle: Text('Total: \$${total}'),
            trailing: Text(
              'Due: \$${due}',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentsList(List payments) {
    if (payments.isEmpty) {
      return const Center(child: Text('No payments recorded.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: payments.length,
      itemBuilder: (context, index) {
        final p = payments[index];
        final date = DateTime.tryParse(p['date'] ?? '') ?? DateTime.now();
        return Card(
          child: ListTile(
            leading: const Icon(Icons.payment, color: Colors.green),
            title: Text('Payment: \$${p['amount']}'),
            subtitle: Text(DateFormat('MMM dd, yyyy').format(date)),
            trailing: p['note'] != null
                ? SizedBox(
                    width: 100,
                    child: Text(
                      p['note'],
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    ),
                  )
                : null,
          ),
        );
      },
    );
  }
}
