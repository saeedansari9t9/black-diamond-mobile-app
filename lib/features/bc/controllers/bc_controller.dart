import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/bc_models.dart';
import '../services/bc_api_service.dart';

class BcController extends GetxController {
  final BcApiService _apiService = BcApiService();
  final _storage = GetStorage();

  // Observables
  var isLoadingDashboard = true.obs;
  var isLoadingMonthData = false.obs;
  
  var dashboardData = Rxn<BcDashboardModel>();
  var monthData = Rxn<BcMonthDataModel>();
  var allMembers = <BcMemberModel>[].obs;

  var selectedMonth = 1.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {
      isLoadingDashboard(true);
      
      // Fetch Dashboard
      final dData = await _apiService.getDashboard();
      dashboardData.value = dData;
      
      // Load current or selected month
      await loadMonthData(selectedMonth.value);
      
      // Fetch Members for general purpose
      final members = await _apiService.getMembers();
      allMembers.value = members;

    } catch (e) {
      Get.snackbar('Error', e.toString(), 
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoadingDashboard(false);
    }
  }

  Future<void> loadMonthData(int month) async {
    try {
      isLoadingMonthData(true);
      selectedMonth.value = month;
      final mData = await _apiService.getMonthData(month);
      monthData.value = mData;
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoadingMonthData(false);
    }
  }

  Future<void> updateSettings(num newContribution) async {
    try {
      await _apiService.updateSettings(newContribution);
      Get.snackbar('Success', 'Settings updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
      await loadDashboard();
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  Future<void> addMembers(List<String> names) async {
    try {
      await _apiService.addMembers(names);
      Get.snackbar('Success', 'Members added successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
      await loadDashboard(); // refresh all
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  Future<void> togglePaymentStatus(String recordId) async {
    try {
      await _apiService.togglePaymentStatus(recordId);
      // Quickly find and toggle local state for instant feedback
      if (monthData.value != null) {
        final records = monthData.value!.records;
        final index = records.indexWhere((r) => r.id == recordId);
        if (index != -1) {
          final oldRecord = records[index];
          records[index] = BcRecordModel(
            id: oldRecord.id,
            member: oldRecord.member,
            amount: oldRecord.amount,
            hasPaid: !oldRecord.hasPaid,
          );
          monthData.refresh();
        }
      }
      // Re-fetch to ensure sync with collected amount
      final mData = await _apiService.getMonthData(selectedMonth.value);
      monthData.value = mData;
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  Future<void> selectWinner(String winnerId) async {
    try {
      await _apiService.selectWinner(selectedMonth.value, winnerId);
      Get.snackbar('Success', 'Winner updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
      await loadDashboard(); // refresh to update dashboard winnersIds and current month data
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  Future<void> completeMonth() async {
    final currentData = monthData.value;
    if (currentData != null) {
      final unpaidCount = currentData.records.where((r) => !r.hasPaid).length;
      if (unpaidCount > 0) {
        Get.snackbar(
          'Cannot End Month', 
          '$unpaidCount member(s) are still Unpaid. Please clear all payments first.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.shade800,
          colorText: Colors.white,
          icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
        );
        return;
      }
    }

    try {
      _storage.write('bc_month_locked_${selectedMonth.value}', true);
      // Still try to hit the backend API just in case it exists and expects it!
      await _apiService.completeMonth(selectedMonth.value).catchError((_) {}); 
      
      Get.snackbar('Success', 'Month manually locked successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
      await loadDashboard(); // refresh
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  bool isMonthLocallyLocked() {
    return _storage.read<bool>('bc_month_locked_${selectedMonth.value}') ?? false;
  }

  List<int> getLockedMonths(int totalMonths) {
    final locked = <int>[];
    for (int i = 1; i <= totalMonths; i++) {
      if (_storage.read<bool>('bc_month_locked_$i') == true) {
        locked.add(i);
      }
    }
    return locked;
  }

  void unlockMonth(int month) {
    _storage.write('bc_month_locked_$month', false);
    if (selectedMonth.value == month) {
      loadMonthData(month); // Refresh the UI state for the current month
    }
    Get.snackbar(
      'Unlocked', 
      'Month $month has been reopened successfully.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }
}
