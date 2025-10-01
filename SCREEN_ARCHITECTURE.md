# Vocabulary App - Screen Architecture

## 앱 화면 구조

### 네비게이션 플로우
```
LoginScreen
    ↓ (로그인 성공)
HomeScreen (TabBar)
    ├─ VocabularyListScreen (내 단어장)
    │   ├─ CreateVocabularyScreen (단어장 생성)
    │   ├─ VocabularyDetailScreen (단어 목록)
    │   │   ├─ AddWordScreen (단어 추가)
    │   │   ├─ EditWordScreen (단어 수정)
    │   │   └─ WordStudyScreen (예문 학습)
    │   │       └─ SentenceDetailScreen (예문 상세)
    │   └─ EditVocabularyScreen (단어장 수정)
    │
    ├─ ExploreScreen (공개 단어장 탐색)
    │   └─ PublicVocabularyDetailScreen (미리보기)
    │
    ├─ StudyScreen (학습)
    │   └─ QuizScreen (퀴즈/복습)
    │
    └─ ProfileScreen (프로필)
        ├─ StatsScreen (학습 통계)
        └─ SettingsScreen (설정)
```

---

## 화면별 상세 명세

### 1. HomeScreen
**파일:** `lib/screens/home_screen.dart`

**기능:**
- BottomNavigationBar로 4개 탭 관리
- 탭: 단어장 / 탐색 / 학습 / 프로필

**주요 위젯:**
- `BottomNavigationBar` (4개 탭)
- `IndexedStack` (화면 유지)

**API 호출:** 없음 (탭 전환만)

---

### 2. VocabularyListScreen (내 단어장 목록)
**파일:** `lib/screens/vocabulary/vocabulary_list_screen.dart`

**기능:**
- 내 단어장 목록 표시
- 단어장 검색/필터링
- 단어장 생성 버튼
- 각 단어장 클릭 → 단어 목록으로 이동

**주요 위젯:**
```dart
Scaffold(
  appBar: AppBar(
    title: Text('내 단어장'),
    actions: [
      IconButton(icon: Icon(Icons.search)),
      IconButton(icon: Icon(Icons.filter_list)),
    ],
  ),
  body: RefreshIndicator(
    child: ListView.builder(
      itemBuilder: (context, index) => VocabularyCard(),
    ),
  ),
  floatingActionButton: FloatingActionButton(
    child: Icon(Icons.add),
    onPressed: () => Navigator.push(CreateVocabularyScreen()),
  ),
)
```

**API 호출:**
- `GET /api/vocabularies/my`
  - Query: page, limit, sort, order
  - 응답: 단어장 목록 + 페이지네이션

**State Management:**
```dart
class VocabularyListProvider extends ChangeNotifier {
  List<VocabularyModel> vocabularies = [];
  bool isLoading = false;
  int currentPage = 1;

  Future<void> fetchVocabularies({bool refresh = false});
  Future<void> deleteVocabulary(int id);
}
```

---

### 3. CreateVocabularyScreen (단어장 생성)
**파일:** `lib/screens/vocabulary/create_vocabulary_screen.dart`

**기능:**
- 새 단어장 생성 폼
- 제목, 설명, 공개여부, 카테고리, 난이도 입력

**Form Fields:**
```dart
- TextFormField: title (필수, 1-100자)
- TextFormField: description (선택, 500자)
- SwitchListTile: is_public (공개/비공개)
- DropdownButton: category
- DropdownButton: target_level
```

**API 호출:**
- `POST /api/vocabularies`
  - Body: title, description, is_public, category, target_level
  - 성공 시 → 생성된 단어장 상세 화면으로 이동

**Validation:**
```dart
title.validator = (value) {
  if (value == null || value.isEmpty) return '제목을 입력하세요';
  if (value.length > 100) return '제목은 100자 이내로 입력하세요';
  return null;
}
```

---

### 4. VocabularyDetailScreen (단어 목록)
**파일:** `lib/screens/vocabulary/vocabulary_detail_screen.dart`

**기능:**
- 선택한 단어장의 단어 목록 표시
- 단어 추가 버튼
- 단어 검색/필터링 (학습완료/미완료)
- 학습 진행률 표시
- 각 단어 클릭 → 예문 학습 화면

**주요 위젯:**
```dart
Scaffold(
  appBar: AppBar(
    title: Text(vocabulary.title),
    actions: [
      IconButton(icon: Icon(Icons.edit)), // 단어장 수정
      IconButton(icon: Icon(Icons.search)), // 단어 검색
    ],
  ),
  body: Column(
    children: [
      ProgressIndicator(progress: stats.progressPercentage),
      FilterChips(learned: true/false/all),
      Expanded(
        child: ListView.builder(
          itemBuilder: (context, index) => WordCard(
            word: words[index],
            onTap: () => Navigator.push(WordStudyScreen()),
          ),
        ),
      ),
    ],
  ),
  floatingActionButton: FloatingActionButton(
    child: Icon(Icons.add),
    onPressed: () => Navigator.push(AddWordScreen()),
  ),
)
```

**API 호출:**
- `GET /api/vocabularies/{id}/words`
  - Query: page, limit, learned, difficulty, sort
  - 응답: 단어 목록 + 통계
- `GET /api/vocabularies/{id}/stats`
  - 응답: 학습 진행도

---

### 5. AddWordScreen (단어 추가)
**파일:** `lib/screens/vocabulary/add_word_screen.dart`

**기능:**
- 단어장에 새 단어 추가
- 단어, 뜻, 품사, 난이도, 메모 입력

**Form Fields:**
```dart
- TextFormField: word (필수, 영문만, 1-50자)
- TextFormField: meaning (선택, 200자)
- DropdownButton: part_of_speech
- DropdownButton: difficulty
- TextFormField: notes (선택)
```

**API 호출:**
- `POST /api/vocabularies/{id}/words`
  - Body: word, meaning, part_of_speech, difficulty, notes
  - 성공 시 → 단어 목록으로 돌아가기

**Validation:**
```dart
word.validator = (value) {
  if (value == null || value.isEmpty) return '단어를 입력하세요';
  if (!RegExp(r'^[a-zA-Z\s-]+$').hasMatch(value)) {
    return '영문자만 입력 가능합니다';
  }
  return null;
}
```

---

### 6. WordStudyScreen (예문 학습)
**파일:** `lib/screens/study/word_study_screen.dart`

**기능:**
- 선택한 단어의 예문 표시
- 뜻 보기/숨기기 토글
- 예문 북마크
- TTS (Text-to-Speech) 재생
- 학습 완료 버튼

**주요 위젯:**
```dart
Scaffold(
  appBar: AppBar(
    title: Text(word.word),
    actions: [
      IconButton(
        icon: Icon(showMeaning ? Icons.visibility_off : Icons.visibility),
        onPressed: () => toggleMeaning(),
      ),
    ],
  ),
  body: Column(
    children: [
      WordCard(
        word: word.word,
        meaning: showMeaning ? word.meaning : '???',
        partOfSpeech: word.partOfSpeech,
      ),
      Divider(),
      Text('예문', style: headline),
      Expanded(
        child: ListView.builder(
          itemBuilder: (context, index) => SentenceCard(
            sentence: sentences[index],
            onBookmark: () => bookmarkSentence(sentence.id),
            onPlayAudio: () => playTTS(sentence.text),
          ),
        ),
      ),
      ElevatedButton(
        child: Text('학습 완료'),
        onPressed: () => markAsLearned(),
      ),
    ],
  ),
)
```

**API 호출:**
- `POST /api/example_sentence`
  - Body: word, years, user_sentences, count
  - 응답: 예문 목록
- `POST /api/vocabularies/{vocab_id}/words/{word_id}/mark-learned`
  - Body: learned: true
- `POST /api/vocabularies/{vocab_id}/words/{word_id}/sentences/{sentence_id}/bookmark`

---

### 7. ExploreScreen (공개 단어장 탐색)
**파일:** `lib/screens/explore/explore_screen.dart`

**기능:**
- 공개 단어장 검색
- 카테고리별 필터링
- 인기순/최신순 정렬
- 단어장 다운로드

**주요 위젯:**
```dart
Scaffold(
  appBar: AppBar(
    title: TextField(
      decoration: InputDecoration(hintText: '단어장 검색'),
      onSubmitted: (query) => searchVocabularies(query),
    ),
  ),
  body: Column(
    children: [
      FilterChips(categories: [...]),
      SortButtons(sort: ['popular', 'recent', 'word_count']),
      Expanded(
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          itemBuilder: (context, index) => PublicVocabularyCard(
            vocabulary: publicVocabs[index],
            onDownload: () => downloadVocabulary(id),
          ),
        ),
      ),
    ],
  ),
)
```

**API 호출:**
- `GET /api/vocabularies/public`
  - Query: q, category, target_level, min_words, sort, page
  - 응답: 공개 단어장 목록
- `POST /api/vocabularies/{id}/download`
  - 응답: 다운로드된 단어장 정보

---

### 8. StudyScreen (학습 대시보드)
**파일:** `lib/screens/study/study_screen.dart`

**기능:**
- 학습 통계 대시보드
- 오늘의 학습 목표
- 연속 학습 일수 (Streak)
- 최근 학습한 단어장
- 퀴즈 시작 버튼

**주요 위젯:**
```dart
Scaffold(
  body: SingleChildScrollView(
    child: Column(
      children: [
        StatsCard(
          totalWords: stats.totalWords,
          learnedWords: stats.learnedWords,
          progressPercentage: stats.overallProgress,
        ),
        StreakCard(
          currentStreak: stats.currentStreak,
          longestStreak: stats.longestStreak,
        ),
        RecentActivityChart(
          data: stats.recentActivity,
        ),
        RecentVocabulariesList(),
        ElevatedButton(
          child: Text('퀴즈 시작'),
          onPressed: () => Navigator.push(QuizScreen()),
        ),
      ],
    ),
  ),
)
```

**API 호출:**
- `GET /api/users/me/stats`
  - 응답: 전체 학습 통계

---

### 9. ProfileScreen (프로필)
**파일:** `lib/screens/profile/profile_screen.dart`

**기능:**
- 사용자 정보 표시
- 학습 통계 요약
- 설정 메뉴
- 로그아웃

**주요 위젯:**
```dart
Scaffold(
  body: ListView(
    children: [
      UserHeader(user: currentUser),
      QuickStatsCard(),
      ListTile(
        leading: Icon(Icons.bar_chart),
        title: Text('학습 통계'),
        onTap: () => Navigator.push(StatsScreen()),
      ),
      ListTile(
        leading: Icon(Icons.settings),
        title: Text('설정'),
        onTap: () => Navigator.push(SettingsScreen()),
      ),
      ListTile(
        leading: Icon(Icons.logout),
        title: Text('로그아웃'),
        onTap: () => logout(),
      ),
    ],
  ),
)
```

**API 호출:**
- `GET /api/users/me/stats` (요약 버전)

---

## Models

### VocabularyModel
**파일:** `lib/models/vocabulary_model.dart`

```dart
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
  final String createdAt;
  final String updatedAt;

  VocabularyModel({...});

  factory VocabularyModel.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

### WordModel
**파일:** `lib/models/word_model.dart`

```dart
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

  WordModel({...});

  factory WordModel.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

### SentenceModel
**파일:** `lib/models/sentence_model.dart`

```dart
class SentenceModel {
  final int id;
  final String text;
  final bool? isBookmarked;

  SentenceModel({...});

  factory SentenceModel.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

---

## Services

### VocabularyService
**파일:** `lib/services/vocabulary_service.dart`

```dart
class VocabularyService {
  final ApiAuthService _authService;

  Future<List<VocabularyModel>> getMyVocabularies({...});
  Future<List<VocabularyModel>> getPublicVocabularies({...});
  Future<VocabularyModel> createVocabulary(VocabularyModel vocab);
  Future<VocabularyModel> updateVocabulary(int id, Map<String, dynamic> data);
  Future<void> deleteVocabulary(int id);
  Future<VocabularyModel> downloadVocabulary(int id);
}
```

### WordService
**파일:** `lib/services/word_service.dart`

```dart
class WordService {
  Future<List<WordModel>> getWords(int vocabularyId, {...});
  Future<WordModel> addWord(int vocabularyId, WordModel word);
  Future<WordModel> updateWord(int vocabularyId, int wordId, {...});
  Future<void> deleteWord(int vocabularyId, int wordId);
  Future<void> markAsLearned(int vocabularyId, int wordId, bool learned);
}
```

### SentenceService
**파일:** `lib/services/sentence_service.dart`

```dart
class SentenceService {
  Future<List<SentenceModel>> getSentences(String word, int years, {...});
  Future<void> bookmarkSentence(int wordId, int sentenceId);
}
```

---

## Providers

### VocabularyProvider
**파일:** `lib/providers/vocabulary_provider.dart`

```dart
class VocabularyProvider extends ChangeNotifier {
  List<VocabularyModel> _vocabularies = [];
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> fetchMyVocabularies();
  Future<void> createVocabulary(VocabularyModel vocab);
  Future<void> deleteVocabulary(int id);
  // ...
}
```

### WordProvider
**파일:** `lib/providers/word_provider.dart`

```dart
class WordProvider extends ChangeNotifier {
  List<WordModel> _words = [];
  VocabularyStats? _stats;

  Future<void> fetchWords(int vocabularyId);
  Future<void> addWord(int vocabularyId, WordModel word);
  Future<void> markAsLearned(int vocabularyId, int wordId);
  // ...
}
```

---

## 디렉토리 구조

```
lib/
├── main.dart
├── models/
│   ├── user_model.dart
│   ├── vocabulary_model.dart
│   ├── word_model.dart
│   ├── sentence_model.dart
│   └── stats_model.dart
├── services/
│   ├── api_auth_service.dart
│   ├── vocabulary_service.dart
│   ├── word_service.dart
│   └── sentence_service.dart
├── providers/
│   ├── auth_provider.dart
│   ├── vocabulary_provider.dart
│   ├── word_provider.dart
│   └── stats_provider.dart
├── screens/
│   ├── login_screen.dart
│   ├── signup_screen.dart
│   ├── home_screen.dart
│   ├── vocabulary/
│   │   ├── vocabulary_list_screen.dart
│   │   ├── create_vocabulary_screen.dart
│   │   ├── vocabulary_detail_screen.dart
│   │   ├── edit_vocabulary_screen.dart
│   │   ├── add_word_screen.dart
│   │   └── edit_word_screen.dart
│   ├── explore/
│   │   ├── explore_screen.dart
│   │   └── public_vocabulary_detail_screen.dart
│   ├── study/
│   │   ├── study_screen.dart
│   │   ├── word_study_screen.dart
│   │   ├── sentence_detail_screen.dart
│   │   └── quiz_screen.dart
│   └── profile/
│       ├── profile_screen.dart
│       ├── stats_screen.dart
│       └── settings_screen.dart
└── widgets/
    ├── vocabulary_card.dart
    ├── word_card.dart
    ├── sentence_card.dart
    ├── progress_indicator.dart
    ├── stats_card.dart
    └── loading_indicator.dart
```

---

## 개발 우선순위

### Phase 1: 핵심 기능 (MVP)
1. ✅ 로그인/회원가입 (완료)
2. 단어장 CRUD
3. 단어 CRUD
4. 예문 조회 및 학습

### Phase 2: 탐색 및 공유
5. 공개 단어장 검색
6. 단어장 다운로드
7. 북마크 기능

### Phase 3: 학습 강화
8. 학습 통계
9. 퀴즈/복습
10. TTS 기능

### Phase 4: 개선
11. 오프라인 모드
12. 알림/리마인더
13. 소셜 기능 (공유, 좋아요)
