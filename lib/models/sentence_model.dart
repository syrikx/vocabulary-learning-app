class SentenceModel {
  final int id;
  final String text;
  final bool isBookmarked;

  SentenceModel({
    required this.id,
    required this.text,
    this.isBookmarked = false,
  });

  factory SentenceModel.fromJson(Map<String, dynamic> json) {
    return SentenceModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      text: json['text'],
      isBookmarked: json['is_bookmarked'] ?? json['isBookmarked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'is_bookmarked': isBookmarked,
    };
  }

  SentenceModel copyWith({
    int? id,
    String? text,
    bool? isBookmarked,
  }) {
    return SentenceModel(
      id: id ?? this.id,
      text: text ?? this.text,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}

class SentenceResponse {
  final String word;
  final int years;
  final String source;
  final List<SentenceModel> sentences;
  final int totalAvailable;
  final String timestamp;
  final int? aiCallsSaved;

  SentenceResponse({
    required this.word,
    required this.years,
    required this.source,
    required this.sentences,
    required this.totalAvailable,
    required this.timestamp,
    this.aiCallsSaved,
  });

  factory SentenceResponse.fromJson(Map<String, dynamic> json) {
    return SentenceResponse(
      word: json['word'],
      years: json['years'],
      source: json['source'],
      sentences: (json['sentences'] as List)
          .map((s) => SentenceModel.fromJson(s))
          .toList(),
      totalAvailable: json['total_available'],
      timestamp: json['timestamp'],
      aiCallsSaved: json['ai_calls_saved'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'years': years,
      'source': source,
      'sentences': sentences.map((s) => s.toJson()).toList(),
      'total_available': totalAvailable,
      'timestamp': timestamp,
      'ai_calls_saved': aiCallsSaved,
    };
  }
}
