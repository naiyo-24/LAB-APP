class DashboardKpis {
  final int totalBookings;
  final double totalEarnings;
  final int totalTestsDone;
  final double avgOrderValue;
  final double amountPlatformOwesLab;
  final double amountLabOwesPlatform;
  final double netBalance;

  DashboardKpis({
    required this.totalBookings,
    required this.totalEarnings,
    required this.totalTestsDone,
    required this.avgOrderValue,
    required this.amountPlatformOwesLab,
    required this.amountLabOwesPlatform,
    required this.netBalance,
  });

  factory DashboardKpis.fromJson(Map<String, dynamic> json) {
    return DashboardKpis(
      totalBookings: json['total_bookings'] ?? 0,
      totalEarnings: (json['total_earnings'] ?? 0).toDouble(),
      totalTestsDone: json['total_tests_done'] ?? 0,
      avgOrderValue: (json['avg_order_value'] ?? 0).toDouble(),
      amountPlatformOwesLab: (json['amount_platform_owes_lab'] ?? 0).toDouble(),
      amountLabOwesPlatform: (json['amount_lab_owes_platform'] ?? 0).toDouble(),
      netBalance: (json['net_balance'] ?? 0).toDouble(),
    );
  }
}

class EarningsTrendPoint {
  final String date;
  final double amount;

  EarningsTrendPoint({required this.date, required this.amount});

  factory EarningsTrendPoint.fromJson(Map<String, dynamic> json) {
    return EarningsTrendPoint(
      date: json['date'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
    );
  }
}

class RecentBooking {
  final String bookingId;
  final String patientName;
  final double totalPrice;
  final String bookingStatus;
  final String paymentMode;
  final DateTime? createdAt;

  RecentBooking({
    required this.bookingId,
    required this.patientName,
    required this.totalPrice,
    required this.bookingStatus,
    required this.paymentMode,
    this.createdAt,
  });

  factory RecentBooking.fromJson(Map<String, dynamic> json) {
    return RecentBooking(
      bookingId: json['booking_id'] ?? '',
      patientName: json['patient_name'] ?? 'N/A',
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      bookingStatus: json['booking_status'] ?? '',
      paymentMode: json['payment_mode'] ?? 'cod',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }
}

class DashboardData {
  final DashboardKpis kpis;
  final Map<String, int> bookingsByStatus;
  final Map<String, int> paymentModeSplit;
  final List<EarningsTrendPoint> earningsTrend;
  final List<RecentBooking> recentBookings;

  DashboardData({
    required this.kpis,
    required this.bookingsByStatus,
    required this.paymentModeSplit,
    required this.earningsTrend,
    required this.recentBookings,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      kpis: DashboardKpis.fromJson(json['kpis'] ?? {}),
      bookingsByStatus: Map<String, int>.from(json['bookings_by_status'] ?? {}),
      paymentModeSplit: Map<String, int>.from(json['payment_mode_split'] ?? {}),
      earningsTrend: (json['earnings_trend'] as List? ?? [])
          .map((e) => EarningsTrendPoint.fromJson(e))
          .toList(),
      recentBookings: (json['recent_bookings'] as List? ?? [])
          .map((e) => RecentBooking.fromJson(e))
          .toList(),
    );
  }
}
