class VocabularyModel {
  final int id;
  final int userId;
  final String title;
  final String? description;
  final bool isPublic;
  final String category;
  final String targetLevel;
  final String language;
  final int wordCount;
  final int downloadCount;
  final int? originalId;
  final String? username;
  final double? rating;
  final String createdAt;
  final String updatedAt;

  VocabularyModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.isPublic,
    required this.category,
    required this.targetLevel,
    this.language = 'en',
    this.wordCount = 0,
    this.downloadCount = 0,
    this.originalId,
    this.username,
    this.rating,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VocabularyModel.fromJson(Map<String, dynamic> json) {
    return VocabularyModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      userId: json['user_id'] is int ? json['user_id'] : int.parse(json['user_id'].toString()),
      title: json['title'],
      description: json['description'],
      isPublic: json['is_public'] ?? false,
      category: json['category'] ?? 'general',
      targetLevel: json['target_level'] ?? 'intermediate',
      language: json['language'] ?? 'en',
      wordCount: json['word_count'] ?? 0,
      downloadCount: json['download_count'] ?? 0,
      originalId: json['original_id'],
      username: json['username'],
      rating: json['rating']?.toDouble(),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'is_public': isPublic,
      'category': category,
      'target_level': targetLevel,
      'language': language,
      'word_count': wordCount,
      'download_count': downloadCount,
      'original_id': originalId,
      'username': username,
      'rating': rating,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  VocabularyModel copyWith({
    int? id,
    int? userId,
    String? title,
    String? description,
    bool? isPublic,
    String? category,
    String? targetLevel,
    String? language,
    int? wordCount,
    int? downloadCount,
    int? originalId,
    String? username,
    double? rating,
    String? createdAt,
    String? updatedAt,
  }) {
    return VocabularyModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      isPublic: isPublic ?? this.isPublic,
      category: category ?? this.category,
      targetLevel: targetLevel ?? this.targetLevel,
      language: language ?? this.language,
      wordCount: wordCount ?? this.wordCount,
      downloadCount: downloadCount ?? this.downloadCount,
      originalId: originalId ?? this.originalId,
      username: username ?? this.username,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum VocabularyCategory {
  general,
  examPrep,
  business,
  travel,
  academic,
  custom;

  String get displayName {
    switch (this) {
      case VocabularyCategory.general:
        return '일반';
      case VocabularyCategory.examPrep:
        return '시험 준비';
      case VocabularyCategory.business:
        return '비즈니스';
      case VocabularyCategory.travel:
        return '여행';
      case VocabularyCategory.academic:
        return '학술';
      case VocabularyCategory.custom:
        return '커스텀';
    }
  }

  String get apiValue {
    switch (this) {
      case VocabularyCategory.general:
        return 'general';
      case VocabularyCategory.examPrep:
        return 'exam_prep';
      case VocabularyCategory.business:
        return 'business';
      case VocabularyCategory.travel:
        return 'travel';
      case VocabularyCategory.academic:
        return 'academic';
      case VocabularyCategory.custom:
        return 'custom';
    }
  }

  static VocabularyCategory fromApiValue(String value) {
    switch (value) {
      case 'exam_prep':
        return VocabularyCategory.examPrep;
      case 'business':
        return VocabularyCategory.business;
      case 'travel':
        return VocabularyCategory.travel;
      case 'academic':
        return VocabularyCategory.academic;
      case 'custom':
        return VocabularyCategory.custom;
      default:
        return VocabularyCategory.general;
    }
  }
}

enum TargetLevel {
  beginner,
  intermediate,
  advanced;

  String get displayName {
    switch (this) {
      case TargetLevel.beginner:
        return '초급';
      case TargetLevel.intermediate:
        return '중급';
      case TargetLevel.advanced:
        return '고급';
    }
  }

  String get apiValue => name;

  static TargetLevel fromApiValue(String value) {
    switch (value) {
      case 'beginner':
        return TargetLevel.beginner;
      case 'intermediate':
        return TargetLevel.intermediate;
      case 'advanced':
        return TargetLevel.advanced;
      default:
        return TargetLevel.intermediate;
    }
  }
}
