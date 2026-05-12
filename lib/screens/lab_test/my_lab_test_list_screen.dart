import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../providers/auth_provider.dart';
import '../../providers/lab_test_provider.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/side_nav_bar.dart';
import '../../cards/lab_test/lab_test_card.dart';
import '../../theme/app_theme.dart';

class MyLabTestListScreen extends ConsumerStatefulWidget {
  const MyLabTestListScreen({super.key});

  @override
  ConsumerState<MyLabTestListScreen> createState() => _MyLabTestListScreenState();
}

class _MyLabTestListScreenState extends ConsumerState<MyLabTestListScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider).user;
      if (user?.id != null) {
        ref.read(myLabTestProvider.notifier).fetchMyTests(user!.id!);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final testsAsync = ref.watch(myLabTestProvider);
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _isSearching
          ? _buildSearchAppBar()
          : CustomAppBar(
              title: "My Inventory",
              subtitle: "Tests in your lab",
              showDrawer: true,
              showBackButton: false,
              actions: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isSearching = true;
                    });
                  },
                  icon: const Icon(IconsaxPlusLinear.search_normal, color: AppColors.textPrimary),
                ),
              ],
            ),
      drawer: const SideNavBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          if (user?.id != null) {
            await ref.read(myLabTestProvider.notifier).fetchMyTests(user!.id!);
          }
        },
        child: testsAsync.when(
          data: (tests) {
            if (tests.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(IconsaxPlusLinear.box, size: 64, color: AppColors.textTertiary.withAlpha(100)),
                    const SizedBox(height: 16),
                    Text(
                      "No tests in inventory",
                      style: AppTextStyles.cardTitle.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to Available Tests
                        context.go('/test-management');
                      },
                      child: const Text("Browse Available Tests"),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              itemCount: tests.length,
              itemBuilder: (context, index) {
                return LabTestCard(test: tests[index]);
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
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: IconButton(
        onPressed: () {
          setState(() {
            _isSearching = false;
            _searchController.clear();
            ref.read(myLabTestProvider.notifier).searchMyTests("");
          });
        },
        icon: const Icon(IconsaxPlusLinear.arrow_left_1, color: AppColors.textPrimary),
      ),
      title: TextField(
        controller: _searchController,
        autofocus: true,
        style: AppTextStyles.description.copyWith(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: "Search by name, category or price...",
          border: InputBorder.none,
          hintStyle: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) {
          ref.read(myLabTestProvider.notifier).searchMyTests(value);
        },
      ),
      actions: [
        if (_searchController.text.isNotEmpty)
          IconButton(
            onPressed: () {
              _searchController.clear();
              ref.read(myLabTestProvider.notifier).searchMyTests("");
              setState(() {});
            },
            icon: const Icon(IconsaxPlusLinear.close_circle, color: AppColors.textTertiary),
          ),
      ],
    );
  }
}
