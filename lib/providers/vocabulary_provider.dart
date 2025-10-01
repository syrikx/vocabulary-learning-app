import 'package:flutter/material.dart';
import '../models/vocabulary_model.dart';
import '../models/stats_model.dart';
import '../services/vocabulary_service.dart';
import '../services/api_auth_service.dart';

class VocabularyProvider with ChangeNotifier {
  final VocabularyService _vocabularyService;

  List<VocabularyModel> _vocabularies = [];
  List<VocabularyModel> _publicVocabularies = [];
  PaginationMeta? _pagination;
  PaginationMeta? _publicPagination;
  bool _isLoading = false;
  String? _errorMessage;

  List<VocabularyModel> get vocabularies => _vocabularies;
  List<VocabularyModel> get publicVocabularies => _publicVocabularies;
  PaginationMeta? get pagination => _pagination;
  PaginationMeta? get publicPagination => _publicPagination;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  VocabularyProvider(ApiAuthService authService)
      : _vocabularyService = VocabularyService(authService);

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

  // 내 단어장 목록 조회
  Future<void> fetchMyVocabularies({
    bool refresh = false,
    int page = 1,
    String sort = 'updated_at',
    String order = 'desc',
  }) async {
    if (refresh) {
      _vocabularies = [];
      _pagination = null;
    }

    _setLoading(true);
    _setError(null);

    try {
      final result = await _vocabularyService.getMyVocabularies(
        page: page,
        sort: sort,
        order: order,
      );

      if (refresh || page == 1) {
        _vocabularies = result['vocabularies'];
      } else {
        _vocabularies.addAll(result['vocabularies']);
      }

      _pagination = result['pagination'];
      _setLoading(false);
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
    }
  }

  // 공개 단어장 검색
  Future<void> searchPublicVocabularies({
    String? query,
    String? category,
    String? targetLevel,
    int? minWords,
    String sort = 'popular',
    int page = 1,
    bool refresh = false,
  }) async {
    if (refresh) {
      _publicVocabularies = [];
      _publicPagination = null;
    }

    _setLoading(true);
    _setError(null);

    try {
      final result = await _vocabularyService.getPublicVocabularies(
        query: query,
        category: category,
        targetLevel: targetLevel,
        minWords: minWords,
        sort: sort,
        page: page,
      );

      if (refresh || page == 1) {
        _publicVocabularies = result['vocabularies'];
      } else {
        _publicVocabularies.addAll(result['vocabularies']);
      }

      _publicPagination = result['pagination'];
      _setLoading(false);
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
    }
  }

  // 단어장 생성
  Future<VocabularyModel?> createVocabulary({
    required String title,
    String? description,
    bool isPublic = false,
    required String category,
    required String targetLevel,
    String language = 'en',
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final vocabulary = await _vocabularyService.createVocabulary(
        title: title,
        description: description,
        isPublic: isPublic,
        category: category,
        targetLevel: targetLevel,
        language: language,
      );

      _vocabularies.insert(0, vocabulary);
      _setLoading(false);
      return vocabulary;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return null;
    }
  }

  // 단어장 수정
  Future<bool> updateVocabulary(
    int vocabularyId,
    Map<String, dynamic> updates,
  ) async {
    _setLoading(true);
    _setError(null);

    try {
      final updatedVocabulary = await _vocabularyService.updateVocabulary(
        vocabularyId,
        updates,
      );

      final index = _vocabularies.indexWhere((v) => v.id == vocabularyId);
      if (index != -1) {
        _vocabularies[index] = updatedVocabulary;
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  // 단어장 삭제
  Future<bool> deleteVocabulary(int vocabularyId) async {
    _setLoading(true);
    _setError(null);

    try {
      await _vocabularyService.deleteVocabulary(vocabularyId);

      _vocabularies.removeWhere((v) => v.id == vocabularyId);

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  // 단어장 다운로드
  Future<VocabularyModel?> downloadVocabulary(int vocabularyId) async {
    _setLoading(true);
    _setError(null);

    try {
      final vocabulary = await _vocabularyService.downloadVocabulary(vocabularyId);

      _vocabularies.insert(0, vocabulary);

      _setLoading(false);
      return vocabulary;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return null;
    }
  }

  // 단어장 통계 조회
  Future<VocabularyStats?> getVocabularyStats(int vocabularyId) async {
    try {
      return await _vocabularyService.getVocabularyStats(vocabularyId);
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return null;
    }
  }

  // 특정 단어장 찾기
  VocabularyModel? findById(int id) {
    try {
      return _vocabularies.firstWhere((v) => v.id == id);
    } catch (e) {
      return null;
    }
  }
}
