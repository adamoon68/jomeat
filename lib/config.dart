class AppConfig {
  static const String baseUrl = "http://192.168.0.135/backend_jomeat/api";

  static String get serverRoot {
    const apiPath = '/backend_jomeat/api';
    if (baseUrl.endsWith(apiPath)) {
      return baseUrl.replaceFirst(apiPath, '');
    }
    return baseUrl.replaceFirst('/api', '');
  }

  static String get uploadUrl {
    return '$serverRoot/assets/images';
  }

  static String foodImageUrl(String imageName) {
    if (imageName.startsWith('http://') || imageName.startsWith('https://')) {
      return imageName;
    }
    if (imageName.startsWith('assets/images/')) {
      return '$serverRoot/$imageName';
    }
    return '$uploadUrl/$imageName';
  }
}
