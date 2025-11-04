class User {
  final String id;
  final String username;
  final String password;
  final String personalCode;
  final DateTime createdAt;

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.personalCode,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password, // In production, this should be hashed
      'personalCode': personalCode,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      personalCode: json['personalCode'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  User copyWith({
    String? id,
    String? username,
    String? password,
    String? personalCode,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      personalCode: personalCode ?? this.personalCode,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'User(id: $id, username: $username, createdAt: $createdAt)';
  }
}

class UserSession {
  final User user;
  final DateTime loginTime;

  UserSession({required this.user, required this.loginTime});

  Map<String, dynamic> toJson() {
    return {'user': user.toJson(), 'loginTime': loginTime.toIso8601String()};
  }

  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      user: User.fromJson(json['user']),
      loginTime: DateTime.tryParse(json['loginTime'] ?? '') ?? DateTime.now(),
    );
  }
}
