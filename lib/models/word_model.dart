class WordModel {
  final int id;
  final int vocabularyId;
  final String word;
  final String? meaning;
  final String partOfSpeech;
  final String difficulty;
  final String? notes;
  final bool learned;
  final String? learnedAt;
  final int exampleCount;
  final String createdAt;
  final String updatedAt;

  WordModel({
    required this.id,
    required this.vocabularyId,
    required this.word,
    this.meaning,
    this.partOfSpeech = 'other',
    this.difficulty = 'intermediate',
    this.notes,
    this.learned = false,
    this.learnedAt,
    this.exampleCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WordModel.fromJson(Map<String, dynamic> json) {
    return WordModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      vocabularyId: json['vocabulary_id'] is int
          ? json['vocabulary_id']
          : int.parse(json['vocabulary_id'].toString()),
      word: json['word'],
      meaning: json['meaning'],
      partOfSpeech: json['part_of_speech'] ?? 'other',
      difficulty: json['difficulty'] ?? 'intermediate',
      notes: json['notes'],
      learned: json['learned'] ?? false,
      learnedAt: json['learned_at'],
      exampleCount: json['example_count'] ?? 0,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vocabulary_id': vocabularyId,
      'word': word,
      'meaning': meaning,
      'part_of_speech': partOfSpeech,
      'difficulty': difficulty,
      'notes': notes,
      'learned': learned,
      'learned_at': learnedAt,
      'example_count': exampleCount,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  WordModel copyWith({
    int? id,
    int? vocabularyId,
    String? word,
    String? meaning,
    String? partOfSpeech,
    String? difficulty,
    String? notes,
    bool? learned,
    String? learnedAt,
    int? exampleCount,
    String? createdAt,
    String? updatedAt,
  }) {
    return WordModel(
      id: id ?? this.id,
      vocabularyId: vocabularyId ?? this.vocabularyId,
      word: word ?? this.word,
      meaning: meaning ?? this.meaning,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      difficulty: difficulty ?? this.difficulty,
      notes: notes ?? this.notes,
      learned: learned ?? this.learned,
      learnedAt: learnedAt ?? this.learnedAt,
      exampleCount: exampleCount ?? this.exampleCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum PartOfSpeech {
  noun,
  verb,
  adjective,
  adverb,
  preposition,
  other;

  String get displayName {
    switch (this) {
      case PartOfSpeech.noun:
        return '명사';
      case PartOfSpeech.verb:
        return '동사';
      case PartOfSpeech.adjective:
        return '형용사';
      case PartOfSpeech.adverb:
        return '부사';
      case PartOfSpeech.preposition:
        return '전치사';
      case PartOfSpeech.other:
        return '기타';
    }
  }

  String get apiValue => name;

  static PartOfSpeech fromApiValue(String value) {
    switch (value) {
      case 'noun':
        return PartOfSpeech.noun;
      case 'verb':
        return PartOfSpeech.verb;
      case 'adjective':
        return PartOfSpeech.adjective;
      case 'adverb':
        return PartOfSpeech.adverb;
      case 'preposition':
        return PartOfSpeech.preposition;
      default:
        return PartOfSpeech.other;
    }
  }
}

enum WordDifficulty {
  beginner,
  intermediate,
  advanced;

  String get displayName {
    switch (this) {
      case WordDifficulty.beginner:
        return '초급';
      case WordDifficulty.intermediate:
        return '중급';
      case WordDifficulty.advanced:
        return '고급';
    }
  }

  String get apiValue => name;

  static WordDifficulty fromApiValue(String value) {
    switch (value) {
      case 'beginner':
        return WordDifficulty.beginner;
      case 'intermediate':
        return WordDifficulty.intermediate;
      case 'advanced':
        return WordDifficulty.advanced;
      default:
        return WordDifficulty.intermediate;
    }
  }
}
