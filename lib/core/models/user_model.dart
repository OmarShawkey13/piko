import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String username;
  final String photoUrl;
  final String bio;
  final bool online;
  final DateTime? lastActive;
  final DateTime? createdAt;
  final DateTime? lastSeen;

  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.username,
    required this.photoUrl,
    required this.bio,
    this.online = false,
    this.lastActive,
    this.createdAt,
    this.lastSeen,
  });

  /// ------------ Firestore → Model ------------
  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      username: map['username'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      bio: map['bio'] ?? '',
      online: map['online'] ?? false,
      lastActive: parseDate(map['lastActive']),
      createdAt: parseDate(map["createdAt"]),
      lastSeen: parseDate(map["lastSeen"]),
    );
  }

  /// ------------ Model → Firestore / JSON ------------
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'username': username,
      'photoUrl': photoUrl,
      'bio': bio,
      'online': online,
      'lastActive': lastActive?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'lastSeen': lastSeen?.toIso8601String(),
    };
  }

  /// ------------ CopyWith ------------
  UserModel copyWith({
    String? email,
    String? displayName,
    String? username,
    String? photoUrl,
    String? bio,
    bool? online,
    DateTime? lastActive,
    DateTime? createdAt,
    DateTime? lastSeen,
  }) {
    return UserModel(
      uid: uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      online: online ?? this.online,
      lastActive: lastActive ?? this.lastActive,
      createdAt: createdAt ?? this.createdAt,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}
