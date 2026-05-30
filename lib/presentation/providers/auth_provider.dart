import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';
import '../../data/services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final userProvider = StateProvider<UserModel?>((ref) => null);

final isMerchantViewProvider = StateProvider<bool>((ref) => false);

final authControllerProvider = Provider((ref) => AuthController(ref));

class AuthController {
  final Ref _ref;
  AuthController(this._ref);

  ApiService get _api => _ref.read(apiServiceProvider);

  Future<void> register({
    required String phone,
    required String firstName,
    required String lastName,
    required String password,
    String? email,
    required String role,
  }) async {
    final json = await _api.post('/auth/register', {
      'phone': phone,
      'firstName': firstName,
      'lastName': lastName,
      'password': password,
      if (email != null && email.isNotEmpty) 'email': email,
      'role': role,
    });
    await _api.saveToken(json['accessToken']);
    _ref.read(userProvider.notifier).state = UserModel.fromJson(json['user']);
  }

  Future<void> login(String phone, String password) async {
    final json = await _api.post('/auth/login', {
      'phone': phone,
      'password': password,
    });
    await _api.saveToken(json['accessToken']);
    _ref.read(userProvider.notifier).state = UserModel.fromJson(json['user']);
  }

  Future<void> fetchUserData() async {
    final json = await _api.get('/auth/me');
    _ref.read(userProvider.notifier).state = UserModel.fromJson(json);
  }

  Future<bool> tryAutoLogin() async {
    final token = await _api.getToken();
    if (token == null) return false;
    try {
      await fetchUserData();
      return true;
    } catch (_) {
      await _api.clearToken();
      return false;
    }
  }

  Future<void> signOut() async {
    await _api.clearToken();
    _ref.read(userProvider.notifier).state = null;
  }
}
