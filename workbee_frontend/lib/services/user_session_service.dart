import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSessionService extends ChangeNotifier {
  static final UserSessionService _instance = UserSessionService._internal();
  factory UserSessionService() => _instance;
  UserSessionService._internal();

  static const String _userNameKey = 'user_name';
  static const String _userIdKey = 'user_id';
  static const String _userRoleKey = 'user_role';
  static const String _locationKey = 'user_location';
  static const String _collegeUniversityKey = 'user_college_university';
  static const String _programKey = 'user_program';
  static const String _semesterKey = 'user_semester';
  static const String _bioKey = 'user_bio';
  static const String _skillsKey = 'user_skills';
  static const String _portfolioUrlKey = 'user_portfolio_url';
  static const String _appliedGigIdsKey = 'applied_gig_ids';

  String? _userName;
  String? _userId;
  String? _userRole;
  String? _location;
  String? _collegeUniversity;
  String? _program;
  String? _semester;
  String? _bio;
  List<String> _skills = [];
  String? _portfolioUrl;
  Set<int> _appliedGigIds = {};
  bool _initialized = false;
  static SharedPreferences? _prefs;

  static Future<SharedPreferences> get _prefsInstance async {
    if (_prefs != null) return _prefs!;
    _prefs = await SharedPreferences.getInstance();
    return _prefs!;
  }

  String? get userName => _userName;
  String? get userId => _userId;
  String? get userRole => _userRole;
  String? get location => _location;
  String? get collegeUniversity => _collegeUniversity;
  String? get program => _program;
  String? get semester => _semester;
  String? get bio => _bio;
  List<String> get skills => _skills;
  String? get portfolioUrl => _portfolioUrl;
  Set<int> get appliedGigIds => _appliedGigIds;
  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) return;
    final prefs = await _prefsInstance;
    _userName = prefs.getString(_userNameKey);
    _userId = prefs.getString(_userIdKey);
    _userRole = prefs.getString(_userRoleKey);
    _location = prefs.getString(_locationKey);
    _collegeUniversity = prefs.getString(_collegeUniversityKey);
    _program = prefs.getString(_programKey);
    _semester = prefs.getString(_semesterKey);
    _bio = prefs.getString(_bioKey);
    final skillsJson = prefs.getString(_skillsKey);
    if (skillsJson != null && skillsJson.isNotEmpty) {
      try {
        _skills = List<String>.from(jsonDecode(skillsJson));
      } catch (_) {
        _skills = [];
      }
    }
    _portfolioUrl = prefs.getString(_portfolioUrlKey);
    final appliedIdsJson = prefs.getString(_appliedGigIdsKey);
    if (appliedIdsJson != null && appliedIdsJson.isNotEmpty) {
      try {
        final list = List<int>.from(jsonDecode(appliedIdsJson));
        _appliedGigIds = list.toSet();
      } catch (_) {
        _appliedGigIds = {};
      }
    }
    _initialized = true;
    notifyListeners();
  }

  bool isApplied(int gigId) {
    return _appliedGigIds.contains(gigId);
  }

  Future<void> markApplied(int gigId) async {
    _appliedGigIds.add(gigId);
    final prefs = await _prefsInstance;
    await prefs.setString(_appliedGigIdsKey, jsonEncode(_appliedGigIds.toList()));
    notifyListeners();
  }

  Future<void> markWithdrawn(int gigId) async {
    _appliedGigIds.remove(gigId);
    final prefs = await _prefsInstance;
    await prefs.setString(_appliedGigIdsKey, jsonEncode(_appliedGigIds.toList()));
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
    final prefs = await _prefsInstance;
    await prefs.setString(_userNameKey, name);
    await prefs.setString(_userIdKey, id);
    await prefs.setString(_userRoleKey, role);
    notifyListeners();
  }

  Future<void> setFullProfile({
    required String name,
    required String id,
    required String role,
    String? location,
    String? collegeUniversity,
    String? program,
    String? semester,
    String? bio,
    List<String>? skills,
    String? portfolioUrl,
  }) async {
    _userName = name;
    _userId = id;
    _userRole = role;
    _location = location;
    _collegeUniversity = collegeUniversity;
    _program = program;
    _semester = semester;
    _bio = bio;
    _skills = skills ?? [];
    _portfolioUrl = portfolioUrl;

    final prefs = await _prefsInstance;
    await prefs.setString(_userNameKey, name);
    await prefs.setString(_userIdKey, id);
    await prefs.setString(_userRoleKey, role);
    if (location != null) await prefs.setString(_locationKey, location);
    if (collegeUniversity != null) await prefs.setString(_collegeUniversityKey, collegeUniversity);
    if (program != null) await prefs.setString(_programKey, program);
    if (semester != null) await prefs.setString(_semesterKey, semester);
    if (bio != null) await prefs.setString(_bioKey, bio);
    if (skills != null) await prefs.setString(_skillsKey, jsonEncode(skills));
    if (portfolioUrl != null) await prefs.setString(_portfolioUrlKey, portfolioUrl);
    notifyListeners();
  }

  Future<void> updateName(String newName) async {
    _userName = newName;
    final prefs = await _prefsInstance;
    await prefs.setString(_userNameKey, newName);
    notifyListeners();
  }

  Future<void> updateProfile({
    String? name,
    String? location,
    String? collegeUniversity,
    String? program,
    String? semester,
    String? bio,
    List<String>? skills,
    String? portfolioUrl,
  }) async {
    if (name != null) _userName = name;
    if (location != null) _location = location;
    if (collegeUniversity != null) _collegeUniversity = collegeUniversity;
    if (program != null) _program = program;
    if (semester != null) _semester = semester;
    if (bio != null) _bio = bio;
    if (skills != null) _skills = skills;
    if (portfolioUrl != null) _portfolioUrl = portfolioUrl;

    final prefs = await _prefsInstance;
    if (name != null) await prefs.setString(_userNameKey, name);
    if (location != null) await prefs.setString(_locationKey, location);
    if (collegeUniversity != null) await prefs.setString(_collegeUniversityKey, collegeUniversity);
    if (program != null) await prefs.setString(_programKey, program);
    if (semester != null) await prefs.setString(_semesterKey, semester);
    if (bio != null) await prefs.setString(_bioKey, bio);
    if (skills != null) await prefs.setString(_skillsKey, jsonEncode(skills));
    if (portfolioUrl != null) await prefs.setString(_portfolioUrlKey, portfolioUrl);
    notifyListeners();
  }

  Future<void> clear() async {
    _userName = null;
    _userId = null;
    _userRole = null;
    _location = null;
    _collegeUniversity = null;
    _program = null;
    _semester = null;
    _bio = null;
    _skills = [];
    _portfolioUrl = null;
    _appliedGigIds = {};
    final prefs = await _prefsInstance;
    await prefs.remove(_userNameKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userRoleKey);
    await prefs.remove(_locationKey);
    await prefs.remove(_collegeUniversityKey);
    await prefs.remove(_programKey);
    await prefs.remove(_semesterKey);
    await prefs.remove(_bioKey);
    await prefs.remove(_skillsKey);
    await prefs.remove(_portfolioUrlKey);
    await prefs.remove(_appliedGigIdsKey);
    _prefs = null;
    notifyListeners();
  }
}