import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/api_error_model.dart';

class ApiService {
  static const String _baseUrl = 'http://localhost:3000/api/v1';
  static const String _tokenKey = 'access_token';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> getToken() => _storage.read(key: _tokenKey);
  Future<void> saveToken(String token) => _storage.write(key: _tokenKey, value: token);
  Future<void> clearToken() => _storage.delete(key: _tokenKey);

  Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String path) async {
    final headers = await _authHeaders();
    try {
      final response = await http.get(Uri.parse('$_baseUrl$path'), headers: headers);
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(ApiError(statusCode: 0, message: 'Erreur réseau : ${e.toString()}'));
    }
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final headers = await _authHeaders();
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$path'),
        headers: headers,
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(ApiError(statusCode: 0, message: 'Erreur réseau : ${e.toString()}'));
    }
  }

  Future<dynamic> patch(String path, Map<String, dynamic> body) async {
    final headers = await _authHeaders();
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl$path'),
        headers: headers,
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(ApiError(statusCode: 0, message: 'Erreur réseau : ${e.toString()}'));
    }
  }

  Future<dynamic> delete(String path) async {
    final headers = await _authHeaders();
    try {
      final response = await http.delete(Uri.parse('$_baseUrl$path'), headers: headers);
      if (response.statusCode == 204) return null;
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(ApiError(statusCode: 0, message: 'Erreur réseau : ${e.toString()}'));
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(utf8.decode(response.bodyBytes));
    }
    final json = jsonDecode(utf8.decode(response.bodyBytes));
    throw ApiException(ApiError.fromJson(json));
  }
}

class ApiException implements Exception {
  final ApiError error;
  ApiException(this.error);

  @override
  String toString() => error.displayMessage;
}
