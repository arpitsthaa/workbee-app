import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSessionService extends ChangeNotifier {
  static final UserSessionService _instance = UserSessionService._internal();
  factory UserSessionService() => _instance;
  UserSessionService._internal();

  static const String _userNameKey = 'user_name';
  static const String _userIdKey = 'user_id';
  static const String _userRoleKey = 'user_role';

  String? _userName;
  String? _userId;
  String? _userRole;
  bool _initialized = false;

  String? get userName => _userName;
  String? get userId => _userId;
  String? get userRole => _userRole;
  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString(_userNameKey);
    _userId = prefs.getString(_userIdKey);
    _userRole = prefs.getString(_userRoleKey);
    _initialized = true;
    notifyListeners();
  }

  Future<void> setUser({
    required String name,
    required String id,
    required String role,
  }) async {
    _userName = name;
    _userId = id;
    _userRole = role;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
    await prefs.setString(_userIdKey, id);
    await prefs.setString(_userRoleKey, role);
    notifyListeners();
  }

  Future<void> updateName(String newName) async {
    _userName = newName;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, newName);
    notifyListeners();
  }

  Future<void> clear() async {
    _userName = null;
    _userId = null;
    _userRole = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userNameKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userRoleKey);
    notifyListeners();
  }
}