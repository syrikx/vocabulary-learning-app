class VocabularyStats {
  final int vocabularyId;
  final int totalWords;
  final int learnedWords;
  final int inProgress;
  final int notStarted;
  final double progressPercentage;
  final String? lastStudiedAt;
  final int studyStreakDays;
  final int totalStudyTimeMinutes;

  VocabularyStats({
    required this.vocabularyId,
    required this.totalWords,
    required this.learnedWords,
    this.inProgress = 0,
    this.notStarted = 0,
    this.progressPercentage = 0.0,
    this.lastStudiedAt,
    this.studyStreakDays = 0,
    this.totalStudyTimeMinutes = 0,
  });

  factory VocabularyStats.fromJson(Map<String, dynamic> json) {
    return VocabularyStats(
      vocabularyId: json['vocabulary_id'] is int
          ? json['vocabulary_id']
          : int.parse(json['vocabulary_id'].toString()),
      totalWords: json['total_words'] ?? 0,
      learnedWords: json['learned_words'] ?? 0,
      inProgress: json['in_progress'] ?? 0,
      notStarted: json['not_started'] ?? 0,
      progressPercentage: (json['progress_percentage'] ?? 0).toDouble(),
      lastStudiedAt: json['last_studied_at'],
      studyStreakDays: json['study_streak_days'] ?? 0,
      totalStudyTimeMinutes: json['total_study_time_minutes'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vocabulary_id': vocabularyId,
      'total_words': totalWords,
      'learned_words': learnedWords,
      'in_progress': inProgress,
      'not_started': notStarted,
      'progress_percentage': progressPercentage,
      'last_studied_at': lastStudiedAt,
      'study_streak_days': studyStreakDays,
      'total_study_time_minutes': totalStudyTimeMinutes,
    };
  }
}

class UserStats {
  final int totalVocabularies;
  final int totalWords;
  final int learnedWords;
  final double overallProgress;
  final int currentStreak;
  final int longestStreak;
  final int totalStudyDays;
  final String? favoriteCategory;
  final List<DailyActivity> recentActivity;

  UserStats({
    required this.totalVocabularies,
    required this.totalWords,
    required this.learnedWords,
    this.overallProgress = 0.0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalStudyDays = 0,
    this.favoriteCategory,
    this.recentActivity = const [],
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalVocabularies: json['total_vocabularies'] ?? 0,
      totalWords: json['total_words'] ?? 0,
      learnedWords: json['learned_words'] ?? 0,
      overallProgress: (json['overall_progress'] ?? 0).toDouble(),
      currentStreak: json['current_streak'] ?? 0,
      longestStreak: json['longest_streak'] ?? 0,
      totalStudyDays: json['total_study_days'] ?? 0,
      favoriteCategory: json['favorite_category'],
      recentActivity: json['recent_activity'] != null
          ? (json['recent_activity'] as List)
              .map((a) => DailyActivity.fromJson(a))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_vocabularies': totalVocabularies,
      'total_words': totalWords,
      'learned_words': learnedWords,
      'overall_progress': overallProgress,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'total_study_days': totalStudyDays,
      'favorite_category': favoriteCategory,
      'recent_activity': recentActivity.map((a) => a.toJson()).toList(),
    };
  }
}

class DailyActivity {
  final String date;
  final int wordsLearned;
  final int studyTimeMinutes;

  DailyActivity({
    required this.date,
    required this.wordsLearned,
    required this.studyTimeMinutes,
  });

  factory DailyActivity.fromJson(Map<String, dynamic> json) {
    return DailyActivity(
      date: json['date'],
      wordsLearned: json['words_learned'] ?? 0,
      studyTimeMinutes: json['study_time_minutes'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'words_learned': wordsLearned,
      'study_time_minutes': studyTimeMinutes,
    };
  }
}

class PaginationMeta {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  PaginationMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      total: json['total'] ?? 0,
      totalPages: json['total_pages'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'total': total,
      'total_pages': totalPages,
    };
  }
}
