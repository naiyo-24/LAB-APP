class ApiUrl {
  static const String baseUrl =
      "http://192.168.0.222:8000/api"; 
  static const String graphql = "http://192.168.0.222:8000/graphql";

  // Auth and Profile Endpoints
  static const String pathoLabAuth = "$baseUrl/auth/lab";
  static const String login = "$pathoLabAuth/login";
  // The backend uses a different endpoint for lab admin registration
  static const String signup = "$baseUrl/auth/admin/register-lab";
  
  // Note: Profile endpoints are fully functional.
  static String profile(String labId) => "$pathoLabAuth/get-by/$labId";
  static String updateProfile(String labId) => "$pathoLabAuth/update-by/$labId";

  // Lab Test Endpoints
  static const String coreLabTests = "$baseUrl/rest/lab-inventory/global";
  static const String getAllTests = "$coreLabTests";
  static const String searchCoreTests = "$coreLabTests/search";
  static String getTestById(String testId) => "$coreLabTests/$testId";

  // Lab Test Inventory Endpoints
  static const String labTestInventory = "$baseUrl/rest/lab-inventory";
  static String createInventory(String labId) => "$labTestInventory/pricing/$labId";
  static String getInventoryByLab(String labId) =>
      "$labTestInventory/pricing/$labId";
  static String getInventoryById(String testId) =>
      "$labTestInventory/$testId";
  static String updateInventory(String testId) =>
      "$labTestInventory/$testId";
  static const String deleteInventory = "$labTestInventory/delete-by-ids";

  // Test Package Endpoints
  static const String testPackages = "$baseUrl/rest/test-packages";
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
  static const String aboutUs = "$baseUrl/rest/about-us";
  static const String getAboutUsAll = "$aboutUs/get-all";
  static String getAboutUsById(int id) => "$aboutUs/get-by/$id";

  // Lab Bookings Endpoints
  static const String testPackageBookings = "$baseUrl/rest/lab-bookings";
  static String getOrdersByLab(String labId) => "$testPackageBookings/lab/$labId";
  static String getOrderDetails(String bookingId) => "$testPackageBookings/$bookingId";
  static String updateOrder(String bookingId) => "$testPackageBookings/status/$bookingId";
  static String updateOrderDetails(String bookingId) => "$testPackageBookings/details/$bookingId";
  static String deleteOrder(String bookingId) => "$testPackageBookings/$bookingId";

  // Helper for image URLs
  static String imageUrl(String path) => "http://192.168.0.222:8000/$path";
}
