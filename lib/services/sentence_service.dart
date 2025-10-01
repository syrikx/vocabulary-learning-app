import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sentence_model.dart';
import 'api_auth_service.dart';

class SentenceService {
  final ApiAuthService _authService;
  static const String baseUrl = 'http://eng.gunsiya.com';

  SentenceService(this._authService);

  // 예문 조회 (기존 API 활용)
  Future<SentenceResponse> getSentences({
    required String word,
    required int years,
    List<String> userSentences = const [],
    int count = 5,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/example_sentence'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'word': word,
          'years': years,
          'user_sentences': userSentences,
          'count': count,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return SentenceResponse.fromJson(data);
      } else {
        throw Exception('Failed to fetch sentences');
      }
    } catch (e) {
      print('Error fetching sentences: $e');
      rethrow;
    }
  }

  // 예문 북마크
  Future<void> bookmarkSentence(
    int vocabularyId,
    int wordId,
    int sentenceId,
  ) async {
    try {
      final response = await _authService.authenticatedRequest(
        '/api/vocabularies/$vocabularyId/words/$wordId/sentences/$sentenceId/bookmark',
        method: 'POST',
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to bookmark sentence');
      }
    } catch (e) {
      print('Error bookmarking sentence: $e');
      rethrow;
    }
  }

  // 예문 북마크 해제
  Future<void> unbookmarkSentence(
    int vocabularyId,
    int wordId,
    int sentenceId,
  ) async {
    try {
      final response = await _authService.authenticatedRequest(
        '/api/vocabularies/$vocabularyId/words/$wordId/sentences/$sentenceId/bookmark',
        method: 'DELETE',
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to unbookmark sentence');
      }
    } catch (e) {
      print('Error unbookmarking sentence: $e');
      rethrow;
    }
  }
}
