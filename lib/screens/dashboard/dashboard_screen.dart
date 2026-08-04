import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:intl/intl.dart';
import '../../providers/dashboard_provider.dart';
import '../../models/dashboard_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/side_nav_bar.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    Future.microtask(() => ref.read(dashboardProvider.notifier).loadDashboard());
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardProvider);

    // Trigger animation when data arrives
    if (state.data != null && !_animController.isAnimating && _animController.value == 0) {
      _animController.forward();
    }

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Dashboard',
        subtitle: 'Business overview',
        showDrawer: true,
      ),
      drawer: const SideNavBar(),
      body: state.isLoading && state.data == null
          ? const Center(child: CircularProgressIndicator())
          : state.error != null && state.data == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(IconsaxPlusLinear.warning_2, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text('Error: ${state.error}', style: AppTextStyles.caption),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.read(dashboardProvider.notifier).loadDashboard(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => ref.read(dashboardProvider.notifier).loadDashboard(),
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: _buildDashboard(state.data!),
                  ),
                ),
    );
  }

  Widget _buildDashboard(DashboardData data) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Net Balance Banner
        _buildNetBalanceBanner(data.kpis),
        const SizedBox(height: 24),

        // KPI Cards
        _buildKpiSection(data.kpis),
        const SizedBox(height: 24),

        // Earnings Trend
        _buildSectionTitle('Earnings Trend', 'Last 7 days'),
        const SizedBox(height: 12),
        _buildEarningsTrendChart(data.earningsTrend),
        const SizedBox(height: 24),

        // Bookings by Status + Payment Mode side by side
        _buildSectionTitle('Booking Analytics', 'Status & payments'),
        const SizedBox(height: 12),
        _buildChartsRow(data),
        const SizedBox(height: 24),

        // Recent Bookings
        _buildSectionTitle('Recent Bookings', 'Last 5 orders'),
        const SizedBox(height: 12),
        ...data.recentBookings.map((b) => _buildRecentBookingCard(b)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildNetBalanceBanner(DashboardKpis kpis) {
    final bool platformOwesLab = kpis.netBalance > 0;
    final bool isSettled = kpis.netBalance == 0;
    
    final Color bgColor = isSettled 
        ? Colors.grey.shade100 
        : (platformOwesLab ? Colors.green.shade50 : Colors.red.shade50);
    final Color iconColor = isSettled 
        ? Colors.grey.shade600
        : (platformOwesLab ? Colors.green.shade600 : Colors.red.shade600);
    final String title = isSettled 
        ? 'Accounts Settled'
        : (platformOwesLab ? 'Platform owes you' : 'You owe the platform');
    final String amount = '₹${kpis.netBalance.abs().toStringAsFixed(0)}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSettled ? IconsaxPlusLinear.tick_circle : IconsaxPlusLinear.wallet_money,
              color: iconColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Net Outstanding Balance',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$title $amount',
                  style: AppTextStyles.subHeader.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────── KPI SECTION ────────────────────

  Widget _buildKpiSection(DashboardKpis kpis) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildKpiCard(
                icon: IconsaxPlusLinear.calendar_tick,
                label: 'Total Bookings',
                value: '${kpis.totalBookings}',
                gradient: const [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKpiCard(
                icon: IconsaxPlusLinear.wallet_3,
                label: 'Total Earnings',
                value: '₹${kpis.totalEarnings.toStringAsFixed(0)}',
                gradient: const [Color(0xFF11998E), Color(0xFF38EF7D)],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildKpiCard(
                icon: IconsaxPlusLinear.microscope,
                label: 'Tests Done',
                value: '${kpis.totalTestsDone}',
                gradient: const [Color(0xFFF093FB), Color(0xFFF5576C)],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKpiCard(
                icon: IconsaxPlusLinear.chart_2,
                label: 'Avg. Order Value',
                value: '₹${kpis.avgOrderValue.toStringAsFixed(0)}',
                gradient: const [Color(0xFF4FACFE), Color(0xFF00F2FE)],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKpiCard({
    required IconData icon,
    required String label,
    required String value,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withAlpha(60),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(50),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Lexend',
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Lexend',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white.withAlpha(200),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────── SECTION TITLE ────────────────────

  Widget _buildSectionTitle(String title, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.cardTitle),
            const SizedBox(height: 2),
            Text(subtitle, style: AppTextStyles.caption),
          ],
        ),
      ],
    );
  }

  // ──────────────────── EARNINGS TREND LINE CHART ────────────────────

  Widget _buildEarningsTrendChart(List<EarningsTrendPoint> trend) {
    if (trend.isEmpty) {
      return _buildEmptyChartPlaceholder('No earnings data yet');
    }

    final maxY = trend.map((e) => e.amount).reduce((a, b) => a > b ? a : b);
    final ceiling = maxY == 0 ? 100.0 : (maxY * 1.3);

    final spots = trend.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.amount);
    }).toList();

    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: AppCardStyles.sleekCard,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: ceiling / 4,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.shade200,
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 44,
                interval: ceiling / 4,
                getTitlesWidget: (value, meta) {
                  if (value == ceiling) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      '₹${value.toInt()}',
                      style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= trend.length) return const SizedBox.shrink();
                  // Show only first, middle, and last label if 7+ items
                  if (trend.length >= 5) {
                    final mid = trend.length ~/ 2;
                    if (i != 0 && i != mid && i != trend.length - 1) {
                      return const SizedBox.shrink();
                    }
                  }
                  final dt = DateTime.tryParse(trend[i].date);
                  final label = dt != null ? DateFormat('dd MMM').format(dt) : '';
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.grey.shade600)),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (trend.length - 1).toDouble(),
          minY: 0,
          maxY: ceiling,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.3,
              color: AppColors.primaryAccent,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, p, bar, i) => FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 2.5,
                  strokeColor: AppColors.primaryAccent,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryAccent.withAlpha(80),
                    AppColors.primaryAccent.withAlpha(10),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  return LineTooltipItem(
                    '₹${spot.y.toStringAsFixed(0)}',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      ),
    );
  }

  // ──────────────────── CHARTS ROW (BAR + PIE) ────────────────────

  Widget _buildChartsRow(DashboardData data) {
    return Column(
      children: [
        _buildStatusBarChart(data.bookingsByStatus),
        const SizedBox(height: 16),
        _buildPaymentPieChart(data.paymentModeSplit),
      ],
    );
  }

  // ──────────────────── BOOKINGS BY STATUS BAR CHART ────────────────────

  Widget _buildStatusBarChart(Map<String, int> byStatus) {
    final entries = byStatus.entries.toList();
    if (entries.every((e) => e.value == 0)) {
      return _buildEmptyChartPlaceholder('No bookings yet');
    }

    final statusColors = {
      'pending': const Color(0xFFF59E0B),
      'accepted': const Color(0xFF3B82F6),
      'sample_collected': const Color(0xFF8B5CF6),
      'processing': const Color(0xFF6366F1),
      'report_ready': const Color(0xFF10B981),
      'completed': const Color(0xFF059669),
      'cancelled': const Color(0xFFEF4444),
    };

    final statusLabels = {
      'pending': 'Pend.',
      'accepted': 'Acpt.',
      'sample_collected': 'Smpl.',
      'processing': 'Proc.',
      'report_ready': 'Ready',
      'completed': 'Done',
      'cancelled': 'Cncl.',
    };

    final maxVal = entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final maxY = maxVal == 0 ? 5.0 : (maxVal + 2).toDouble();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppCardStyles.sleekCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Bookings by Status',
              style: TextStyle(fontFamily: 'Lexend', fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, gI, rod, rI) {
                      final name = entries[group.x.toInt()].key;
                      return BarTooltipItem(
                        '${name.replaceAll('_', ' ')}\n${rod.toY.toInt()}',
                        const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: maxY > 4 ? (maxY / 4).ceilToDouble() : 1,
                      getTitlesWidget: (value, meta) {
                        if (value == maxY) return const SizedBox.shrink();
                        return Text('${value.toInt()}',
                            style: TextStyle(fontSize: 10, color: Colors.grey.shade500));
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= entries.length) return const SizedBox.shrink();
                        final label = statusLabels[entries[i].key] ?? entries[i].key;
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(label,
                              style: TextStyle(fontSize: 9, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY > 4 ? (maxY / 4).ceilToDouble() : 1,
                  getDrawingHorizontalLine: (v) => FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                barGroups: entries.asMap().entries.map((entry) {
                  final i = entry.key;
                  final e = entry.value;
                  final color = statusColors[e.key] ?? Colors.grey;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: e.value.toDouble(),
                        color: color,
                        width: 18,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────── PAYMENT MODE PIE / DONUT CHART ────────────────────

  Widget _buildPaymentPieChart(Map<String, int> split) {
    final total = split.values.fold(0, (a, b) => a + b);
    if (total == 0) {
      return _buildEmptyChartPlaceholder('No payment data yet');
    }

    final pieColors = {
      'cod': const Color(0xFF4FACFE),
      'online': const Color(0xFF38EF7D),
    };

    final pieLabels = {
      'cod': 'Cash',
      'online': 'Online',
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppCardStyles.sleekCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Payment Mode Split',
              style: TextStyle(fontFamily: 'Lexend', fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: Row(
              children: [
                // Pie chart
                Expanded(
                  flex: 3,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 40,
                      sections: split.entries.map((e) {
                        final pct = ((e.value / total) * 100).round();
                        final color = pieColors[e.key] ?? Colors.grey;
                        return PieChartSectionData(
                          value: e.value.toDouble(),
                          color: color,
                          radius: 36,
                          title: '$pct%',
                          titleStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  ),
                ),
                // Legend
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: split.entries.map((e) {
                      final color = pieColors[e.key] ?? Colors.grey;
                      final label = pieLabels[e.key] ?? e.key;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '$label (${e.value})',
                                style: TextStyle(
                                  fontFamily: 'Lexend',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────── RECENT BOOKINGS LIST ────────────────────

  Widget _buildRecentBookingCard(RecentBooking booking) {
    final statusColors = {
      'pending': const Color(0xFFF59E0B),
      'accepted': const Color(0xFF3B82F6),
      'sample_collected': const Color(0xFF8B5CF6),
      'processing': const Color(0xFF6366F1),
      'report_ready': const Color(0xFF10B981),
      'completed': const Color(0xFF059669),
      'cancelled': const Color(0xFFEF4444),
    };

    final color = statusColors[booking.bookingStatus] ?? Colors.grey;
    final dateStr = booking.createdAt != null
        ? DateFormat('dd MMM, hh:mm a').format(booking.createdAt!.toLocal())
        : 'N/A';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Left color indicator
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 14),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      booking.patientName,
                      style: const TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '₹${booking.totalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dateStr,
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withAlpha(25),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: color.withAlpha(80)),
                      ),
                      child: Text(
                        booking.bookingStatus.replaceAll('_', ' ').toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────── EMPTY PLACEHOLDER ────────────────────

  Widget _buildEmptyChartPlaceholder(String message) {
    return Container(
      height: 160,
      decoration: AppCardStyles.sleekCard,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(IconsaxPlusLinear.chart_1, size: 36, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Text(message, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}
