import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vocabulary_model.dart';
import '../models/stats_model.dart';
import 'api_auth_service.dart';

class VocabularyService {
  final ApiAuthService _authService;
  static const String baseUrl = 'http://eng.gunsiya.com';

  VocabularyService(this._authService);

  // 내 단어장 목록 조회
  Future<Map<String, dynamic>> getMyVocabularies({
    int page = 1,
    int limit = 20,
    String sort = 'updated_at',
    String order = 'desc',
  }) async {
    try {
      final response = await _authService.authenticatedRequest(
        '/api/vocabularies/my?page=$page&limit=$limit&sort=$sort&order=$order',
        method: 'GET',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'vocabularies': (data['vocabularies'] as List)
              .map((v) => VocabularyModel.fromJson(v))
              .toList(),
          'pagination': PaginationMeta.fromJson(data['pagination']),
        };
      } else {
        throw Exception('Failed to fetch vocabularies');
      }
    } catch (e) {
      print('Error fetching vocabularies: $e');
      rethrow;
    }
  }

  // 공개 단어장 검색
  Future<Map<String, dynamic>> getPublicVocabularies({
    String? query,
    String? category,
    String? targetLevel,
    int? minWords,
    String sort = 'popular',
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        'sort': sort,
      };

      if (query != null && query.isNotEmpty) queryParams['q'] = query;
      if (category != null) queryParams['category'] = category;
      if (targetLevel != null) queryParams['target_level'] = targetLevel;
      if (minWords != null) queryParams['min_words'] = minWords.toString();

      final uri = Uri.parse('$baseUrl/api/vocabularies/public')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'vocabularies': (data['vocabularies'] as List)
              .map((v) => VocabularyModel.fromJson(v))
              .toList(),
          'pagination': PaginationMeta.fromJson(data['pagination']),
        };
      } else {
        throw Exception('Failed to fetch public vocabularies');
      }
    } catch (e) {
      print('Error fetching public vocabularies: $e');
      rethrow;
    }
  }

  // 단어장 생성
  Future<VocabularyModel> createVocabulary({
    required String title,
    String? description,
    bool isPublic = false,
    required String category,
    required String targetLevel,
    String language = 'en',
  }) async {
    try {
      final response = await _authService.authenticatedRequest(
        '/api/vocabularies',
        method: 'POST',
        body: {
          'title': title,
          'description': description,
          'is_public': isPublic,
          'category': category,
          'target_level': targetLevel,
          'language': language,
        },
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return VocabularyModel.fromJson(data['vocabulary']);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to create vocabulary');
      }
    } catch (e) {
      print('Error creating vocabulary: $e');
      rethrow;
    }
  }

  // 단어장 수정
  Future<VocabularyModel> updateVocabulary(
    int vocabularyId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await _authService.authenticatedRequest(
        '/api/vocabularies/$vocabularyId',
        method: 'PUT',
        body: updates,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return VocabularyModel.fromJson(data['vocabulary']);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to update vocabulary');
      }
    } catch (e) {
      print('Error updating vocabulary: $e');
      rethrow;
    }
  }

  // 단어장 삭제
  Future<void> deleteVocabulary(int vocabularyId) async {
    try {
      final response = await _authService.authenticatedRequest(
        '/api/vocabularies/$vocabularyId',
        method: 'DELETE',
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to delete vocabulary');
      }
    } catch (e) {
      print('Error deleting vocabulary: $e');
      rethrow;
    }
  }

  // 단어장 다운로드 (복사)
  Future<VocabularyModel> downloadVocabulary(int vocabularyId) async {
    try {
      final response = await _authService.authenticatedRequest(
        '/api/vocabularies/$vocabularyId/download',
        method: 'POST',
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return VocabularyModel.fromJson(data['vocabulary']);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to download vocabulary');
      }
    } catch (e) {
      print('Error downloading vocabulary: $e');
      rethrow;
    }
  }

  // 단어장 통계 조회
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
