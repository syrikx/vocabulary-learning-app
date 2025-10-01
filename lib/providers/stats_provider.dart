import 'package:flutter/material.dart';
import '../models/stats_model.dart';
import '../services/stats_service.dart';
import '../services/api_auth_service.dart';

class StatsProvider with ChangeNotifier {
  final StatsService _statsService;

  UserStats? _userStats;
  bool _isLoading = false;
  String? _errorMessage;

  UserStats? get userStats => _userStats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  StatsProvider(ApiAuthService authService)
      : _statsService = StatsService(authService);

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // 사용자 전체 통계 조회
  Future<void> fetchUserStats() async {
    _setLoading(true);
    _setError(null);

    try {
      _userStats = await _statsService.getUserStats();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
    }
  }

  // 통계 새로고침
  Future<void> refreshStats() async {
    await fetchUserStats();
  }

  // 통계 클리어
  void clearStats() {
    _userStats = null;
    notifyListeners();
  }
}
