enum UserRole { merchant, client, admin }
enum UserStatus { active, inactive, suspended }

class UserModel {
  final String id;
  final String phone;
  final String firstName;
  final String lastName;
  final String? email;
  final UserRole role;
  final UserStatus status;
  final bool isPhoneVerified;
  final String? avatarUrl;
  final String? fcmToken;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get fullName => '$firstName $lastName';
  bool get isMerchant => role == UserRole.merchant;

  const UserModel({
    required this.id,
    required this.phone,
    required this.firstName,
    required this.lastName,
    this.email,
    required this.role,
    required this.status,
    required this.isPhoneVerified,
    this.avatarUrl,
    this.fcmToken,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      phone: json['phone'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.client,
      ),
      status: UserStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => UserStatus.active,
      ),
      isPhoneVerified: json['isPhoneVerified'] ?? false,
      avatarUrl: json['avatarUrl'],
      fcmToken: json['fcmToken'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'phone': phone,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'role': role.name,
    'status': status.name,
    'isPhoneVerified': isPhoneVerified,
    'avatarUrl': avatarUrl,
    'fcmToken': fcmToken,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}
