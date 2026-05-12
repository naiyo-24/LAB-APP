import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  bool _isSearching = false;
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
      appBar: _isSearching
          ? _buildSearchAppBar()
          : CustomAppBar(
              showBackButton: false,
              showDrawer: true,
              title: "Available Tests",
              subtitle: "Add Tests to Your Inventory",
              actions: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isSearching = true;
                    });
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

  PreferredSizeWidget _buildSearchAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 2,
      leading: IconButton(
        onPressed: () {
          setState(() {
            _isSearching = false;
            _searchController.clear();
            ref.read(coreLabTestProvider.notifier).searchTests("");
          });
        },
        icon: const Icon(
          IconsaxPlusLinear.arrow_left_1,
          color: AppColors.textPrimary,
        ),
      ),
      title: TextField(
        controller: _searchController,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: "Search by name or category...",
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.grey),
        ),
        onChanged: (value) {
          ref.read(coreLabTestProvider.notifier).searchTests(value);
        },
      ),
      actions: [
        if (_searchController.text.isNotEmpty)
          IconButton(
            onPressed: () {
              _searchController.clear();
              ref.read(coreLabTestProvider.notifier).searchTests("");
              setState(() {});
            },
            icon: const Icon(
              IconsaxPlusLinear.close_circle,
              color: Colors.grey,
            ),
          ),
      ],
    );
  }
}
