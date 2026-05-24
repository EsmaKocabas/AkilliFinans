import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show ValueNotifier, kIsWeb;

class AppSession {
  static String? token;
  static int? userId;
  static String? userName;
  static String? userEmail;
  
  // Use ValueNotifier for reactive budget state updates across screens
  static final ValueNotifier<double> budgetNotifier = ValueNotifier<double>(0.0);

  static double get budget => budgetNotifier.value;
  static set budget(double newBudget) {
    budgetNotifier.value = newBudget;
  }

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5001';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:5001'; // Redirects to host machine localhost
      }
    } catch (_) {}
    return 'http://localhost:5001';
  }

  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  static void logout() {
    token = null;
    userId = null;
    userName = null;
    userEmail = null;
    budget = 0.0;
  }
}
