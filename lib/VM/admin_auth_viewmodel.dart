import 'package:flutter/material.dart';

class AdminAuthViewModel extends ChangeNotifier {
  static const Map<String, String> _allowedCredentials = {
    'admin': '1111',
  };

  bool _isAuthenticated = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _currentAdminId;

  bool get isAuthenticated => _isAuthenticated;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String? get currentAdminId => _currentAdminId;

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

    await Future<void>.delayed(const Duration(milliseconds: 350));

    final expectedPassword = _allowedCredentials[trimmedId];
    if (expectedPassword == null || expectedPassword != password) {
      _isSubmitting = false;
      _errorMessage = '관리자 계정 정보가 올바르지 않습니다.';
      notifyListeners();
      return false;
    }

    _isSubmitting = false;
    _isAuthenticated = true;
    _currentAdminId = trimmedId;
    notifyListeners();
    return true;
  }

  void signOut() {
    _isAuthenticated = false;
    _isSubmitting = false;
    _errorMessage = null;
    _currentAdminId = null;
    notifyListeners();
  }
}
