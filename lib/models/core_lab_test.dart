class CoreLabTest {
  final String coreTestId;
  final String testName;
  final String testCategory;
  final String sampleType;
  final String? description;
  final List<String> parameters;
  final List<String> precautions;
  final String? testPhotoUrl;

  CoreLabTest({
    required this.coreTestId,
    required this.testName,
    required this.testCategory,
    required this.sampleType,
    this.description,
    required this.parameters,
    required this.precautions,
    this.testPhotoUrl,
  });

  factory CoreLabTest.fromJson(Map<String, dynamic> json) {
    return CoreLabTest(
      coreTestId: json['test_id'] ?? json['core_test_id'] ?? '',
      testName: json['test_name'] ?? '',
      testCategory: json['category'] ?? json['test_category'] ?? '',
      sampleType: json['sample_type'] ?? '',
      description: json['description'],
      parameters: [], // Deprecated in new backend, has number_of_parameters
      precautions: json['pre_test_info'] != null ? [json['pre_test_info']] : [],
      testPhotoUrl: json['test_photo_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'test_id': coreTestId,
      'test_name': testName,
      'category': testCategory,
      'sample_type': sampleType,
      'description': description,
    };
  }
}
