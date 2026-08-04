class Earning {
  final String ledgerId;
  final String orderId;
  final double totalCustomerPaid;
  final double vendorEarning;
  final DateTime createdAt;

  Earning({
    required this.ledgerId,
    required this.orderId,
    required this.totalCustomerPaid,
    required this.vendorEarning,
    required this.createdAt,
  });

  factory Earning.fromJson(Map<String, dynamic> json) {
    return Earning(
      ledgerId: json['ledger_id'] ?? '',
      orderId: json['order_id'] ?? '',
      totalCustomerPaid: (json['total_customer_paid'] ?? 0).toDouble(),
      vendorEarning: (json['vendor_earning'] ?? 0).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
