import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  Future<void> initSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('auth_token');
      _userId = prefs.getInt('auth_user_id');
      _userName = prefs.getString('auth_user_name');
      _userEmail = prefs.getString('auth_user_email');
      _budget = prefs.getDouble('auth_user_budget') ?? 0.0;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading persisted session: $e');
    }
  }

  Future<void> signIn({
    required String token,
    required int userId,
    required String fullName,
    required String email,
    required double budget,
  }) async {
    _token = token;
    _userId = userId;
    _userName = fullName;
    _userEmail = email;
    _budget = budget;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setInt('auth_user_id', userId);
      await prefs.setString('auth_user_name', fullName);
      await prefs.setString('auth_user_email', email);
      await prefs.setDouble('auth_user_budget', budget);
    } catch (e) {
      debugPrint('Error saving session to local storage: $e');
    }
  }

  Future<void> updateBudget(double value) async {
    if (_budget == value) return;
    _budget = value;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('auth_user_budget', value);
    } catch (e) {
      debugPrint('Error updating budget in local storage: $e');
    }
  }

  Future<void> updateProfile({
    String? fullName,
    String? email,
    double? budget,
  }) async {
    var changed = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (fullName != null && _userName != fullName) {
        _userName = fullName;
        await prefs.setString('auth_user_name', fullName);
        changed = true;
      }
      if (email != null && _userEmail != email) {
        _userEmail = email;
        await prefs.setString('auth_user_email', email);
        changed = true;
      }
      if (budget != null && _budget != budget) {
        _budget = budget;
        await prefs.setDouble('auth_user_budget', budget);
        changed = true;
      }
    } catch (e) {
      debugPrint('Error updating profile in local storage: $e');
    }
    if (changed) notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _userName = null;
    _userEmail = null;
    _budget = 0.0;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('auth_user_id');
      await prefs.remove('auth_user_name');
      await prefs.remove('auth_user_email');
      await prefs.remove('auth_user_budget');
    } catch (e) {
      debugPrint('Error clearing local storage on logout: $e');
    }
  }

  static AppSession watch(BuildContext context) => context.watch<AppSession>();

  static AppSession read(BuildContext context) => context.read<AppSession>();
}
