import 'dart:convert';
import '../models/stats_model.dart';
import 'api_auth_service.dart';

class StatsService {
  final ApiAuthService _authService;

  StatsService(this._authService);

  // 사용자 전체 통계 조회
  Future<UserStats> getUserStats() async {
    try {
      final response = await _authService.authenticatedRequest(
        '/api/users/me/stats',
        method: 'GET',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserStats.fromJson(data);
      } else {
        throw Exception('Failed to fetch user stats');
      }
    } catch (e) {
      print('Error fetching user stats: $e');
      rethrow;
    }
  }

  // 단어장별 통계 조회 (VocabularyService와 중복이지만 별도 관리)
  Future<VocabularyStats> getVocabularyStats(int vocabularyId) async {
    try {
      final response = await _authService.authenticatedRequest(
        '/api/vocabularies/$vocabularyId/stats',
        method: 'GET',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return VocabularyStats.fromJson(data);
      } else {
        throw Exception('Failed to fetch vocabulary stats');
      }
    } catch (e) {
      print('Error fetching vocabulary stats: $e');
      rethrow;
    }
  }
}
