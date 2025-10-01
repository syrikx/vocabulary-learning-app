class UserModel {
  final String id;
  final String name;
  final String email;
  final String? profileImageUrl;
  final LoginProvider loginProvider;
  final bool? isEmailVerified;
  final bool? isActive;
  final String? createdAt;
  final String? lastLoginAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
    required this.loginProvider,
    this.isEmailVerified,
    this.isActive,
    this.createdAt,
    this.lastLoginAt,
  });

  // 로컬 저장용 JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      name: json['name'] ?? json['username'] ?? '',
      email: json['email'],
      profileImageUrl: json['profileImageUrl'],
      loginProvider: LoginProvider.values.firstWhere(
        (provider) => provider.name == json['loginProvider'],
        orElse: () => LoginProvider.email,
      ),
      isEmailVerified: json['isEmailVerified'],
      isActive: json['isActive'],
      createdAt: json['createdAt'],
      lastLoginAt: json['lastLoginAt'],
    );
  }

  // API 로그인 응답용 팩토리 메서드
  factory UserModel.fromApiLoginResponse(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      name: json['username'] ?? '',
      email: json['email'],
      profileImageUrl: null,
      loginProvider: LoginProvider.email,
      isEmailVerified: json['is_email_verified'],
      isActive: json['is_active'],
      createdAt: json['created_at'],
      lastLoginAt: json['last_login_at'],
    );
  }

  // API 회원가입 응답용 팩토리 메서드
  factory UserModel.fromApiRegisterResponse(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      name: json['username'] ?? '',
      email: json['email'],
      profileImageUrl: null,
      loginProvider: LoginProvider.email,
      isEmailVerified: json['is_email_verified'],
      isActive: json['is_active'],
      createdAt: json['created_at'],
      lastLoginAt: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'loginProvider': loginProvider.name,
      'isEmailVerified': isEmailVerified,
      'isActive': isActive,
      'createdAt': createdAt,
      'lastLoginAt': lastLoginAt,
    };
  }
}

enum LoginProvider { google, naver, email }