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
  static const String _phoneKey = 'user_phone';
  static const String _graduationYearKey = 'user_graduation_year';
  static const String _linkedinKey = 'user_linkedin';
  static const String _githubKey = 'user_github';
  static const String _addressKey = 'user_address';
  static const String _avatarUrlKey = 'user_avatar_url';

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
  static String? _cachedPhone;
  static String? _cachedGraduationYear;
  static String? _cachedLinkedin;
  static String? _cachedGithub;
  static String? _cachedAddress;
  static String? _cachedAvatarUrl;
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
  static String? getPhoneSync() => _cachedPhone;
  static String? getGraduationYearSync() => _cachedGraduationYear;
  static String? getLinkedinSync() => _cachedLinkedin;
  static String? getGithubSync() => _cachedGithub;
  static String? getAddressSync() => _cachedAddress;
  static String? getAvatarUrlSync() => _cachedAvatarUrl;
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
    String? phone,
    String? graduationYear,
    String? linkedin,
    String? github,
    String? address,
    String? avatarUrl,
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
    if (phone != null) await prefs.setString(_phoneKey, phone);
    if (graduationYear != null) {
      await prefs.setString(_graduationYearKey, graduationYear);
    }
    if (linkedin != null) await prefs.setString(_linkedinKey, linkedin);
    if (github != null) await prefs.setString(_githubKey, github);
    if (address != null) await prefs.setString(_addressKey, address);
    if (avatarUrl != null) await prefs.setString(_avatarUrlKey, avatarUrl);
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
    _cachedPhone = phone;
    _cachedGraduationYear = graduationYear;
    _cachedLinkedin = linkedin;
    _cachedGithub = github;
    _cachedAddress = address;
    _cachedAvatarUrl = avatarUrl;
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
    String? phone,
    String? graduationYear,
    String? linkedin,
    String? github,
    String? address,
    String? avatarUrl,
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
    if (phone != null) await prefs.setString(_phoneKey, phone);
    if (graduationYear != null) {
      await prefs.setString(_graduationYearKey, graduationYear);
    }
    if (linkedin != null) await prefs.setString(_linkedinKey, linkedin);
    if (github != null) await prefs.setString(_githubKey, github);
    if (address != null) await prefs.setString(_addressKey, address);
    if (avatarUrl != null) await prefs.setString(_avatarUrlKey, avatarUrl);
    if (name != null) _cachedName = name;
    if (location != null) _cachedLocation = location;
    if (collegeUniversity != null) _cachedCollege = collegeUniversity;
    if (program != null) _cachedProgram = program;
    if (semester != null) _cachedSemester = semester;
    if (bio != null) _cachedBio = bio;
    if (skills != null) _cachedSkills = skills;
    if (portfolioUrl != null) _cachedPortfolio = portfolioUrl;
    if (phone != null) _cachedPhone = phone;
    if (graduationYear != null) _cachedGraduationYear = graduationYear;
    if (linkedin != null) _cachedLinkedin = linkedin;
    if (github != null) _cachedGithub = github;
    if (address != null) _cachedAddress = address;
    if (avatarUrl != null) _cachedAvatarUrl = avatarUrl;
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

  static Future<String?> getPhone() async {
    final prefs = await _prefsInstance;
    return prefs.getString(_phoneKey);
  }

  static Future<String?> getGraduationYear() async {
    final prefs = await _prefsInstance;
    return prefs.getString(_graduationYearKey);
  }

  static Future<String?> getLinkedin() async {
    final prefs = await _prefsInstance;
    return prefs.getString(_linkedinKey);
  }

  static Future<String?> getGithub() async {
    final prefs = await _prefsInstance;
    return prefs.getString(_githubKey);
  }

  static Future<String?> getAddress() async {
    final prefs = await _prefsInstance;
    return prefs.getString(_addressKey);
  }

  static Future<String?> getAvatarUrl() async {
    final prefs = await _prefsInstance;
    return prefs.getString(_avatarUrlKey);
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
    await prefs.remove(_phoneKey);
    await prefs.remove(_graduationYearKey);
    await prefs.remove(_linkedinKey);
    await prefs.remove(_githubKey);
    await prefs.remove(_addressKey);
    await prefs.remove(_avatarUrlKey);
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
    _cachedPhone = null;
    _cachedGraduationYear = null;
    _cachedLinkedin = null;
    _cachedGithub = null;
    _cachedAddress = null;
    _cachedAvatarUrl = null;
    TokenService._instance.notifyListeners();
  }
}
