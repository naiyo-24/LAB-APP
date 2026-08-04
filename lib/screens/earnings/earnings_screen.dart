import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/earnings_provider.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/side_nav_bar.dart';
import '../../widgets/main_screen_pop_scope.dart';

class EarningsScreen extends ConsumerStatefulWidget {
  const EarningsScreen({super.key});

  @override
  ConsumerState<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends ConsumerState<EarningsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(earningsProvider.notifier).loadEarnings());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(earningsProvider);

    return MainScreenPopScope(
      child: Scaffold(
        appBar: const CustomAppBar(
          title: 'Earnings & Payments',
          subtitle: 'Financial summary',
          showDrawer: true,
        ),
        drawer: const SideNavBar(),
        body: state.isLoading && state.earnings.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : state.error != null
                ? Center(child: Text('Error: ${state.error}'))
                : RefreshIndicator(
                    onRefresh: () => ref.read(earningsProvider.notifier).loadEarnings(),
                    child: CustomScrollView(
                      slivers: [
                        if (state.summary != null)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: _buildSummaryCards(state.summary!),
                            ),
                          ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final earning = state.earnings[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Order #${earning.orderId.length > 8 ? earning.orderId.substring(0, 8) : earning.orderId}',
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          DateFormat('dd MMM yyyy, hh:mm a').format(earning.createdAt.toLocal()),
                                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                        ),
                                        const Divider(height: 24),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('Total Amount Paid:'),
                                            Text('₹${earning.totalCustomerPaid.toStringAsFixed(2)}'),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('Your Earning:', style: TextStyle(fontWeight: FontWeight.bold)),
                                            Text(
                                              '₹${earning.vendorEarning.toStringAsFixed(2)}',
                                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              childCount: state.earnings.length,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildSummaryCards(summary) {
    final bool platformOwesLab = summary.netBalance > 0;
    final bool isSettled = summary.netBalance == 0;

    final Color netColor = isSettled 
        ? Colors.grey 
        : (platformOwesLab ? Colors.green : Colors.red);
    final String netTitle = isSettled 
        ? 'Accounts Settled' 
        : (platformOwesLab ? 'Platform owes you' : 'You owe the platform');

    return Column(
      children: [
        _buildStatCard(
          title: 'Total Earnings (Your Share)',
          amount: summary.totalEarnings,
          icon: Icons.account_balance_wallet,
          color: Colors.blue,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Online (Owed to you)',
                amount: summary.totalPlatformOwesLab,
                icon: Icons.language,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'COD (Owed to Platform)',
                amount: summary.totalLabOwesPlatform,
                icon: Icons.money,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          title: 'Net Outstanding Balance: $netTitle',
          amount: summary.netBalance.abs(),
          icon: Icons.account_balance,
          color: netColor,
        ),
      ],
    );
  }

  Widget _buildStatCard({required String title, required double amount, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                  '₹${amount.toStringAsFixed(2)}',
                  style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

}
