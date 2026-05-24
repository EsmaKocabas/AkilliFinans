import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Uygulama genelinde oturum ve kullanıcı verisi (Provider / Context API).
///
/// [ChangeNotifierProvider] ile `main.dart` içinde sağlanır.
/// Ekranlar: `context.watch<AppSession>()` (dinle) veya `context.read<AppSession>()` (yaz).
class AppSession extends ChangeNotifier {
  AppSession._();

  static final AppSession instance = AppSession._();

  String? _token;
  int? _userId;
  String? _userName;
  String? _userEmail;
  double _budget = 0.0;

  bool get isLoggedIn => _token != null;
  String? get token => _token;
  int? get userId => _userId;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  double get budget => _budget;

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5001';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:5001';
      }
    } catch (_) {}
    return 'http://localhost:5001';
  }

  Map<String, String> get headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  void signIn({
    required String token,
    required int userId,
    required String fullName,
    required String email,
    required double budget,
  }) {
    _token = token;
    _userId = userId;
    _userName = fullName;
    _userEmail = email;
    _budget = budget;
    notifyListeners();
  }

  void updateBudget(double value) {
    if (_budget == value) return;
    _budget = value;
    notifyListeners();
  }

  void updateProfile({
    String? fullName,
    String? email,
    double? budget,
  }) {
    var changed = false;
    if (fullName != null && _userName != fullName) {
      _userName = fullName;
      changed = true;
    }
    if (email != null && _userEmail != email) {
      _userEmail = email;
      changed = true;
    }
    if (budget != null && _budget != budget) {
      _budget = budget;
      changed = true;
    }
    if (changed) notifyListeners();
  }

  void logout() {
    _token = null;
    _userId = null;
    _userName = null;
    _userEmail = null;
    _budget = 0.0;
    notifyListeners();
  }

  static AppSession watch(BuildContext context) => context.watch<AppSession>();

  static AppSession read(BuildContext context) => context.read<AppSession>();
}
