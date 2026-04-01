import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/bc_controller.dart';
import '../models/bc_models.dart';

class BcDashboardScreen extends StatelessWidget {
  const BcDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Put controller in memory
    final BcController controller = Get.put(BcController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'BC Management',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsDialog(context, controller),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.secondary,
        onPressed: () => _showAddMembersBottomSheet(context, controller),
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
      body: Obx(() {
        if (controller.isLoadingDashboard.value &&
            controller.dashboardData.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final dashboard = controller.dashboardData.value;
        if (dashboard == null) {
          return const Center(child: Text('No data found.'));
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadDashboard(),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary Cards
                      _buildSummaryCards(dashboard),
                      const SizedBox(height: 24),

                      // Month Selector
                      const Text(
                        'Months',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildMonthSelector(controller, dashboard.totalMembers),
                      const SizedBox(height: 24),

                      // Winner Selection
                      _buildWinnerSelection(controller, dashboard),
                      const SizedBox(height: 24),

                      // Payments List Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Payments List',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (controller.monthData.value != null &&
                              controller.monthData.value!.collectedAmount > 0)
                            Text(
                              'Collected: \Rs ${controller.monthData.value!.collectedAmount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.success,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              // Payments List
              _buildPaymentsList(controller),

              // Bottom spacing for FAB
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSummaryCards(BcDashboardModel dashboard) {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            title: 'Total Members',
            value: dashboard.totalMembers.toString(),
            icon: Icons.group,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoCard(
            title: 'Total Pot',
            value: '\Rs ${dashboard.totalPot.toStringAsFixed(0)}',
            icon: Icons.account_balance_wallet,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector(BcController controller, int totalMonths) {
    if (totalMonths == 0) {
      return const Text(
        'Add members to generate months',
        style: TextStyle(color: AppColors.textSecondary),
      );
    }
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: totalMonths,
        itemBuilder: (context, index) {
          final monthNum = index + 1;
          final isSelected = controller.selectedMonth.value == monthNum;
          return GestureDetector(
            onTap: () => controller.loadMonthData(monthNum),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.secondary : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.secondary
                      : Colors.grey.withOpacity(0.3),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.secondary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Text(
                'Month $monthNum',
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWinnerSelection(
    BcController controller,
    BcDashboardModel dashboard,
  ) {
    if (controller.isLoadingMonthData.value) {
      return const Center(child: CircularProgressIndicator());
    }

    final monthData = controller.monthData.value;
    if (monthData == null) return const SizedBox.shrink();

    final hasWinner = monthData.monthState.winner != null;
    final isCompleted = controller
        .isMonthLocallyLocked(); // Use our manual lock!

    Widget content;

    if (hasWinner) {
      content = Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(isCompleted ? 0.05 : 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.success.withOpacity(isCompleted ? 0.2 : 0.3),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.success.withOpacity(
                isCompleted ? 0.6 : 1.0,
              ),
              child: const Icon(Icons.emoji_events, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Month Winner',
                    style: TextStyle(
                      color: AppColors.success.withOpacity(
                        isCompleted ? 0.8 : 1.0,
                      ),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    monthData.monthState.winner!.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isCompleted ? Colors.grey[700] : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            if (!isCompleted)
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.error),
                onPressed: () =>
                    controller.selectWinner(''), // empty string to clear
              ),
          ],
        ),
      );
    } else {
      if (isCompleted) {
        content = Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              'This month was ended without a winner.',
              style: TextStyle(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        );
      } else {
        // Find eligible winners (members not in dashboard.winnersIds)
        final members = controller.allMembers;
        final eligibleMembers = members
            .where((m) => !dashboard.winnersIds.contains(m.id))
            .toList();

        content = Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: const Text('Select Pot Winner'),
              items: eligibleMembers.map((member) {
                return DropdownMenuItem<String>(
                  value: member.id,
                  child: Text(member.name),
                );
              }).toList(),
              onChanged: (winnerId) {
                if (winnerId != null) {
                  controller.selectWinner(winnerId);
                }
              },
            ),
          ),
        );
      }
    }

    return Column(
      children: [
        content,
        if (!isCompleted) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.lock_outline, color: Colors.white),
              label: Text(
                'End Month ${controller.selectedMonth.value}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Get.dialog(
                  AlertDialog(
                    title: const Text('End Month'),
                    content: const Text(
                      'Are you sure you want to end this month? Once ended, no further changes can be made to payments or the winner.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                        ),
                        onPressed: () {
                          Get.back();
                          controller.completeMonth();
                        },
                        child: const Text(
                          'Confirm',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPaymentsList(BcController controller) {
    if (controller.isLoadingMonthData.value) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    final records = controller.monthData.value?.records ?? [];
    final isCompleted = controller.isMonthLocallyLocked(); // Use manual lock

    if (records.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Text(
              'No payment records found',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final record = records[index];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              backgroundColor: AppColors.secondary.withOpacity(0.1),
              child: Text(
                record.member.name.isNotEmpty
                    ? record.member.name[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              record.member.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isCompleted ? Colors.grey[700] : Colors.black,
              ),
            ),
            subtitle: Text('\Rs ${record.amount.toStringAsFixed(0)}'),
            trailing: GestureDetector(
              onTap: isCompleted
                  ? null
                  : () => controller.togglePaymentStatus(record.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: record.hasPaid
                      ? AppColors.success.withOpacity(isCompleted ? 0.05 : 0.1)
                      : AppColors.error.withOpacity(isCompleted ? 0.05 : 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        (record.hasPaid ? AppColors.success : AppColors.error)
                            .withOpacity(isCompleted ? 0.4 : 1.0),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      record.hasPaid ? Icons.check_circle : Icons.cancel,
                      color:
                          (record.hasPaid ? AppColors.success : AppColors.error)
                              .withOpacity(isCompleted ? 0.5 : 1.0),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      record.hasPaid ? 'Paid' : 'Unpaid',
                      style: TextStyle(
                        color:
                            (record.hasPaid
                                    ? AppColors.success
                                    : AppColors.error)
                                .withOpacity(isCompleted ? 0.5 : 1.0),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }, childCount: records.length),
    );
  }

  void _showSettingsDialog(BuildContext context, BcController controller) {
    final textController = TextEditingController(
      text:
          controller.dashboardData.value?.monthlyContribution.toString() ?? '',
    );

    final totalMonths = controller.dashboardData.value?.totalMonths ?? 0;
    final lockedMonths = controller.getLockedMonths(totalMonths);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: textController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Monthly Contribution (\Rs)',
                  border: OutlineInputBorder(),
                ),
              ),
              if (lockedMonths.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text(
                  'Locked Months',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tap on a month to unlock it again.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: lockedMonths.map((m) {
                    return ActionChip(
                      label: Text('Month $m'),
                      avatar: const Icon(
                        Icons.lock_open,
                        size: 16,
                        color: AppColors.secondary,
                      ),
                      backgroundColor: AppColors.secondary.withOpacity(0.1),
                      side: BorderSide(
                        color: AppColors.secondary.withOpacity(0.5),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        controller.unlockMonth(m);
                      },
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
              ),
              onPressed: () {
                final val = double.tryParse(textController.text);
                if (val != null) {
                  controller.updateSettings(val);
                  Navigator.pop(context);
                }
              },
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showAddMembersBottomSheet(
    BuildContext context,
    BcController controller,
  ) {
    final textController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Members',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Enter member names separated by commas.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: textController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'e.g. Ahmed, Ali, Zaid',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    final text = textController.text.trim();
                    if (text.isNotEmpty) {
                      final names = text
                          .split(',')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .toList();
                      if (names.isNotEmpty) {
                        controller.addMembers(names);
                        Navigator.pop(context);
                      }
                    }
                  },
                  child: const Text(
                    'Add Members',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
