import 'dart:convert';
import '../models/word_model.dart';
import 'api_auth_service.dart';

class WordService {
  final ApiAuthService _authService;

  WordService(this._authService);

  // 단어 목록 조회
  Future<Map<String, dynamic>> getWords(
    int vocabularyId, {
    int page = 1,
    int limit = 20,
    String? learned,
    String? difficulty,
    String sort = 'created_at',
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        'sort': sort,
      };

      if (learned != null) queryParams['learned'] = learned;
      if (difficulty != null) queryParams['difficulty'] = difficulty;

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');

      final response = await _authService.authenticatedRequest(
        '/api/vocabularies/$vocabularyId/words?$queryString',
        method: 'GET',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'words': (data['words'] as List)
              .map((w) => WordModel.fromJson(w))
              .toList(),
          'pagination': data['pagination'],
          'stats': data['stats'],
        };
      } else {
        throw Exception('Failed to fetch words');
      }
    } catch (e) {
      print('Error fetching words: $e');
      rethrow;
    }
  }

  // 단어 추가
  Future<WordModel> addWord(
    int vocabularyId, {
    required String word,
    String? meaning,
    required String partOfSpeech,
    required String difficulty,
    String? notes,
  }) async {
    try {
      final response = await _authService.authenticatedRequest(
        '/api/vocabularies/$vocabularyId/words',
        method: 'POST',
        body: {
          'word': word,
          'meaning': meaning,
          'part_of_speech': partOfSpeech,
          'difficulty': difficulty,
          'notes': notes,
        },
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return WordModel.fromJson(data['word']);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to add word');
      }
    } catch (e) {
      print('Error adding word: $e');
      rethrow;
    }
  }

  // 단어 수정
  Future<WordModel> updateWord(
    int vocabularyId,
    int wordId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await _authService.authenticatedRequest(
        '/api/vocabularies/$vocabularyId/words/$wordId',
        method: 'PUT',
        body: updates,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return WordModel.fromJson(data['word']);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to update word');
      }
    } catch (e) {
      print('Error updating word: $e');
      rethrow;
    }
  }

  // 단어 삭제
  Future<void> deleteWord(int vocabularyId, int wordId) async {
    try {
      final response = await _authService.authenticatedRequest(
        '/api/vocabularies/$vocabularyId/words/$wordId',
        method: 'DELETE',
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to delete word');
      }
    } catch (e) {
      print('Error deleting word: $e');
      rethrow;
    }
  }

  // 학습 완료 표시
  Future<WordModel> markAsLearned(
    int vocabularyId,
    int wordId,
    bool learned,
  ) async {
    try {
      final response = await _authService.authenticatedRequest(
        '/api/vocabularies/$vocabularyId/words/$wordId/mark-learned',
        method: 'POST',
        body: {'learned': learned},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return WordModel.fromJson(data['word']);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to mark word as learned');
      }
    } catch (e) {
      print('Error marking word as learned: $e');
      rethrow;
    }
  }
}
