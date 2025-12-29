import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'session_manager.dart';

final GlobalKey<NavigatorState> authNavigatorKey = GlobalKey<NavigatorState>();

abstract class AuthClient {
  Future<String> login({required String email, required String password});
  Future<String> register({
    required String name,
    required String email,
    required String password,
  });
  Future<Map<String, dynamic>> fetchCurrentUser();
  Future<void> logout();
}

class AuthException implements Exception {
  AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

class AuthService implements AuthClient {
  AuthService._internal() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _sessionManager.getToken();
          options.headers['Accept'] = 'application/json';
          options.headers['Content-Type'] = 'application/json';

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await _sessionManager.clearToken();
            authNavigatorKey.currentState
                ?.pushNamedAndRemoveUntil('/login', (route) => false);
          }
          handler.next(error);
        },
      ),
    );
  }

  static final AuthService instance = AuthService._internal();
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://landlordbd-1.onrender.com/api',
  );

  final SessionManager _sessionManager = SessionManager.instance;

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  @override
  Future<String> login({required String email, required String password}) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );

      final token = _extractToken(response.data);
      if (token == null || token.isEmpty) {
        throw AuthException('Login succeeded but token not found in response.');
      }

      await _sessionManager.saveToken(token);
      return token;
    } on DioException catch (e) {
      throw AuthException(_formatError(e));
    }
  }

  @override
  Future<String> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
        },
      );

      final token = _extractToken(response.data);
      if (token == null || token.isEmpty) {
        throw AuthException(
            'Registration succeeded but token not found in response.');
      }

      await _sessionManager.saveToken(token);
      return token;
    } on DioException catch (e) {
      throw AuthException(_formatError(e));
    }
  }

  @override
  Future<Map<String, dynamic>> fetchCurrentUser() async {
    try {
      final response = await _dio.get('/me');
      final data = response.data;

      if (data is Map<String, dynamic>) return data;
      throw AuthException('Unexpected /me response format.');
    } on DioException catch (e) {
      throw AuthException(_formatError(e));
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dio.post('/logout');
    } on DioException {
      // ignore
    } finally {
      await _sessionManager.clearToken();
    }
  }

  String _formatError(DioException exception) {
    final response = exception.response;
    final data = response?.data;

    if (data is Map<String, dynamic>) {
      if (data['message'] is String) return data['message'] as String;

      if (data['errors'] is Map<String, dynamic>) {
        final errors = data['errors'] as Map<String, dynamic>;
        if (errors.isNotEmpty) {
          final first = errors.values.first;
          if (first is List && first.isNotEmpty) return first.first.toString();
          return first.toString();
        }
      }
    }

    final code = response?.statusCode;
    if (code != null) return 'Request failed ($code). Please try again.';
    return 'Authentication failed. Please try again.';
  }

  String? _extractToken(dynamic data) {
    if (data is String) return data.isNotEmpty ? data : null;

    if (data is Map<String, dynamic>) {
      final token = data['token'] ??
          data['access_token'] ??
          data['plainTextToken'] ??
          data['plain_text_token'];

      if (token != null && token.toString().isNotEmpty) return token.toString();

      final nested = data['data'];
      if (nested is Map<String, dynamic>) {
        final nestedToken = nested['token'] ??
            nested['access_token'] ??
            nested['plainTextToken'] ??
            nested['plain_text_token'];
        if (nestedToken != null && nestedToken.toString().isNotEmpty) {
          return nestedToken.toString();
        }
      }
    }
    return null;
  }
}
