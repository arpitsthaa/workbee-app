import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;
  DioClient._internal();

  static const String _baseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: 'https://workbee-app.onrender.com');

  Dio? _dioInstance;
  bool _initialized = false;

  Dio get dio {
    if (!_initialized) init();
    return _dioInstance!;
  }

  void init() {
    if (_initialized) return;
    _initialized = true;
    _dioInstance = Dio(BaseOptions(baseUrl: _baseUrl));
    _dioInstance!.interceptors.add(_AuthInterceptor());
  }

  Future<void> warmUp() async {
    try {
      await dio.get('/api/health/').timeout(const Duration(seconds: 10));
    } catch (_) {}
  }
}

class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Token $token';
    }
    handler.next(options);
  }
}
