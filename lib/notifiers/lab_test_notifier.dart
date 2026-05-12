import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/core_lab_test.dart';
import '../services/lab_test_services.dart';

import '../models/my_lab_test.dart';

class LabTestNotifier extends AsyncNotifier<List<CoreLabTest>> {
  final LabTestServices _services = LabTestServices();
  List<CoreLabTest> _allTests = [];

  @override
  FutureOr<List<CoreLabTest>> build() async {
    _allTests = await _services.getAllCoreTests();
    return _allTests;
  }

  Future<void> refreshTests() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      _allTests = await _services.getAllCoreTests();
      return _allTests;
    });
  }

  void searchTests(String query) {
    if (query.isEmpty) {
      state = AsyncValue.data(_allTests);
      return;
    }

    final filtered = _allTests.where((test) {
      final nameLower = test.testName.toLowerCase();
      final categoryLower = test.testCategory.toLowerCase();
      final queryLower = query.toLowerCase();
      return nameLower.contains(queryLower) ||
          categoryLower.contains(queryLower);
    }).toList();

    state = AsyncValue.data(filtered);
  }
}

class MyLabTestNotifier extends AsyncNotifier<List<MyLabTest>> {
  final LabTestServices _services = LabTestServices();
  List<MyLabTest> _myTests = [];

  @override
  FutureOr<List<MyLabTest>> build() async {
    // We will refresh this from the screen once we have the labId
    return [];
  }

  Future<void> fetchMyTests(String labId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      _myTests = await _services.getInventoryByLab(labId);
      return _myTests;
    });
  }

  Future<void> addToInventory(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final newTest = await _services.createInventory(data);
      _myTests.add(newTest);
      return [..._myTests];
    });
  }

  Future<void> updateInventory(String testId, Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final updatedTest = await _services.updateInventory(testId, data);
      _myTests = _myTests.map((t) => t.testId == testId ? updatedTest : t).toList();
      return [..._myTests];
    });
  }

  Future<void> deleteFromInventory(String testId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _services.deleteInventory([testId]);
      _myTests.removeWhere((t) => t.testId == testId);
      return [..._myTests];
    });
  }

  void searchMyTests(String query) {
    if (query.isEmpty) {
      state = AsyncValue.data(_myTests);
      return;
    }

    final filtered = _myTests.where((test) {
      final nameLower = test.coreTestDetails?.testName.toLowerCase() ?? '';
      final categoryLower = test.coreTestDetails?.testCategory.toLowerCase() ?? '';
      final priceStr = test.marketPrice.toString();
      final queryLower = query.toLowerCase();
      
      return nameLower.contains(queryLower) || 
             categoryLower.contains(queryLower) || 
             priceStr.contains(queryLower);
    }).toList();

    state = AsyncValue.data(filtered);
  }
}
