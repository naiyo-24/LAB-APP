class ApiUrl {
  static const String baseUrl =
      "http://10.0.2.2:8000"; // Update for real device if needed

  // static const String baseUrl = "http://0.0.0.0:8000";

  // Auth and Profile Endpoints
  static const String pathoLabAuth = "$baseUrl/auth/patho-lab";
  static const String signup = "$pathoLabAuth/signup";
  static const String login = "$pathoLabAuth/login";
  static String profile(String labId) => "$pathoLabAuth/get-by/$labId";
  static String updateProfile(String labId) => "$pathoLabAuth/update-by/$labId";

  // Lab Test Endpoibts
  static const String coreLabTests = "$baseUrl/core-tests";
  static const String getAllTests = "$coreLabTests/get-all";
  static String getTestById(String testId) => "$coreLabTests/get-by/$testId";

  // Lab Test Inventory Endpoints
  static const String labTestInventory = "$baseUrl/lab-test-inventory";
  static const String createInventory = "$labTestInventory/create";
  static String getInventoryByLab(String labId) =>
      "$labTestInventory/get-by-lab/$labId";
  static String getInventoryById(String testId) =>
      "$labTestInventory/get-by/$testId";
  static String updateInventory(String testId) =>
      "$labTestInventory/update-by/$testId";
  static const String deleteInventory = "$labTestInventory/delete-by-ids";

  // Test Package Endpoints
  static const String testPackages = "$baseUrl/test-packages";
  static const String createPackage = "$testPackages/create";
  static String getPackagesByLab(String labId) =>
      "$testPackages/get-by-lab/$labId";
  static String getPackageById(String packageId) =>
      "$testPackages/get-by/$packageId";
  static String updatePackage(String packageId) =>
      "$testPackages/update-by/$packageId";
  static String deletePackage(String packageId) =>
      "$testPackages/delete-by/$packageId";

  // About Us Endpoints
  static const String aboutUs = "$baseUrl/about-us";
  static const String getAboutUsAll = "$aboutUs/get-all";
  static String getAboutUsById(int id) => "$aboutUs/get-by/$id";

  // Helper for image URLs
  static String imageUrl(String path) => "$baseUrl/$path";
}
