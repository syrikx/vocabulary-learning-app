# English Learning Service - API Documentation

## Base URL
```
http://localhost:6000
```

---

## 1. Authentication APIs

### 1.1 회원가입
사용자 계정을 생성합니다.

**Endpoint:** `POST /api/auth/register`

**Request Body:**
```json
{
  "email": "user@example.com",
  "username": "myusername",
  "password": "SecurePass123!"
}
```

**Validation Rules:**
- **email**: 유효한 이메일 형식 필수
- **username**: 3-50자, 영문/숫자/언더스코어(_)만 허용
- **password**: 최소 8자, 대문자 1개 이상, 소문자 1개 이상, 숫자 1개 이상

**Success Response (201):**
```json
{
  "message": "User registered successfully",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "username": "myusername",
    "is_email_verified": false,
    "is_active": true,
    "created_at": "2025-10-01T12:00:00.000Z"
  }
}
```

**Error Responses:**
- **400**: Validation error (잘못된 입력 형식)
- **409**: Email or username already exists (이메일/유저네임 중복)

---

### 1.2 로그인
이메일과 비밀번호로 로그인하여 JWT 토큰을 발급받습니다.

**Endpoint:** `POST /api/auth/login`

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "SecurePass123!"
}
```

**Success Response (200):**
```json
{
  "message": "Login successful",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "username": "myusername",
    "is_email_verified": false,
    "is_active": true,
    "last_login_at": "2025-10-01T12:00:00.000Z"
  },
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6..."
}
```

**토큰 사용 방법:**
- `accessToken`: API 요청 시 Authorization 헤더에 포함 (유효기간: 15분)
- `refreshToken`: accessToken 갱신 시 사용 (유효기간: 7일)

**Error Responses:**
- **400**: Missing required fields (필수 필드 누락)
- **401**: Invalid credentials (이메일 또는 비밀번호 오류)
- **403**: Account is deactivated (계정 비활성화)

---

### 1.3 토큰 갱신
만료된 accessToken을 refreshToken으로 갱신합니다.

**Endpoint:** `POST /api/auth/refresh`

**Request Body:**
```json
{
  "refreshToken": "a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6..."
}
```

**Success Response (200):**
```json
{
  "message": "Token refreshed successfully",
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7..."
}
```

**Note:** 기존 refreshToken은 무효화되고 새로운 토큰이 발급됩니다.

**Error Responses:**
- **400**: Missing refresh token
- **401**: Invalid or expired refresh token

---

### 1.4 로그아웃
현재 세션을 종료하고 refreshToken을 무효화합니다.

**Endpoint:** `POST /api/auth/logout`

**Request Body:**
```json
{
  "refreshToken": "a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6..."
}
```

**Success Response (200):**
```json
{
  "message": "Logout successful"
}
```

---

### 1.5 모든 세션 로그아웃
사용자의 모든 디바이스/세션을 로그아웃합니다.

**Endpoint:** `POST /api/auth/logout-all`

**Request Body:**
```json
{
  "userId": 1
}
```

**Success Response (200):**
```json
{
  "message": "All sessions logged out successfully"
}
```

---

## 2. Example Sentence APIs

### 2.1 예문 가져오기 (GET)
단어에 대한 예문을 가져옵니다. Base64로 인코딩된 사용자 예문을 전달하여 중복을 피합니다.

**Endpoint:** `GET /api/example_sentence`

**Query Parameters:**
- `word` (required): 검색할 영어 단어
- `years` (required): 학습자 나이 (5-18)
- `user_sentences` (optional): Base64 인코딩된 JSON 배열
- `count` (optional): 요청할 예문 개수 (기본값: 3, 최대: 10)

**Example Request:**
```javascript
// 사용자 예문
const userSentences = ["The flowers bloom in spring.", "Her career began to bloom."];

// Base64 인코딩
const encoded = btoa(JSON.stringify(userSentences));

// API 호출
fetch(`http://localhost:6000/api/example_sentence?word=bloom&years=9&user_sentences=${encoded}&count=3`)
  .then(res => res.json())
  .then(data => console.log(data));
```

**Success Response (200):**
```json
{
  "word": "bloom",
  "years": 9,
  "source": "database",
  "sentences": [
    {
      "id": 5,
      "text": "The sunflower will bloom very tall."
    },
    {
      "id": 4,
      "text": "My favorite time of year is when the tulips bloom."
    },
    {
      "id": 3,
      "text": "I love to see the cherry blossoms bloom."
    }
  ],
  "total_available": 5,
  "timestamp": "2025-10-01T12:00:00.000Z",
  "ai_calls_saved": 1
}
```

**Response Fields:**
- `source`: "database" (캐시에서 조회), "ai" (AI 생성), "mixed" (혼합)
- `sentences`: 예문 배열
- `total_available`: DB에 저장된 총 예문 수
- `ai_calls_saved`: 절약된 AI 호출 횟수

---

### 2.2 예문 가져오기 (POST)
더 많은 사용자 예문 데이터를 전송할 수 있는 POST 방식입니다.

**Endpoint:** `POST /api/example_sentence`

**Request Body:**
```json
{
  "word": "bloom",
  "years": 9,
  "user_sentences": [
    "The flowers bloom in spring.",
    "Her career began to bloom."
  ],
  "count": 3
}
```

**Success Response (200):**
```json
{
  "word": "bloom",
  "years": 9,
  "source": "database",
  "sentences": [
    {
      "id": 5,
      "text": "The sunflower will bloom very tall."
    },
    {
      "id": 4,
      "text": "My favorite time of year is when the tulips bloom."
    },
    {
      "id": 3,
      "text": "I love to see the cherry blossoms bloom."
    }
  ],
  "total_available": 5,
  "timestamp": "2025-10-01T12:00:00.000Z",
  "ai_calls_saved": 1
}
```

**Error Responses:**
- **400**: Validation error (잘못된 파라미터)
  - `word`가 없거나 50자 초과
  - `years`가 5-18 범위 밖
  - `count`가 1-10 범위 밖

---

## 3. Health Check

### 3.1 서버 상태 확인
서버가 정상 동작 중인지 확인합니다.

**Endpoint:** `GET /health`

**Success Response (200):**
```json
{
  "status": "healthy",
  "timestamp": "2025-10-01T12:00:00.000Z",
  "database": "postgresql"
}
```

---

## 인증 사용 방법

### 보호된 API 호출 (예시)
로그인 후 받은 `accessToken`을 사용하여 인증이 필요한 API를 호출합니다.

```javascript
// 로그인
const loginResponse = await fetch('http://localhost:6000/api/auth/login', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    email: 'user@example.com',
    password: 'SecurePass123!'
  })
});

const { accessToken, refreshToken } = await loginResponse.json();

// 인증이 필요한 API 호출 (향후 구현 예정)
const protectedResponse = await fetch('http://localhost:6000/api/my-sentences', {
  headers: {
    'Authorization': `Bearer ${accessToken}`
  }
});
```

### 토큰 만료 시 갱신
```javascript
// accessToken 만료 시 (401 에러 발생)
if (response.status === 401) {
  // refreshToken으로 새 accessToken 발급
  const refreshResponse = await fetch('http://localhost:6000/api/auth/refresh', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      refreshToken: refreshToken
    })
  });

  const { accessToken: newAccessToken, refreshToken: newRefreshToken } = await refreshResponse.json();

  // 새 토큰으로 재시도
  // ...
}
```

---

## 에러 응답 형식

모든 에러는 다음 형식을 따릅니다:

```json
{
  "error": "Error Type",
  "message": "Detailed error message"
}
```

### HTTP Status Codes
- **200**: Success
- **201**: Created (회원가입 성공)
- **400**: Bad Request (잘못된 요청)
- **401**: Unauthorized (인증 실패)
- **403**: Forbidden (권한 없음)
- **409**: Conflict (중복 데이터)
- **500**: Internal Server Error (서버 오류)

---

## CORS 설정

개발 환경에서 프론트엔드 서버와 통신하려면 CORS 설정이 필요할 수 있습니다.

**서버 측 설정 예시:**
```javascript
// server.js에 추가
const cors = require('cors');
app.use(cors({
  origin: 'http://localhost:3000', // 프론트엔드 서버 주소
  credentials: true
}));
```

---

## 프론트엔드 예제 코드

### React 예시

#### 1. 회원가입
```jsx
const handleRegister = async (e) => {
  e.preventDefault();

  try {
    const response = await fetch('http://localhost:6000/api/auth/register', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        email: email,
        username: username,
        password: password
      })
    });

    const data = await response.json();

    if (response.ok) {
      alert('회원가입 성공!');
      // 로그인 페이지로 이동
    } else {
      alert(data.error);
    }
  } catch (error) {
    console.error('Registration error:', error);
  }
};
```

#### 2. 로그인 및 토큰 저장
```jsx
const handleLogin = async (e) => {
  e.preventDefault();

  try {
    const response = await fetch('http://localhost:6000/api/auth/login', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        email: email,
        password: password
      })
    });

    const data = await response.json();

    if (response.ok) {
      // 토큰 저장 (localStorage 또는 secure cookie)
      localStorage.setItem('accessToken', data.accessToken);
      localStorage.setItem('refreshToken', data.refreshToken);
      localStorage.setItem('user', JSON.stringify(data.user));

      alert('로그인 성공!');
      // 메인 페이지로 이동
    } else {
      alert(data.error);
    }
  } catch (error) {
    console.error('Login error:', error);
  }
};
```

#### 3. 예문 가져오기
```jsx
const fetchSentences = async (word, years, userSentences = []) => {
  try {
    const response = await fetch('http://localhost:6000/api/example_sentence', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        word: word,
        years: years,
        user_sentences: userSentences,
        count: 3
      })
    });

    const data = await response.json();

    if (response.ok) {
      setSentences(data.sentences);
      setSource(data.source);
    } else {
      alert('예문을 가져오는데 실패했습니다.');
    }
  } catch (error) {
    console.error('Fetch sentences error:', error);
  }
};
```

#### 4. Axios를 사용한 인터셉터 (토큰 자동 갱신)
```jsx
import axios from 'axios';

const api = axios.create({
  baseURL: 'http://localhost:6000',
});

// 요청 인터셉터: 모든 요청에 accessToken 자동 추가
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('accessToken');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// 응답 인터셉터: 401 에러 시 자동 토큰 갱신
api.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config;

    if (error.response.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true;

      try {
        const refreshToken = localStorage.getItem('refreshToken');
        const response = await axios.post('http://localhost:6000/api/auth/refresh', {
          refreshToken
        });

        const { accessToken, refreshToken: newRefreshToken } = response.data;

        localStorage.setItem('accessToken', accessToken);
        localStorage.setItem('refreshToken', newRefreshToken);

        originalRequest.headers.Authorization = `Bearer ${accessToken}`;
        return api(originalRequest);
      } catch (refreshError) {
        // 리프레시 토큰도 만료됨 -> 로그아웃
        localStorage.clear();
        window.location.href = '/login';
        return Promise.reject(refreshError);
      }
    }

    return Promise.reject(error);
  }
);

export default api;
```

#### 5. 사용 예시
```jsx
import api from './api';

// 예문 가져오기
const sentences = await api.post('/api/example_sentence', {
  word: 'bloom',
  years: 9,
  user_sentences: ['The flowers bloom in spring.'],
  count: 3
});

// 로그아웃
const logout = async () => {
  const refreshToken = localStorage.getItem('refreshToken');
  await api.post('/api/auth/logout', { refreshToken });
  localStorage.clear();
  window.location.href = '/login';
};
```

---

## 테스트용 curl 명령어

```bash
# 1. 회원가입
curl -X POST http://localhost:6000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","username":"testuser","password":"Test1234!"}'

# 2. 로그인
curl -X POST http://localhost:6000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"Test1234!"}'

# 3. 예문 가져오기
curl -X POST http://localhost:6000/api/example_sentence \
  -H "Content-Type: application/json" \
  -d '{"word":"bloom","years":9,"user_sentences":["The flowers bloom."],"count":3}'

# 4. 헬스 체크
curl http://localhost:6000/health
```

---

## 주의사항

1. **보안**: 프로덕션 환경에서는 HTTPS 사용 필수
2. **토큰 저장**:
   - `accessToken`과 `refreshToken`을 안전하게 저장
   - XSS 공격 방지를 위해 httpOnly cookie 사용 권장
3. **토큰 만료**:
   - `accessToken`은 15분 후 만료
   - 만료 전 자동 갱신 로직 구현 권장
4. **에러 처리**:
   - 네트워크 오류, 토큰 만료 등 다양한 에러 케이스 처리
5. **CORS**:
   - 프론트엔드 도메인을 백엔드 CORS 설정에 추가

---

## 향후 추가될 API (예정)

- `GET /api/users/me` - 현재 사용자 정보 조회
- `PUT /api/users/me` - 사용자 정보 수정
- `GET /api/my-sentences` - 내가 학습한 예문 목록
- `POST /api/oauth/google` - 구글 OAuth 로그인
- `POST /api/oauth/naver` - 네이버 OAuth 로그인
- `POST /api/oauth/apple` - 애플 OAuth 로그인
