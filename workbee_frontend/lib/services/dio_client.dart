import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Singleton Dio client with automatic auth header injection.
class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;
  DioClient._internal();

  static const String _baseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: 'https://workbee-app.onrender.com');

  Dio? _dioInstance;
  bool _initialized = false;

  Dio get dio {
    if (!_initialized) {
      init();
    }
    return _dioInstance!;
  }

  void init() {
    if (_initialized) return;
    _initialized = true;

    _dioInstance = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
      ),
    );

    _dioInstance!.interceptors.add(_AuthInterceptor());
    if (!kReleaseMode) {
      _dioInstance!.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          responseHeader: false,
          error: true,
        ),
      );
    }
  }

  Future<void> warmUp() async {
    try {
      await dio.get('/api/health/').timeout(const Duration(seconds: 10));
    } catch (_) {
      // best-effort wake-up; ignore
    }
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