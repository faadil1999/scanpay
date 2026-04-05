import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String phoneNumber;
  final double balance;
  final List<String> roles; // ['client', 'merchant']
  final DateTime createdAt;
  final String? avatarUrl;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.phoneNumber,
    required this.balance,
    required this.roles,
    required this.createdAt,
    this.avatarUrl,
  });

  bool get isMerchant => roles.contains('merchant');
  bool get isClient => roles.contains('client');

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      balance: (map['balance'] ?? 0).toDouble(),
      roles: List<String>.from(map['roles'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      avatarUrl: map['avatarUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'balance': balance,
      'roles': roles,
      'createdAt': Timestamp.fromDate(createdAt),
      'avatarUrl': avatarUrl,
    };
  }

  UserModel copyWith({
    String? name,
    String? phoneNumber,
    double? balance,
    List<String>? roles,
    String? avatarUrl,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      balance: balance ?? this.balance,
      roles: roles ?? this.roles,
      createdAt: createdAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
