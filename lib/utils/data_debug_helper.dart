import 'dart:developer' as developer;
import 'dart:convert';
import '../services/shared_prefs_service.dart';
import '../services/database_service.dart';

class DataDebugHelper {
  static Future<void> debugAllDataSources() async {
    developer.log('=== DATA DEBUG REPORT ===', name: 'DataDebugHelper');
    
    // Check SharedPreferences
    await _debugSharedPreferences();
    
    // Check Database
    await _debugDatabase();
    
    developer.log('=== END DEBUG REPORT ===', name: 'DataDebugHelper');
  }
  
  static Future<void> _debugSharedPreferences() async {
    developer.log('--- SharedPreferences Debug ---', name: 'DataDebugHelper');
    
    try {
      final isLoggedIn = SharedPrefsService.isLoggedIn();
      final userId = SharedPrefsService.getUserId();
      final userRole = SharedPrefsService.getUserRole();
      final userData = SharedPrefsService.getUserData();
      
      developer.log('Is Logged In: $isLoggedIn', name: 'DataDebugHelper');
      developer.log('User ID: $userId', name: 'DataDebugHelper');
      developer.log('User Role: $userRole', name: 'DataDebugHelper');
      developer.log('User Data: ${userData != null ? jsonEncode(userData) : 'null'}', name: 'DataDebugHelper');
      
      if (userData != null) {
        developer.log('User Data Keys: ${userData.keys.toList()}', name: 'DataDebugHelper');
      }
    } catch (e) {
      developer.log('SharedPreferences Error: $e', name: 'DataDebugHelper');
    }
  }
  
  static Future<void> _debugDatabase() async {
    developer.log('--- Database Debug ---', name: 'DataDebugHelper');
    
    try {
      final userId = SharedPrefsService.getUserId();
      if (userId != null) {
        final farmer = await DatabaseService.getFarmerById(userId);
        if (farmer != null) {
          developer.log('Database Farmer Found: ${farmer.name}', name: 'DataDebugHelper');
          developer.log('Database Farmer Data: ${jsonEncode(farmer.toMap())}', name: 'DataDebugHelper');
        } else {
          developer.log('No farmer found in database for ID: $userId', name: 'DataDebugHelper');
        }
      } else {
        developer.log('No user ID available for database lookup', name: 'DataDebugHelper');
      }
    } catch (e) {
      developer.log('Database Error: $e', name: 'DataDebugHelper');
    }
  }
  
  static Future<void> validateDataConsistency() async {
    developer.log('=== DATA CONSISTENCY CHECK ===', name: 'DataDebugHelper');
    
    final prefsData = SharedPrefsService.getUserData();
    final userId = SharedPrefsService.getUserId();
    
    if (prefsData == null) {
      developer.log('ISSUE: No user data in SharedPreferences', name: 'DataDebugHelper');
      return;
    }
    
    if (userId == null) {
      developer.log('ISSUE: No user ID in SharedPreferences', name: 'DataDebugHelper');
      return;
    }
    
    try {
      final dbFarmer = await DatabaseService.getFarmerById(userId);
      
      if (dbFarmer == null) {
        developer.log('ISSUE: User exists in prefs but not in database', name: 'DataDebugHelper');
      } else {
        // Compare key fields
        final prefsName = prefsData['name'] ?? '';
        final dbName = dbFarmer.name;
        
        if (prefsName != dbName) {
          developer.log('INCONSISTENCY: Name mismatch - Prefs: "$prefsName", DB: "$dbName"', name: 'DataDebugHelper');
        } else {
          developer.log('CONSISTENCY: Data sources match', name: 'DataDebugHelper');
        }
      }
    } catch (e) {
      developer.log('CONSISTENCY CHECK ERROR: $e', name: 'DataDebugHelper');
    }
  }
}