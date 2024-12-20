class PlatformCredential {
  String platform;
  String email;
  String password;

  PlatformCredential({
    required this.platform,
    required this.email,
    required this.password,
  });

  factory PlatformCredential.fromMap(Map<String, dynamic> map) {
    return PlatformCredential(
      platform: map['platform'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'platform': platform,
      'email': email,
      'password': password,
    };
  }
} 