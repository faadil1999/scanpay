import 'package:flutter/material.dart';

class UserProfile {
  final String id;
  final String name;
  final String phoneNumber;
  final double balance;
  final String avatarUrl;

  UserProfile({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.balance,
    required this.avatarUrl,
  });
}

class AuthProvider with ChangeNotifier {
  UserProfile? _user;
  bool _isMerchant = false;

  UserProfile? get user => _user;
  bool get isMerchant => _isMerchant;

  AuthProvider() {
    // Simulation de chargement initial
    _user = UserProfile(
      id: 'user_123',
      name: 'Jean Dupont',
      phoneNumber: '+229 90 00 00 01',
      balance: 25450,
      avatarUrl: 'https://picsum.photos/seed/user/200',
    );
  }

  void toggleMode() {
    _isMerchant = !_isMerchant;
    notifyListeners();
  }
}
