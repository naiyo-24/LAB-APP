import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:lab_app/widgets/side_nav_bar.dart';
import '../../providers/lab_test_provider.dart';
import '../../widgets/app_bar.dart';
import '../../cards/lab_test/core_lab_test_card.dart';
import '../../theme/app_theme.dart';

class CoreLabTestListScreen extends ConsumerStatefulWidget {
  const CoreLabTestListScreen({super.key});

  @override
  ConsumerState<CoreLabTestListScreen> createState() =>
      _CoreLabTestListScreenState();
}

class _CoreLabTestListScreenState extends ConsumerState<CoreLabTestListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final testsAsync = ref.watch(coreLabTestProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        showBackButton: false,
        showDrawer: true,
        title: "Available Tests",
        subtitle: "Add Tests to Your Inventory",
        actions: [
          IconButton(
            onPressed: () {
              context.push('/search-core-tests');
            },
            icon: const Icon(
              IconsaxPlusLinear.search_normal,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
      drawer: const SideNavBar(),
      body: RefreshIndicator(
        onRefresh: () => ref.read(coreLabTestProvider.notifier).refreshTests(),
        child: testsAsync.when(
          data: (tests) {
            if (tests.isEmpty) {
              return const Center(child: Text("No tests found"));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tests.length,
              itemBuilder: (context, index) {
                return CoreLabTestCard(test: tests[index]);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text("Error: $err")),
        ),
      ),
    );
  }
}
