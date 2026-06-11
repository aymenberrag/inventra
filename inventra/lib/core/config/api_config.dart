import 'dart:io';

class ApiConfig {
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'https://inventra-0jju.onrender.com';
    }
    return 'https://inventra-0jju.onrender.com';
  }
}
