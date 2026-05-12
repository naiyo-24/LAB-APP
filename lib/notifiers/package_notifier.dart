import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/test_package.dart';
import '../services/test_package_services.dart';

class PackageNotifier extends AsyncNotifier<List<TestPackage>> {
  final TestPackageServices _services = TestPackageServices();
  List<TestPackage> _allPackages = [];

  @override
  FutureOr<List<TestPackage>> build() async {
    return [];
  }

  Future<void> fetchPackages(String labId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      _allPackages = await _services.getPackagesByLab(labId);
      return _allPackages;
    });
  }

  Future<void> createPackage(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final created = await _services.createPackage(data);
      final enrichedPackage = await _services.getPackageById(created.packageId);
      _allPackages.add(enrichedPackage);
      return [..._allPackages];
    });
  }

  Future<void> updatePackage(String packageId, Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _services.updatePackage(packageId, data);
      final updatedPackage = await _services.getPackageById(packageId);
      _allPackages = _allPackages
          .map((p) => p.packageId == packageId ? updatedPackage : p)
          .toList();
      return [..._allPackages];
    });
  }

  Future<void> deletePackage(String packageId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _services.deletePackage(packageId);
      _allPackages.removeWhere((p) => p.packageId == packageId);
      return [..._allPackages];
    });
  }

  void searchPackages(String query) {
    if (query.isEmpty) {
      state = AsyncValue.data(_allPackages);
      return;
    }

    final queryLower = query.toLowerCase();
    final filtered = _allPackages.where((p) {
      final nameLower = p.packageName.toLowerCase();
      final priceStr = p.packageFinalPrice.toString();
      return nameLower.contains(queryLower) || priceStr.contains(queryLower);
    }).toList();

    state = AsyncValue.data(filtered);
  }
}
