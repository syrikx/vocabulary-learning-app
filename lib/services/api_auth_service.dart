import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';

class ApiAuthService {
  static const String baseUrl = 'http://eng.gunsiya.com';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  UserModel? _currentUser;

  // 토큰 저장 키
  static const String _accessTokenKey = 'accessToken';
  static const String _refreshTokenKey = 'refreshToken';
  static const String _userDataKey = 'userData';

  ApiAuthService() {
    _loadUserFromStorage();
  }

  // 저장된 사용자 정보 로드
  Future<void> _loadUserFromStorage() async {
    try {
      final userData = await _storage.read(key: _userDataKey);
      if (userData != null) {
        _currentUser = UserModel.fromJson(jsonDecode(userData));
      }
    } catch (e) {
      print('저장된 사용자 정보 로드 실패: $e');
    }
  }

  // 토큰 저장
  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  // 사용자 정보 저장
  Future<void> _saveUserData(UserModel user) async {
    await _storage.write(key: _userDataKey, value: jsonEncode(user.toJson()));
    _currentUser = user;
  }

  // 토큰 및 사용자 정보 삭제
  Future<void> _clearStorage() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userDataKey);
    _currentUser = null;
  }

  // Access Token 가져오기
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  // Refresh Token 가져오기
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  // 회원가입
  Future<UserModel?> signUpWithEmail(String email, String password, String username) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final user = UserModel.fromApiRegisterResponse(data['user']);

        // 회원가입 후 자동 로그인은 하지 않음 (API에서 토큰을 제공하지 않음)
        return user;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? '회원가입에 실패했습니다.');
      }
    } catch (e) {
      print('회원가입 오류: $e');
      rethrow;
    }
  }

  // 로그인
  Future<UserModel?> signInWithEmail(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // 토큰 저장
        await _saveTokens(data['accessToken'], data['refreshToken']);

        // 사용자 정보 생성 및 저장
        final user = UserModel.fromApiLoginResponse(data['user']);
        await _saveUserData(user);

        return user;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? '로그인에 실패했습니다.');
      }
    } catch (e) {
      print('로그인 오류: $e');
      rethrow;
    }
  }

  // 토큰 갱신
  Future<bool> refreshAccessToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) {
        return false;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'refreshToken': refreshToken,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveTokens(data['accessToken'], data['refreshToken']);
        return true;
      } else {
        // 리프레시 토큰도 만료된 경우
        await _clearStorage();
        return false;
      }
    } catch (e) {
      print('토큰 갱신 오류: $e');
      return false;
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    try {
      final refreshToken = await getRefreshToken();

      if (refreshToken != null) {
        await http.post(
          Uri.parse('$baseUrl/api/auth/logout'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'refreshToken': refreshToken,
          }),
        );
      }
    } catch (e) {
      print('로그아웃 API 호출 오류: $e');
    } finally {
      // API 호출 성공 여부와 관계없이 로컬 데이터 삭제
      await _clearStorage();
    }
  }

  // 모든 세션 로그아웃
  Future<void> signOutAll(int userId) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/api/auth/logout-all'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
        }),
      );
    } catch (e) {
      print('모든 세션 로그아웃 오류: $e');
    } finally {
      await _clearStorage();
    }
  }

  // 현재 사용자 가져오기
  UserModel? getCurrentUser() {
    return _currentUser;
  }

  // 인증된 API 요청 (예시)
  Future<http.Response> authenticatedRequest(
    String endpoint, {
    String method = 'GET',
    Map<String, dynamic>? body,
  }) async {
    String? accessToken = await getAccessToken();

    if (accessToken == null) {
      throw Exception('인증 토큰이 없습니다. 로그인이 필요합니다.');
    }

    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };

    http.Response response;

    switch (method.toUpperCase()) {
      case 'POST':
        response = await http.post(uri, headers: headers, body: body != null ? jsonEncode(body) : null);
        break;
      case 'PUT':
        response = await http.put(uri, headers: headers, body: body != null ? jsonEncode(body) : null);
        break;
      case 'DELETE':
        response = await http.delete(uri, headers: headers);
        break;
      default:
        response = await http.get(uri, headers: headers);
    }

    // 401 에러 시 토큰 갱신 시도
    if (response.statusCode == 401) {
      final refreshed = await refreshAccessToken();

      if (refreshed) {
        // 토큰 갱신 성공 시 재시도
        accessToken = await getAccessToken();
        headers['Authorization'] = 'Bearer $accessToken';

        switch (method.toUpperCase()) {
          case 'POST':
            response = await http.post(uri, headers: headers, body: body != null ? jsonEncode(body) : null);
            break;
          case 'PUT':
            response = await http.put(uri, headers: headers, body: body != null ? jsonEncode(body) : null);
            break;
          case 'DELETE':
            response = await http.delete(uri, headers: headers);
            break;
          default:
            response = await http.get(uri, headers: headers);
        }
      } else {
        throw Exception('인증이 만료되었습니다. 다시 로그인해주세요.');
      }
    }

    return response;
  }
}
