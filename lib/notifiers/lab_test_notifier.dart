import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/core_lab_test.dart';
import '../services/lab_test_services.dart';

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
      return nameLower.contains(queryLower) || categoryLower.contains(queryLower);
    }).toList();

    state = AsyncValue.data(filtered);
  }
}
