class ApiUrl {
  static const String baseUrl =
      "http://10.0.2.2:8000"; // Update for real device if needed

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
}
