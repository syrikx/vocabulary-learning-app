import 'package:flutter/material.dart';
import '../models/word_model.dart';
import '../services/word_service.dart';
import '../services/api_auth_service.dart';

class WordProvider with ChangeNotifier {
  final WordService _wordService;

  Map<int, List<WordModel>> _wordsByVocabulary = {};
  Map<int, dynamic> _statsByVocabulary = {};
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  WordProvider(ApiAuthService authService)
      : _wordService = WordService(authService);

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

  // 특정 단어장의 단어 목록 가져오기
  List<WordModel> getWords(int vocabularyId) {
    return _wordsByVocabulary[vocabularyId] ?? [];
  }

  // 특정 단어장의 통계 가져오기
  dynamic getStats(int vocabularyId) {
    return _statsByVocabulary[vocabularyId];
  }

  // 단어 목록 조회
  Future<void> fetchWords(
    int vocabularyId, {
    bool refresh = false,
    int page = 1,
    String? learned,
    String? difficulty,
    String sort = 'created_at',
  }) async {
    if (refresh) {
      _wordsByVocabulary[vocabularyId] = [];
    }

    _setLoading(true);
    _setError(null);

    try {
      final result = await _wordService.getWords(
        vocabularyId,
        page: page,
        learned: learned,
        difficulty: difficulty,
        sort: sort,
      );

      if (refresh || page == 1) {
        _wordsByVocabulary[vocabularyId] = result['words'];
      } else {
        _wordsByVocabulary[vocabularyId] = [
          ..._wordsByVocabulary[vocabularyId] ?? [],
          ...result['words'],
        ];
      }

      _statsByVocabulary[vocabularyId] = result['stats'];

      _setLoading(false);
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
    }
  }

  // 단어 추가
  Future<WordModel?> addWord(
    int vocabularyId, {
    required String word,
    String? meaning,
    required String partOfSpeech,
    required String difficulty,
    String? notes,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final newWord = await _wordService.addWord(
        vocabularyId,
        word: word,
        meaning: meaning,
        partOfSpeech: partOfSpeech,
        difficulty: difficulty,
        notes: notes,
      );

      if (_wordsByVocabulary[vocabularyId] != null) {
        _wordsByVocabulary[vocabularyId]!.insert(0, newWord);
      }

      _setLoading(false);
      return newWord;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return null;
    }
  }

  // 단어 수정
  Future<bool> updateWord(
    int vocabularyId,
    int wordId,
    Map<String, dynamic> updates,
  ) async {
    _setLoading(true);
    _setError(null);

    try {
      final updatedWord = await _wordService.updateWord(
        vocabularyId,
        wordId,
        updates,
      );

      if (_wordsByVocabulary[vocabularyId] != null) {
        final index = _wordsByVocabulary[vocabularyId]!
            .indexWhere((w) => w.id == wordId);
        if (index != -1) {
          _wordsByVocabulary[vocabularyId]![index] = updatedWord;
        }
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  // 단어 삭제
  Future<bool> deleteWord(int vocabularyId, int wordId) async {
    _setLoading(true);
    _setError(null);

    try {
      await _wordService.deleteWord(vocabularyId, wordId);

      if (_wordsByVocabulary[vocabularyId] != null) {
        _wordsByVocabulary[vocabularyId]!
            .removeWhere((w) => w.id == wordId);
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  // 학습 완료 표시
  Future<bool> markAsLearned(
    int vocabularyId,
    int wordId,
    bool learned,
  ) async {
    _setLoading(true);
    _setError(null);

    try {
      final updatedWord = await _wordService.markAsLearned(
        vocabularyId,
        wordId,
        learned,
      );

      if (_wordsByVocabulary[vocabularyId] != null) {
        final index = _wordsByVocabulary[vocabularyId]!
            .indexWhere((w) => w.id == wordId);
        if (index != -1) {
          _wordsByVocabulary[vocabularyId]![index] = updatedWord;
        }
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  // 특정 단어 찾기
  WordModel? findWordById(int vocabularyId, int wordId) {
    try {
      return _wordsByVocabulary[vocabularyId]
          ?.firstWhere((w) => w.id == wordId);
    } catch (e) {
      return null;
    }
  }

  // 단어장의 모든 데이터 클리어
  void clearVocabularyWords(int vocabularyId) {
    _wordsByVocabulary.remove(vocabularyId);
    _statsByVocabulary.remove(vocabularyId);
    notifyListeners();
  }
}
