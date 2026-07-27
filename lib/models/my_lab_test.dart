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
    // Handling both old backend names and new backend names (including flat GraphQL structure)
    final double sellingPrice = (json['customer_selling_price'] ?? json['final_price'] ?? json['price'] ?? 0.0).toDouble();
    final double marketPriceVal = (json['mrp'] ?? json['market_price'] ?? json['price'] ?? 0.0).toDouble();
    
    // Calculate discount if not provided
    double discount = (json['discount_percent'] ?? json['discount_percentage'] ?? 0.0).toDouble();
    if (discount == 0.0 && marketPriceVal > 0 && sellingPrice < marketPriceVal) {
      discount = ((marketPriceVal - sellingPrice) / marketPriceVal) * 100;
    }

    CoreLabTest? details;
    if (json['core_test_details'] != null) {
      details = CoreLabTest.fromJson(json['core_test_details']);
    } else if (json['test_name'] != null) {
      // If it's a flat GraphQL response, construct CoreLabTest manually
      details = CoreLabTest.fromJson(json);
    }

    return MyLabTest(
      testId: json['id'] ?? json['test_id'] ?? '',
      labId: json['lab_id'] ?? '',
      coreTestId: json['test_id'] ?? json['core_test_id'] ?? '',
      sampleCollectionTime: json['sample_collection_time'] ?? (json['home_collection_available'] == true ? 'Home Collection Available' : ''),
      reportDeliveryTime: json['report_delivery_time'] ?? '${json['turnaround_time_hours'] ?? 24} hours',
      price: sellingPrice,
      discountPercent: discount,
      marketPrice: marketPriceVal,
      reviews: List<dynamic>.from(json['reviews'] ?? []),
      coreTestDetails: details,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'test_id': coreTestId, // The new backend uses test_id to link to the global test catalog
      'lab_base_rate': price * 0.8, // Approximation if not stored
      'customer_selling_price': price,
      'mrp': marketPrice,
      'turnaround_time_hours': 24, // Approximation
      'home_collection_available': true,
      'walk_in_available': true,
    };
  }
}
