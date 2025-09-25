import 'dart:developer' as developer;
import '../services/shared_prefs_service.dart';

class ReleaseDebugHelper {
  static Future<void> testSharedPrefs() async {
    try {
      // Test basic string storage
      await SharedPrefsService.setLanguage('en');
      final lang = SharedPrefsService.getLanguage();
      developer.log('Language test: $lang', name: 'ReleaseDebug');
      
      // Test basic data storage
      final testData = {'id': 'farmer123', 'name': 'Sample Farmer'};
      await SharedPrefsService.saveUserData(testData, 'farmer');
      
      final savedData = SharedPrefsService.getUserData();
      developer.log('User data test: $savedData', name: 'ReleaseDebug');
      
      final isLoggedIn = SharedPrefsService.isLoggedIn();
      developer.log('Login status: $isLoggedIn', name: 'ReleaseDebug');
      
    } catch (e) {
      developer.log('SharedPrefs test failed: $e', name: 'ReleaseDebug');
    }
  }
}