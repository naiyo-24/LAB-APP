class TestPackage {
  final String packageId;
  final String labId;
  final String packageName;
  final List<dynamic> testDetails; // List of tests in the package
  final String? packageDescription;
  final String packageSampleCollectionTime;
  final String packageReportDeliveryTime;
  final double packageMarketPrice;
  final double discountPercentage;
  final double packageFinalPrice;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TestPackage({
    required this.packageId,
    required this.labId,
    required this.packageName,
    required this.testDetails,
    this.packageDescription,
    required this.packageSampleCollectionTime,
    required this.packageReportDeliveryTime,
    required this.packageMarketPrice,
    required this.discountPercentage,
    required this.packageFinalPrice,
    this.createdAt,
    this.updatedAt,
  });

  factory TestPackage.fromJson(Map<String, dynamic> json) {
    return TestPackage(
      packageId: json['package_id'] ?? '',
      labId: json['lab_id'] ?? '',
      packageName: json['package_name'] ?? '',
      testDetails: List<dynamic>.from(json['test_details'] ?? []),
      packageDescription: json['package_description'],
      packageSampleCollectionTime: json['package_sample_collection_time'] ?? '',
      packageReportDeliveryTime: json['package_report_delivery_time'] ?? '',
      packageMarketPrice: (json['package_market_price'] ?? 0.0).toDouble(),
      discountPercentage: (json['discount_percentage'] ?? 0.0).toDouble(),
      packageFinalPrice: (json['package_final_price'] ?? 0.0).toDouble(),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'package_id': packageId,
      'lab_id': labId,
      'package_name': packageName,
      'test_details': testDetails,
      'package_description': packageDescription,
      'package_sample_collection_time': packageSampleCollectionTime,
      'package_report_delivery_time': packageReportDeliveryTime,
      'package_market_price': packageMarketPrice,
      'discount_percentage': discountPercentage,
      'package_final_price': packageFinalPrice,
    };
  }
}
