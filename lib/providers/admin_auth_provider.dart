import 'package:flutter/foundation.dart';

class AdminAuthProvider extends ChangeNotifier {
  static final AdminAuthProvider instance = AdminAuthProvider._();
  AdminAuthProvider._();

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  void authenticate() {
    _isAuthenticated = true;
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }
}
