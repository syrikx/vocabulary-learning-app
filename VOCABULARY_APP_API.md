# Vocabulary App - API Documentation

## 앱 개요
단어와 예문을 연결하여 학습하는 영어 단어장 앱. 예문을 통해 단어의 의미를 자연스럽게 이해하고, 원한다면 뜻도 확인할 수 있습니다.

## Base URL
```
http://eng.gunsiya.com
```

---

## 주요 기능

1. **단어장 관리**
   - 단어장 생성/수정/삭제
   - 내 단어장 목록 조회
   - 공개 단어장 검색 및 다운로드

2. **단어 관리**
   - 단어장에 단어 추가
   - 단어 수정/삭제
   - 단어 목록 조회

3. **예문 학습**
   - 단어별 예문 조회 (AI 생성 + DB 캐시)
   - 예문 북마크/좋아요
   - 학습 진행도 추적

---

## 1. 단어장 APIs

### 1.1 단어장 생성
사용자가 새로운 단어장을 생성합니다.

**Endpoint:** `POST /api/vocabularies`

**Headers:**
```
Authorization: Bearer {accessToken}
Content-Type: application/json
```

**Request Body:**
```json
{
  "title": "TOEFL Essential Words",
  "description": "TOEFL 시험 필수 단어 모음",
  "is_public": true,
  "category": "exam_prep",
  "target_level": "intermediate",
  "language": "en"
}
```

**Validation Rules:**
- **title**: 1-100자, 필수
- **description**: 0-500자, 선택
- **is_public**: boolean (기본값: false)
- **category**: enum ["general", "exam_prep", "business", "travel", "academic", "custom"]
- **target_level**: enum ["beginner", "intermediate", "advanced"]
- **language**: ISO 639-1 코드 (기본값: "en")

**Success Response (201):**
```json
{
  "message": "Vocabulary created successfully",
  "vocabulary": {
    "id": 1,
    "user_id": 123,
    "title": "TOEFL Essential Words",
    "description": "TOEFL 시험 필수 단어 모음",
    "is_public": true,
    "category": "exam_prep",
    "target_level": "intermediate",
    "language": "en",
    "word_count": 0,
    "download_count": 0,
    "created_at": "2025-10-01T12:00:00.000Z",
    "updated_at": "2025-10-01T12:00:00.000Z"
  }
}
```

**Error Responses:**
- **400**: Validation error
- **401**: Unauthorized (토큰 없음/만료)

---

### 1.2 내 단어장 목록 조회
로그인한 사용자의 단어장 목록을 조회합니다.

**Endpoint:** `GET /api/vocabularies/my`

**Headers:**
```
Authorization: Bearer {accessToken}
```

**Query Parameters:**
- `page` (optional): 페이지 번호 (기본값: 1)
- `limit` (optional): 페이지당 개수 (기본값: 20, 최대: 100)
- `sort` (optional): 정렬 기준 ["created_at", "updated_at", "title", "word_count"] (기본값: "updated_at")
- `order` (optional): 정렬 순서 ["asc", "desc"] (기본값: "desc")

**Success Response (200):**
```json
{
  "vocabularies": [
    {
      "id": 1,
      "title": "TOEFL Essential Words",
      "description": "TOEFL 시험 필수 단어 모음",
      "is_public": true,
      "category": "exam_prep",
      "target_level": "intermediate",
      "word_count": 150,
      "download_count": 45,
      "created_at": "2025-10-01T12:00:00.000Z",
      "updated_at": "2025-10-01T12:00:00.000Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 5,
    "total_pages": 1
  }
}
```

---

### 1.3 공개 단어장 검색
공개된 단어장을 검색하고 다운로드할 수 있습니다.

**Endpoint:** `GET /api/vocabularies/public`

**Query Parameters:**
- `q` (optional): 검색 키워드 (제목, 설명에서 검색)
- `category` (optional): 카테고리 필터
- `target_level` (optional): 난이도 필터
- `min_words` (optional): 최소 단어 수
- `sort` (optional): ["popular", "recent", "word_count"] (기본값: "popular")
- `page` (optional): 페이지 번호
- `limit` (optional): 페이지당 개수

**Success Response (200):**
```json
{
  "vocabularies": [
    {
      "id": 42,
      "user_id": 99,
      "username": "english_master",
      "title": "Daily English Conversations",
      "description": "일상 회화 필수 표현",
      "category": "general",
      "target_level": "beginner",
      "word_count": 200,
      "download_count": 1250,
      "rating": 4.7,
      "created_at": "2025-09-15T12:00:00.000Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 150,
    "total_pages": 8
  }
}
```

---

### 1.4 단어장 다운로드 (복사)
공개 단어장을 내 계정으로 복사합니다.

**Endpoint:** `POST /api/vocabularies/{vocabulary_id}/download`

**Headers:**
```
Authorization: Bearer {accessToken}
```

**Success Response (201):**
```json
{
  "message": "Vocabulary downloaded successfully",
  "vocabulary": {
    "id": 150,
    "title": "Daily English Conversations (복사본)",
    "description": "일상 회화 필수 표현",
    "word_count": 200,
    "original_id": 42,
    "created_at": "2025-10-01T12:00:00.000Z"
  }
}
```

**Error Responses:**
- **404**: Vocabulary not found
- **403**: Vocabulary is private
- **409**: Already downloaded

---

### 1.5 단어장 수정

**Endpoint:** `PUT /api/vocabularies/{vocabulary_id}`

**Headers:**
```
Authorization: Bearer {accessToken}
Content-Type: application/json
```

**Request Body:**
```json
{
  "title": "Updated Title",
  "description": "Updated description",
  "is_public": false,
  "category": "business"
}
```

**Success Response (200):**
```json
{
  "message": "Vocabulary updated successfully",
  "vocabulary": {
    "id": 1,
    "title": "Updated Title",
    "updated_at": "2025-10-01T13:00:00.000Z"
  }
}
```

**Error Responses:**
- **403**: Not the owner
- **404**: Vocabulary not found

---

### 1.6 단어장 삭제

**Endpoint:** `DELETE /api/vocabularies/{vocabulary_id}`

**Headers:**
```
Authorization: Bearer {accessToken}
```

**Success Response (200):**
```json
{
  "message": "Vocabulary deleted successfully"
}
```

**Error Responses:**
- **403**: Not the owner
- **404**: Vocabulary not found

---

## 2. 단어 APIs

### 2.1 단어장에 단어 추가

**Endpoint:** `POST /api/vocabularies/{vocabulary_id}/words`

**Headers:**
```
Authorization: Bearer {accessToken}
Content-Type: application/json
```

**Request Body:**
```json
{
  "word": "ephemeral",
  "meaning": "일시적인, 덧없는 (선택)",
  "part_of_speech": "adjective",
  "difficulty": "advanced",
  "notes": "사용자 메모 (선택)"
}
```

**Validation Rules:**
- **word**: 1-50자, 필수, 영문자만
- **meaning**: 0-200자, 선택
- **part_of_speech**: enum ["noun", "verb", "adjective", "adverb", "preposition", "other"]
- **difficulty**: enum ["beginner", "intermediate", "advanced"]

**Success Response (201):**
```json
{
  "message": "Word added successfully",
  "word": {
    "id": 1001,
    "vocabulary_id": 1,
    "word": "ephemeral",
    "meaning": "일시적인, 덧없는",
    "part_of_speech": "adjective",
    "difficulty": "advanced",
    "notes": "",
    "example_count": 0,
    "learned": false,
    "created_at": "2025-10-01T12:00:00.000Z"
  }
}
```

**Error Responses:**
- **400**: Validation error
- **403**: Not the owner of vocabulary
- **409**: Word already exists in this vocabulary

---

### 2.2 단어장의 단어 목록 조회

**Endpoint:** `GET /api/vocabularies/{vocabulary_id}/words`

**Headers:**
```
Authorization: Bearer {accessToken}
```

**Query Parameters:**
- `page` (optional): 페이지 번호
- `limit` (optional): 페이지당 개수
- `learned` (optional): 학습 완료 필터 (true/false/all, 기본값: all)
- `difficulty` (optional): 난이도 필터
- `sort` (optional): ["alphabetical", "created_at", "difficulty"] (기본값: "created_at")

**Success Response (200):**
```json
{
  "words": [
    {
      "id": 1001,
      "word": "ephemeral",
      "meaning": "일시적인, 덧없는",
      "part_of_speech": "adjective",
      "difficulty": "advanced",
      "notes": "",
      "example_count": 5,
      "learned": false,
      "created_at": "2025-10-01T12:00:00.000Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 150,
    "total_pages": 8
  },
  "stats": {
    "total_words": 150,
    "learned_words": 45,
    "progress_percentage": 30
  }
}
```

---

### 2.3 단어 수정

**Endpoint:** `PUT /api/vocabularies/{vocabulary_id}/words/{word_id}`

**Headers:**
```
Authorization: Bearer {accessToken}
Content-Type: application/json
```

**Request Body:**
```json
{
  "meaning": "Updated meaning",
  "notes": "Updated notes",
  "learned": true
}
```

**Success Response (200):**
```json
{
  "message": "Word updated successfully",
  "word": {
    "id": 1001,
    "word": "ephemeral",
    "meaning": "Updated meaning",
    "learned": true,
    "updated_at": "2025-10-01T13:00:00.000Z"
  }
}
```

---

### 2.4 단어 삭제

**Endpoint:** `DELETE /api/vocabularies/{vocabulary_id}/words/{word_id}`

**Headers:**
```
Authorization: Bearer {accessToken}
```

**Success Response (200):**
```json
{
  "message": "Word deleted successfully"
}
```

---

## 3. 예문 APIs

### 3.1 단어의 예문 조회 (기존 API 활용)

**Endpoint:** `POST /api/example_sentence`

**Request Body:**
```json
{
  "word": "ephemeral",
  "years": 15,
  "user_sentences": [],
  "count": 5
}
```

**Success Response (200):**
```json
{
  "word": "ephemeral",
  "years": 15,
  "source": "database",
  "sentences": [
    {
      "id": 101,
      "text": "The beauty of cherry blossoms is ephemeral."
    },
    {
      "id": 102,
      "text": "Social media fame is often ephemeral."
    }
  ],
  "total_available": 10,
  "timestamp": "2025-10-01T12:00:00.000Z"
}
```

---

### 3.2 예문 북마크

**Endpoint:** `POST /api/vocabularies/{vocabulary_id}/words/{word_id}/sentences/{sentence_id}/bookmark`

**Headers:**
```
Authorization: Bearer {accessToken}
```

**Success Response (200):**
```json
{
  "message": "Sentence bookmarked successfully",
  "bookmarked": true
}
```

---

### 3.3 단어 학습 완료 표시

**Endpoint:** `POST /api/vocabularies/{vocabulary_id}/words/{word_id}/mark-learned`

**Headers:**
```
Authorization: Bearer {accessToken}
```

**Request Body:**
```json
{
  "learned": true
}
```

**Success Response (200):**
```json
{
  "message": "Word marked as learned",
  "word": {
    "id": 1001,
    "word": "ephemeral",
    "learned": true,
    "learned_at": "2025-10-01T12:00:00.000Z"
  }
}
```

---

## 4. 학습 진행도 APIs

### 4.1 단어장 학습 통계

**Endpoint:** `GET /api/vocabularies/{vocabulary_id}/stats`

**Headers:**
```
Authorization: Bearer {accessToken}
```

**Success Response (200):**
```json
{
  "vocabulary_id": 1,
  "total_words": 150,
  "learned_words": 45,
  "in_progress": 30,
  "not_started": 75,
  "progress_percentage": 30,
  "last_studied_at": "2025-10-01T12:00:00.000Z",
  "study_streak_days": 7,
  "total_study_time_minutes": 320
}
```

---

### 4.2 전체 학습 통계 (대시보드)

**Endpoint:** `GET /api/users/me/stats`

**Headers:**
```
Authorization: Bearer {accessToken}
```

**Success Response (200):**
```json
{
  "total_vocabularies": 5,
  "total_words": 750,
  "learned_words": 230,
  "overall_progress": 30.6,
  "current_streak": 7,
  "longest_streak": 15,
  "total_study_days": 45,
  "favorite_category": "exam_prep",
  "recent_activity": [
    {
      "date": "2025-10-01",
      "words_learned": 12,
      "study_time_minutes": 45
    }
  ]
}
```

---

## Database Schema (참고)

### vocabularies 테이블
```sql
CREATE TABLE vocabularies (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  title VARCHAR(100) NOT NULL,
  description TEXT,
  is_public BOOLEAN DEFAULT false,
  category VARCHAR(50),
  target_level VARCHAR(20),
  language VARCHAR(5) DEFAULT 'en',
  word_count INTEGER DEFAULT 0,
  download_count INTEGER DEFAULT 0,
  original_id INTEGER REFERENCES vocabularies(id),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### vocabulary_words 테이블
```sql
CREATE TABLE vocabulary_words (
  id SERIAL PRIMARY KEY,
  vocabulary_id INTEGER REFERENCES vocabularies(id) ON DELETE CASCADE,
  word VARCHAR(50) NOT NULL,
  meaning TEXT,
  part_of_speech VARCHAR(20),
  difficulty VARCHAR(20),
  notes TEXT,
  learned BOOLEAN DEFAULT false,
  learned_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(vocabulary_id, word)
);
```

### word_sentence_bookmarks 테이블
```sql
CREATE TABLE word_sentence_bookmarks (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  word_id INTEGER REFERENCES vocabulary_words(id) ON DELETE CASCADE,
  sentence_id INTEGER REFERENCES example_sentences(id) ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id, word_id, sentence_id)
);
```

### study_sessions 테이블
```sql
CREATE TABLE study_sessions (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  vocabulary_id INTEGER REFERENCES vocabularies(id) ON DELETE CASCADE,
  words_studied INTEGER DEFAULT 0,
  duration_minutes INTEGER DEFAULT 0,
  session_date DATE DEFAULT CURRENT_DATE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## Error Codes Summary

- **200**: Success
- **201**: Created
- **400**: Bad Request (validation error)
- **401**: Unauthorized (no token or expired)
- **403**: Forbidden (not authorized to access resource)
- **404**: Not Found
- **409**: Conflict (duplicate entry)
- **500**: Internal Server Error

---

## Notes

1. **인증**: 모든 단어장/단어 관련 API는 JWT 토큰 인증 필요
2. **페이지네이션**: 기본 20개씩, 최대 100개
3. **캐싱**: 예문은 DB 캐시 우선, 없으면 AI 생성
4. **공개/비공개**: 단어장은 공개 설정 가능, 다른 사용자가 다운로드 가능
5. **학습 추적**: 단어별 학습 완료 여부 및 전체 진행도 추적
