import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../models/core_lab_test.dart';
import '../../providers/lab_test_provider.dart';
import '../../theme/app_theme.dart';
import '../../cards/lab_test/search_lab_test_card.dart';

class SearchCoreLabTestsScreen extends ConsumerStatefulWidget {
  const SearchCoreLabTestsScreen({super.key});

  @override
  ConsumerState<SearchCoreLabTestsScreen> createState() => _SearchCoreLabTestsScreenState();
}

class _SearchCoreLabTestsScreenState extends ConsumerState<SearchCoreLabTestsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    ref.read(searchCoreLabTestProvider.notifier).searchCoreTests(query);
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchCoreLabTestProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(IconsaxPlusLinear.arrow_left, color: AppColors.textPrimary),
              ),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: AppTextStyles.description.copyWith(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: "Search by test name...",
                    hintStyle: AppTextStyles.description.copyWith(color: AppColors.textTertiary),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (value) {
                    setState(() {}); // To update close button presence
                    _performSearch(value);
                  },
                ),
              ),
              if (_searchController.text.isNotEmpty)
                IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                    _performSearch('');
                  },
                  icon: const Icon(IconsaxPlusLinear.close_circle, color: AppColors.textSecondary),
                )
            ],
          ),
        ),
      ),
      body: _buildBody(searchState),
    );
  }

  Widget _buildBody(AsyncValue<List<CoreLabTest>> searchState) {
    return searchState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(IconsaxPlusLinear.warning_2, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Search Failed', style: AppTextStyles.subHeader.copyWith(color: AppColors.error)),
              const SizedBox(height: 8),
              Text(err.toString().replaceAll('Exception: ', ''), style: AppTextStyles.description, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
      data: (results) {
        if (results.isEmpty) {
          if (_searchController.text.trim().isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(IconsaxPlusLinear.search_normal, size: 48, color: AppColors.textTertiary),
                  const SizedBox(height: 16),
                  Text('Search Lab Tests', style: AppTextStyles.subHeader.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Text('Type a test name to start searching', style: AppTextStyles.description),
                ],
              ),
            );
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(IconsaxPlusLinear.search_status, size: 48, color: AppColors.textTertiary),
                  const SizedBox(height: 16),
                  Text('No Results Found', style: AppTextStyles.subHeader.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Text('Try a different search term', style: AppTextStyles.description),
                ],
              ),
            );
          }
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          itemCount: results.length,
          itemBuilder: (context, index) {
            return SearchLabTestCard(test: results[index]);
          },
        );
      },
    );
  }
}