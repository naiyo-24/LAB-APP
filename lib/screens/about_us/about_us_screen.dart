import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/about_us_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/side_nav_bar.dart';
import '../../cards/about_us/company_header_card.dart';
import '../../cards/about_us/company_description_card.dart';
import '../../cards/about_us/mission_vision_card.dart';
import '../../cards/about_us/director_message_card.dart';
import '../../cards/about_us/partner_card.dart';
import '../../cards/about_us/contact_card.dart';

class AboutUsScreen extends ConsumerWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aboutUsState = ref.watch(aboutUsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'About Us',
        subtitle: 'COMPANY INFORMATION',
        showDrawer: false,
        showBackButton: true,
      ),
      drawer: const SideNavBar(),
      body: aboutUsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : aboutUsState.error != null
          ? Center(child: Text('Error: ${aboutUsState.error}'))
          : aboutUsState.aboutUsList.isEmpty
          ? const Center(child: Text('No information available'))
          : RefreshIndicator(
              onRefresh: () =>
                  ref.read(aboutUsProvider.notifier).fetchAboutUs(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                child: Column(
                  children: [
                    CompanyHeaderCard(aboutUs: aboutUsState.aboutUsList.first),
                    const SizedBox(height: 16),
                    CompanyDescriptionCard(
                      aboutUs: aboutUsState.aboutUsList.first,
                    ),
                    const SizedBox(height: 16),
                    MissionVisionCard(aboutUs: aboutUsState.aboutUsList.first),
                    const SizedBox(height: 16),
                    DirectorMessageCard(
                      aboutUs: aboutUsState.aboutUsList.first,
                    ),
                    const SizedBox(height: 16),
                    PartnerCard(aboutUs: aboutUsState.aboutUsList.first),
                    const SizedBox(height: 16),
                    ContactCard(aboutUs: aboutUsState.aboutUsList.first),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }
}
