import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/core_lab_test.dart';
import '../models/my_lab_test.dart';
import '../notifiers/lab_test_notifier.dart';

final coreLabTestProvider =
    AsyncNotifierProvider<LabTestNotifier, List<CoreLabTest>>(() {
      return LabTestNotifier();
    });

final myLabTestProvider =
    AsyncNotifierProvider<MyLabTestNotifier, List<MyLabTest>>(() {
      return MyLabTestNotifier();
    });
