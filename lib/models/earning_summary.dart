class EarningSummary {
  final double totalEarnings;
  final double totalPlatformOwesLab;
  final double totalLabOwesPlatform;
  final double netBalance;

  EarningSummary({
    required this.totalEarnings,
    required this.totalPlatformOwesLab,
    required this.totalLabOwesPlatform,
    required this.netBalance,
  });

  factory EarningSummary.fromJson(Map<String, dynamic> json) {
    return EarningSummary(
      totalEarnings: (json['total_earnings'] ?? 0).toDouble(),
      totalPlatformOwesLab: (json['total_platform_owes_lab'] ?? 0).toDouble(),
      totalLabOwesPlatform: (json['total_lab_owes_platform'] ?? 0).toDouble(),
      netBalance: (json['net_balance'] ?? 0).toDouble(),
    );
  }
}
