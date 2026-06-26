/// Represents an authenticated user in the system.
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final String role; // 'student' | 'admin'
  final DateTime createdAt;
  final String? fcmToken;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.role = 'student',
    required this.createdAt,
    this.fcmToken,
  });

  bool get isAdmin => role == 'admin';

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid:       map['uid'] as String? ?? '',
      name:      map['name'] as String? ?? 'Utilisateur',
      email:     map['email'] as String? ?? '',
      photoUrl:  map['photoUrl'] as String?,
      role:      map['role'] as String? ?? 'student',
      createdAt: _parseDate(map['createdAt']),
      fcmToken:  map['fcmToken'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid':       uid,
      'name':      name,
      'email':     email,
      'photoUrl':  photoUrl,
      'role':      role,
      'createdAt': createdAt,
      'fcmToken':  fcmToken,
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? photoUrl,
    String? role,
    DateTime? createdAt,
    String? fcmToken,
  }) {
    return UserModel(
      uid:       uid ?? this.uid,
      name:      name ?? this.name,
      email:     email ?? this.email,
      photoUrl:  photoUrl ?? this.photoUrl,
      role:      role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      fcmToken:  fcmToken ?? this.fcmToken,
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    // Firestore Timestamp support
    try {
      return (value as dynamic).toDate() as DateTime;
    } catch (_) {
      return DateTime.now();
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is UserModel && other.uid == uid);

  @override
  int get hashCode => uid.hashCode;

  @override
  String toString() => 'UserModel(uid: $uid, name: $name, role: $role)';
}
