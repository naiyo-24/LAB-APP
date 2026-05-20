import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../providers/auth_provider.dart';
import '../../providers/package_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/side_nav_bar.dart';
import '../../cards/package/package_card.dart';
import '../../cards/package/package_bottomsheet.dart';

class MyTestPackagesScreen extends ConsumerStatefulWidget {
  const MyTestPackagesScreen({super.key});

  @override
  ConsumerState<MyTestPackagesScreen> createState() => _MyTestPackagesScreenState();
}

class _MyTestPackagesScreenState extends ConsumerState<MyTestPackagesScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider).user;
      if (user?.id != null) {
        ref.read(packageProvider.notifier).fetchPackages(user!.id!);
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
    final packagesAsync = ref.watch(packageProvider);
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _isSearching
          ? _buildSearchAppBar()
          : CustomAppBar(
              title: "Test Packages",
              subtitle: "Manage your lab bundles",
              showDrawer: true,
              showBackButton: false,
              actions: [
                IconButton(
                  onPressed: () => context.push('/create-package'),
                  icon: const Icon(IconsaxPlusLinear.add, color: AppColors.textPrimary),
                ),
                IconButton(
                  onPressed: () => setState(() => _isSearching = true),
                  icon: const Icon(IconsaxPlusLinear.search_normal, color: AppColors.textPrimary),
                ),
              ],
            ),
      drawer: const SideNavBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          if (user?.id != null) {
            await ref.read(packageProvider.notifier).fetchPackages(user!.id!);
          }
        },
        child: packagesAsync.when(
          data: (packages) {
            if (packages.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      IconsaxPlusLinear.archive_add,
                      size: 64,
                      color: AppColors.textTertiary.withAlpha(100),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No packages created yet",
                      style: AppTextStyles.cardTitle.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => context.push('/create-package'),
                      child: const Text("Create Your First Package"),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              itemCount: packages.length,
              itemBuilder: (context, index) {
                return PackageCard(
                  package: packages[index],
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => PackageBottomSheet(package: packages[index]),
                    );
                  },
                );
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
            ref.read(packageProvider.notifier).searchPackages("");
          });
        },
        icon: const Icon(IconsaxPlusLinear.arrow_left_1, color: AppColors.textPrimary),
      ),
      title: TextField(
        controller: _searchController,
        autofocus: true,
        style: AppTextStyles.description.copyWith(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: "Search packages by name or price...",
          border: InputBorder.none,
          hintStyle: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) {
          ref.read(packageProvider.notifier).searchPackages(value);
        },
      ),
    );
  }
}
