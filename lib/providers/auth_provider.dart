import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_auth_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiAuthService _authService = ApiAuthService();
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _user = _authService.getCurrentUser();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<bool> signUpWithEmail(String email, String password, String username) async {
    _setLoading(true);
    _setError(null);

    try {
      final user = await _authService.signUpWithEmail(email, password, username);
      if (user != null) {
        // 회원가입 성공 - 자동 로그인은 하지 않고 성공만 반환
        _setLoading(false);
        return true;
      } else {
        _setError('회원가입에 실패했습니다.');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _setLoading(true);
    _setError(null);

    try {
      final user = await _authService.signInWithEmail(email, password);
      if (user != null) {
        _user = user;
        _setLoading(false);
        return true;
      } else {
        _setError('로그인에 실패했습니다.');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    await _authService.signOut();
    _user = null;
    _setLoading(false);
  }

  void clearError() {
    _setError(null);
  }
}