import 'core_lab_test.dart';

class MyLabTest {
  final String testId;
  final String labId;
  final String coreTestId;
  final String sampleCollectionTime;
  final String reportDeliveryTime;
  final double price;
  final double discountPercent;
  final double marketPrice;
  final List<dynamic> reviews;
  final CoreLabTest? coreTestDetails;

  MyLabTest({
    required this.testId,
    required this.labId,
    required this.coreTestId,
    required this.sampleCollectionTime,
    required this.reportDeliveryTime,
    required this.price,
    required this.discountPercent,
    required this.marketPrice,
    required this.reviews,
    this.coreTestDetails,
  });

  factory MyLabTest.fromJson(Map<String, dynamic> json) {
    return MyLabTest(
      testId: json['test_id'] ?? '',
      labId: json['lab_id'] ?? '',
      coreTestId: json['core_test_id'] ?? '',
      sampleCollectionTime: json['sample_collection_time'] ?? '',
      reportDeliveryTime: json['report_delivery_time'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      discountPercent: (json['discount_percent'] ?? 0.0).toDouble(),
      marketPrice: (json['market_price'] ?? 0.0).toDouble(),
      reviews: List<dynamic>.from(json['reviews'] ?? []),
      coreTestDetails: json['core_test_details'] != null
          ? CoreLabTest.fromJson(json['core_test_details'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'test_id': testId,
      'lab_id': labId,
      'core_test_id': coreTestId,
      'sample_collection_time': sampleCollectionTime,
      'report_delivery_time': reportDeliveryTime,
      'price': price,
      'discount_percent': discountPercent,
      'market_price': marketPrice,
      'reviews': reviews,
    };
  }
}
