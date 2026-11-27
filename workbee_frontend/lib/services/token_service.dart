import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores and retrieves authentication tokens and user session data.
///
/// Handles saving/loading the JWT token, user role, and profile information
/// so the user stays logged in across app restarts.
class TokenService extends ChangeNotifier {
  static final TokenService _instance = TokenService._internal();
  factory TokenService() => _instance;
  TokenService._internal();

  static const String _tokenKey = 'auth_token';
  static const String _roleKey = 'user_role';
  static const String _nameKey = 'user_name';
  static const String _idKey = 'user_id';
  static const String _locationKey = 'user_location';
  static const String _collegeKey = 'user_college_university';
  static const String _programKey = 'user_program';
  static const String _semesterKey = 'user_semester';
  static const String _bioKey = 'user_bio';
  static const String _skillsKey = 'user_skills';
  static const String _portfolioKey = 'user_portfolio_url';
  static const String _appliedGigIdsKey = 'applied_gig_ids';

  static SharedPreferences? _prefs;

  // ---- Cached values for synchronous UI access ----

  static String? _cachedName;
  static String? _cachedId;
  static String? _cachedRole;
  static String? _cachedLocation;
  static String? _cachedCollege;
  static String? _cachedProgram;
  static String? _cachedSemester;
  static String? _cachedBio;
  static List<String> _cachedSkills = [];
  static String? _cachedPortfolio;
  static Set<int> _cachedAppliedGigIds = {};

  static Future<SharedPreferences> get _prefsInstance async {
    if (_prefs != null) return _prefs!;
    _prefs = await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ---- Synchronous getters for UI ----

  static String? getNameSync() => _cachedName;
  static String? getIdSync() => _cachedId;
  static String? getRoleSync() => _cachedRole;
  static String? getLocationSync() => _cachedLocation;
  static String? getCollegeUniversitySync() => _cachedCollege;
  static String? getProgramSync() => _cachedProgram;
  static String? getSemesterSync() => _cachedSemester;
  static String? getBioSync() => _cachedBio;
  static List<String> getSkillsSync() => _cachedSkills;
  static String? getPortfolioUrlSync() => _cachedPortfolio;
  static Set<int> getAppliedGigIdsSync() => _cachedAppliedGigIds;

  // ---- Token ----

  static Future<void> saveToken(String token) async {
    final prefs = await _prefsInstance;
    await prefs.setString(_tokenKey, token);
    TokenService._instance.notifyListeners();
  }

  static Future<String?> getToken() async {
    final prefs = await _prefsInstance;
    return prefs.getString(_tokenKey);
  }

  static Future<void> removeToken() async {
    final prefs = await _prefsInstance;
    await prefs.remove(_tokenKey);
    TokenService._instance.notifyListeners();
  }

  // ---- User Role ----

  static Future<void> saveRole(String role) async {
    final prefs = await _prefsInstance;
    await prefs.setString(_roleKey, role);
    _cachedRole = role;
    TokenService._instance.notifyListeners();
  }

  static Future<String?> getRole() async {
    final prefs = await _prefsInstance;
    return prefs.getString(_roleKey);
  }

  // ---- User Profile ----

  static Future<void> saveUser({
    required String name,
    required String id,
    required String role,
  }) async {
    final prefs = await _prefsInstance;
    await prefs.setString(_nameKey, name);
    await prefs.setString(_idKey, id);
    await prefs.setString(_roleKey, role);
    _cachedName = name;
    _cachedId = id;
    _cachedRole = role;
    TokenService._instance.notifyListeners();
  }

  static Future<void> saveFullProfile({
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
    final prefs = await _prefsInstance;
    await prefs.setString(_nameKey, name);
    await prefs.setString(_idKey, id);
    await prefs.setString(_roleKey, role);
    if (location != null) await prefs.setString(_locationKey, location);
    if (collegeUniversity != null) {
      await prefs.setString(_collegeKey, collegeUniversity);
    }
    if (program != null) await prefs.setString(_programKey, program);
    if (semester != null) await prefs.setString(_semesterKey, semester);
    if (bio != null) await prefs.setString(_bioKey, bio);
    if (skills != null) await prefs.setString(_skillsKey, jsonEncode(skills));
    if (portfolioUrl != null) {
      await prefs.setString(_portfolioKey, portfolioUrl);
    }
    _cachedName = name;
    _cachedId = id;
    _cachedRole = role;
    _cachedLocation = location;
    _cachedCollege = collegeUniversity;
    _cachedProgram = program;
    _cachedSemester = semester;
    _cachedBio = bio;
    if (skills != null) _cachedSkills = skills;
    _cachedPortfolio = portfolioUrl;
    TokenService._instance.notifyListeners();
  }

  static Future<void> updateProfile({
    String? name,
    String? location,
    String? collegeUniversity,
    String? program,
    String? semester,
    String? bio,
    List<String>? skills,
    String? portfolioUrl,
  }) async {
    final prefs = await _prefsInstance;
    if (name != null) await prefs.setString(_nameKey, name);
    if (location != null) await prefs.setString(_locationKey, location);
    if (collegeUniversity != null) {
      await prefs.setString(_collegeKey, collegeUniversity);
    }
    if (program != null) await prefs.setString(_programKey, program);
    if (semester != null) await prefs.setString(_semesterKey, semester);
    if (bio != null) await prefs.setString(_bioKey, bio);
    if (skills != null) await prefs.setString(_skillsKey, jsonEncode(skills));
    if (portfolioUrl != null) {
      await prefs.setString(_portfolioKey, portfolioUrl);
    }
    if (name != null) _cachedName = name;
    if (location != null) _cachedLocation = location;
    if (collegeUniversity != null) _cachedCollege = collegeUniversity;
    if (program != null) _cachedProgram = program;
    if (semester != null) _cachedSemester = semester;
    if (bio != null) _cachedBio = bio;
    if (skills != null) _cachedSkills = skills;
    if (portfolioUrl != null) _cachedPortfolio = portfolioUrl;
    TokenService._instance.notifyListeners();
  }

  // ---- Getters (async) ----

  static Future<String?> getName() async {
    final prefs = await _prefsInstance;
    return prefs.getString(_nameKey);
  }

  static Future<String?> getId() async {
    final prefs = await _prefsInstance;
    return prefs.getString(_idKey);
  }

  static Future<String?> getLocation() async {
    final prefs = await _prefsInstance;
    return prefs.getString(_locationKey);
  }

  static Future<String?> getCollegeUniversity() async {
    final prefs = await _prefsInstance;
    return prefs.getString(_collegeKey);
  }

  static Future<String?> getProgram() async {
    final prefs = await _prefsInstance;
    return prefs.getString(_programKey);
  }

  static Future<String?> getSemester() async {
    final prefs = await _prefsInstance;
    return prefs.getString(_semesterKey);
  }

  static Future<String?> getBio() async {
    final prefs = await _prefsInstance;
    return prefs.getString(_bioKey);
  }

  static Future<List<String>> getSkills() async {
    final prefs = await _prefsInstance;
    final skillsJson = prefs.getString(_skillsKey);
    if (skillsJson != null && skillsJson.isNotEmpty) {
      try {
        return List<String>.from(jsonDecode(skillsJson));
      } catch (_) {
        return [];
      }
    }
    return [];
  }

  static Future<String?> getPortfolioUrl() async {
    final prefs = await _prefsInstance;
    return prefs.getString(_portfolioKey);
  }

  static Future<Set<int>> getAppliedGigIds() async {
    final prefs = await _prefsInstance;
    final appliedIdsJson = prefs.getString(_appliedGigIdsKey);
    if (appliedIdsJson != null && appliedIdsJson.isNotEmpty) {
      try {
        final list = List<int>.from(jsonDecode(appliedIdsJson));
        return list.toSet();
      } catch (_) {
        return {};
      }
    }
    return {};
  }

  static Future<void> markApplied(int gigId) async {
    final ids = await getAppliedGigIds();
    ids.add(gigId);
    final prefs = await _prefsInstance;
    await prefs.setString(_appliedGigIdsKey, jsonEncode(ids.toList()));
    _cachedAppliedGigIds = ids;
    TokenService._instance.notifyListeners();
  }

  static Future<void> markWithdrawn(int gigId) async {
    final ids = await getAppliedGigIds();
    ids.remove(gigId);
    final prefs = await _prefsInstance;
    await prefs.setString(_appliedGigIdsKey, jsonEncode(ids.toList()));
    _cachedAppliedGigIds = ids;
    TokenService._instance.notifyListeners();
  }

  // ---- Clear all session data (logout) ----

  static Future<void> clear() async {
    final prefs = await _prefsInstance;
    await prefs.remove(_tokenKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_nameKey);
    await prefs.remove(_idKey);
    await prefs.remove(_locationKey);
    await prefs.remove(_collegeKey);
    await prefs.remove(_programKey);
    await prefs.remove(_semesterKey);
    await prefs.remove(_bioKey);
    await prefs.remove(_skillsKey);
    await prefs.remove(_portfolioKey);
    await prefs.remove(_appliedGigIdsKey);
    _cachedName = null;
    _cachedId = null;
    _cachedRole = null;
    _cachedLocation = null;
    _cachedCollege = null;
    _cachedProgram = null;
    _cachedSemester = null;
    _cachedBio = null;
    _cachedSkills = [];
    _cachedPortfolio = null;
    _cachedAppliedGigIds = {};
    TokenService._instance.notifyListeners();
  }
}
