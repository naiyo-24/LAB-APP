import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/test_package.dart';
import '../notifiers/package_notifier.dart';

final packageProvider = AsyncNotifierProvider<PackageNotifier, List<TestPackage>>(() {
  return PackageNotifier();
});
