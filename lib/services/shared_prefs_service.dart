import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import 'dart:convert';

class SharedPrefsService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    if (_prefs != null) return;
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
      print('SharedPrefs init error: $e');
      await Future.delayed(Duration(milliseconds: 100));
      _prefs = await SharedPreferences.getInstance();
    }
  }

  static Future<SharedPreferences> _ensureInitialized() async {
    if (_prefs == null) {
      await init();
    }
    return _prefs!;
  }

  // Language preferences
  static String? getLanguage() {
    if (_prefs == null) {
      print('SharedPrefs not initialized for getLanguage');
      return 'en'; // Default fallback
    }
    return _prefs!.getString(AppConstants.keyLanguage);
  }

  static Future<bool> setLanguage(String languageCode) async {
    final prefs = await _ensureInitialized();
    return await prefs.setString(AppConstants.keyLanguage, languageCode);
  }

  // User authentication
  static String? getUserRole() {
    if (_prefs == null) {
      print('SharedPrefs not initialized for getUserRole');
      return null;
    }
    return _prefs!.getString(AppConstants.keyUserRole);
  }

  static Future<bool> setUserRole(String role) async {
    final prefs = await _ensureInitialized();
    return await prefs.setString(AppConstants.keyUserRole, role);
  }

  static String? getUserId() {
    if (_prefs == null) {
      print('SharedPrefs not initialized, attempting to get from direct access');
      return null;
    }
    final userId = _prefs!.getString(AppConstants.keyUserId);
    print('Getting userId from SharedPrefs: $userId');
    return userId;
  }

  static Future<String?> getUserIdAsync() async {
    final prefs = await _ensureInitialized();
    final userId = prefs.getString(AppConstants.keyUserId);
    print('Getting userId async from SharedPrefs: $userId');
    return userId;
  }

  static Future<bool> setUserId(String userId) async {
    final prefs = await _ensureInitialized();
    return await prefs.setString(AppConstants.keyUserId, userId);
  }

  static bool isLoggedIn() {
    if (_prefs == null) {
      print('SharedPrefs not initialized for isLoggedIn');
      return false;
    }
    return _prefs!.getBool(AppConstants.keyIsLoggedIn) ?? false;
  }

  static Future<bool> setLoggedIn(bool isLoggedIn) async {
    final prefs = await _ensureInitialized();
    return await prefs.setBool(AppConstants.keyIsLoggedIn, isLoggedIn);
  }

  static Future<void> saveFarmerData(Map<String, dynamic> data) async {
    final prefs = await _ensureInitialized();
    await prefs.setString('user_data', json.encode(data));
  }

  // Save user data based on role
  static Future<void> saveUserData(Map<String, dynamic> userData, String role) async {
    try {
      final prefs = await _ensureInitialized();
      final userId = userData['_id'] ?? userData['id'] ?? '';
      
      // Create a complete data object preserving all fields
      final completeData = Map<String, dynamic>.from(userData);
      completeData['role'] = role; // Ensure role is in the data
      
      await prefs.setString('user_data', json.encode(completeData));
      await prefs.setString('user_role', role);
      await prefs.setString('user_id', userId);
      await prefs.setBool('is_logged_in', true);
      
      // Also save using AppConstants keys for consistency
      await prefs.setString(AppConstants.keyUserRole, role);
      await prefs.setString(AppConstants.keyUserId, userId);
      await prefs.setBool(AppConstants.keyIsLoggedIn, true);
      
      print('Saved complete userData with userId: $userId to SharedPreferences');
      print('Saved data keys: ${completeData.keys.toList()}');
    } catch (e) {
      print('Error saving user data: $e');
      rethrow;
    }
  }

  // Get user data
  static Map<String, dynamic>? getUserData() {
    try {
      if (_prefs == null) {
        print('SharedPrefs not initialized for getUserData');
        return null;
      }
      final userDataString = _prefs!.getString('user_data');
      if (userDataString != null && userDataString.isNotEmpty) {
        return json.decode(userDataString) as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error getting user data: $e');
    }
    return null;
  }

  // Get user token
  static String? getToken() {
    if (_prefs == null) {
      print('SharedPrefs not initialized for getToken');
      return null;
    }
    return _prefs!.getString('token');
  }

  // Save user token
  static Future<void> saveToken(String token) async {
    final prefs = await _ensureInitialized();
    await prefs.setString('token', token);
  }

  // Clear all data
  static Future<bool> clearAll() async {
    final prefs = await _ensureInitialized();
    return await prefs.clear();
  }

  // Clear only authentication data
  static Future<bool> clearAuthData() async {
    try {
      final prefs = await _ensureInitialized();
      await prefs.remove(AppConstants.keyUserRole);
      await prefs.remove(AppConstants.keyUserId);
      await prefs.remove(AppConstants.keyIsLoggedIn);
      await prefs.remove('user_data');
      await prefs.remove('user_role');
      await prefs.remove('user_id');
      await prefs.remove('is_logged_in');
      await prefs.remove('token');
      return true;
    } catch (e) {
      print('Error clearing auth data: $e');
      return false;
    }
  }

  // Get SharedPreferences instance
  static Future<SharedPreferences> getPrefs() async {
    return await _ensureInitialized();
  }

  // JSON decode helper with error handling
  static Map<String, dynamic>? decodeJson(String jsonString) {
    try {
      if (jsonString.isEmpty) return null;
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      print('JSON decode error: $e');
      return null;
    }
  }
}
