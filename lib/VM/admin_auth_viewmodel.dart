import 'package:flutter/material.dart';

import '../Service/admin_dashboard_api.dart';

class AdminAuthViewModel extends ChangeNotifier {
  AdminAuthViewModel({AdminDashboardApi? api}) : _api = api ?? AdminDashboardApi();

  final AdminDashboardApi _api;
  bool _isAuthenticated = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _currentAdminId;
  String? _currentAdminName;
  String? _currentAdminRole;

  bool get isAuthenticated => _isAuthenticated;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String? get currentAdminId => _currentAdminId;
  String? get currentAdminName => _currentAdminName;
  String? get currentAdminRole => _currentAdminRole;

  Future<bool> signIn({
    required String adminId,
    required String password,
  }) async {
    _errorMessage = null;

    final trimmedId = adminId.trim();
    if (trimmedId.isEmpty || password.trim().isEmpty) {
      _errorMessage = '관리자 ID와 비밀번호를 모두 입력해 주세요.';
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      final result = await _api.signInAdmin(
        adminId: trimmedId,
        password: password.trim(),
      );
      _isSubmitting = false;
      _isAuthenticated = true;
      _currentAdminId = result.adminLoginId;
      _currentAdminName = result.adminName;
      _currentAdminRole = result.adminRole;
      notifyListeners();
      return true;
    } catch (error) {
      _isSubmitting = false;
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  void signOut() {
    _isAuthenticated = false;
    _isSubmitting = false;
    _errorMessage = null;
    _currentAdminId = null;
    _currentAdminName = null;
    _currentAdminRole = null;
    notifyListeners();
  }
}
