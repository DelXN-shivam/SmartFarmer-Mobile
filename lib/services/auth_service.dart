import 'dart:convert';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_farmer/services/shared_prefs_service.dart';
import '../constants/app_constants.dart';
import '../models/farmer.dart';
import 'database_service.dart';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';

const String BASE_URL = DatabaseUrl.BASE_URL;

class AuthService {
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserId = 'user_id';
  static const String _keyUserRole = 'user_role';
  static const String _keyUserData = 'user_data';
  static const String _keyUserEmail = 'user_email';

  // Login with mobile number and OTP
  static Future<Map<String, dynamic>> login({
    required String mobileNumber,
    required String otp,
    required String role,
  }) async {
    try {
      developer.log('AuthService.login called', name: 'AuthService');
      developer.log('Login parameters:', name: 'AuthService');
      developer.log('  Mobile Number: $mobileNumber', name: 'AuthService');
      developer.log('  OTP: $otp', name: 'AuthService');
      developer.log('  Role: $role', name: 'AuthService');

      // Validate input
      if (mobileNumber.isEmpty) {
        developer.log(
          'Validation failed: Mobile number is empty',
          name: 'AuthService',
        );
        return {'success': false, 'message': 'Mobile number is required'};
      }

      if (otp.isEmpty) {
        developer.log('Validation failed: OTP is empty', name: 'AuthService');
        return {'success': false, 'message': 'OTP is required'};
      }

      developer.log('Input validation passed', name: 'AuthService');

      // Check credentials based on role
      bool isValid = false;
      Map<String, dynamic> userData = {};

      if (role == AppConstants.roleFarmer) {
        developer.log('Checking farmer credentials...', name: 'AuthService');
        // For farmers, check in database
        final farmer = await DatabaseService.getFarmerById(mobileNumber);

        if (farmer != null) {
          developer.log(
            'Farmer found: ${farmer.name} (ID: ${farmer.id})',
            name: 'AuthService',
          );
          // For demo purposes, accept any OTP for existing farmers
          isValid = true;
          userData = {
            'id': farmer.id,
            'name': farmer.name,
            'mobile_number': farmer.contactNumber,
            'role': role,
            'village': farmer.village,
            'district': farmer.district,
          };
          developer.log('Farmer login successful', name: 'AuthService');
        } else {
          developer.log(
            'No farmer found with mobile number: $mobileNumber',
            name: 'AuthService',
          );
        }
      }

      if (isValid) {
        developer.log(
          'Login successful, saving login state...',
          name: 'AuthService',
        );
        developer.log('User data to save: $userData', name: 'AuthService');

        // Save login state
        await _saveLoginState(userData);
        developer.log('Login state saved successfully', name: 'AuthService');

        return {
          'success': true,
          'message': 'Login successful',
          'userData': userData,
          'token': userData['token'], // Include token if available
        };
      } else {
        developer.log('Login failed: Invalid credentials', name: 'AuthService');
        return {'success': false, 'message': 'Invalid mobile number'};
      }
    } catch (e) {
      developer.log('Login error: $e', name: 'AuthService');
      return {'success': false, 'message': 'Login failed: ${e.toString()}'};
    }
  }

  // Register new farmer with mobile number
  static Future<Map<String, dynamic>> registerFarmer({
    required String name,
    required String mobileNumber,
    required String contactNumber,
    required String aadhaarNumber,
    required String village,
    required String landmark,
    required String taluka,
    required String district,
    required String pincode,
  }) async {
    try {
      developer.log('AuthService.registerFarmer called', name: 'AuthService');
      developer.log('Registration parameters:', name: 'AuthService');
      developer.log('  Name: $name', name: 'AuthService');
      developer.log('  Mobile Number: $mobileNumber', name: 'AuthService');
      developer.log('  Contact Number: $contactNumber', name: 'AuthService');
      developer.log('  Aadhaar Number: $aadhaarNumber', name: 'AuthService');
      developer.log('  Village: $village', name: 'AuthService');
      developer.log('  Landmark: $landmark', name: 'AuthService');
      developer.log('  Taluka: $taluka', name: 'AuthService');
      developer.log('  District: $district', name: 'AuthService');
      developer.log('  Pincode: $pincode', name: 'AuthService');

      // Validate input
      if (name.isEmpty ||
          mobileNumber.isEmpty ||
          contactNumber.isEmpty ||
          aadhaarNumber.isEmpty) {
        developer.log(
          'Validation failed: Required fields are empty',
          name: 'AuthService',
        );
        return {'success': false, 'message': 'All fields are required'};
      }

      if (aadhaarNumber.length != 12) {
        developer.log(
          'Validation failed: Aadhaar number must be 12 digits',
          name: 'AuthService',
        );
        return {
          'success': false,
          'message': 'Aadhaar number must be 12 digits',
        };
      }

      if (contactNumber.length != 10) {
        developer.log(
          'Validation failed: Contact number must be 10 digits',
          name: 'AuthService',
        );
        return {
          'success': false,
          'message': 'Contact number must be 10 digits',
        };
      }

      if (pincode.length != 6) {
        developer.log(
          'Validation failed: Pincode must be 6 digits',
          name: 'AuthService',
        );
        return {'success': false, 'message': 'Pincode must be 6 digits'};
      }

      developer.log('Input validation passed', name: 'AuthService');

      // Remove check for existing farmers by mobile/Aadhaar
      // Always proceed to create new farmer and delete all before insert
      final farmerId = 'farmer_${DateTime.now().millisecondsSinceEpoch}';
      developer.log('Generated farmer ID: $farmerId', name: 'AuthService');

      final farmer = Farmer(
        id: farmerId,
        name: name,
        contactNumber: mobileNumber,
        aadhaarNumber: aadhaarNumber,
        village: village,
        landmark: landmark,
        taluka: taluka,
        district: district,
        pincode: pincode,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      developer.log('Created farmer object:', name: 'AuthService');
      developer.log('  ID: ${farmer.id}', name: 'AuthService');
      developer.log('  Name: ${farmer.name}', name: 'AuthService');
      developer.log(
        '  Contact Number: ${farmer.contactNumber}',
        name: 'AuthService',
      );
      developer.log(
        '  Aadhaar Number: ${farmer.aadhaarNumber}',
        name: 'AuthService',
      );
      developer.log('  Village: ${farmer.village}', name: 'AuthService');
      developer.log('  Landmark: ${farmer.landmark}', name: 'AuthService');
      developer.log('  Taluka: ${farmer.taluka}', name: 'AuthService');
      developer.log('  District: ${farmer.district}', name: 'AuthService');
      developer.log('  Pincode: ${farmer.pincode}', name: 'AuthService');
      developer.log('  Created At: ${farmer.createdAt}', name: 'AuthService');
      developer.log('  Updated At: ${farmer.updatedAt}', name: 'AuthService');

      // Delete all existing farmers before inserting the new one
      await DatabaseService.deleteAllFarmers();

      developer.log('Inserting farmer into database...', name: 'AuthService');
      final result = await DatabaseService.insertFarmer(farmer);
      developer.log('Database insert result: $result', name: 'AuthService');

      if (result > 0) {
        developer.log(
          'Farmer successfully inserted into database',
          name: 'AuthService',
        );

        // Verify the saved data
        final savedFarmer = await DatabaseService.getFarmerById(farmerId);
        if (savedFarmer != null) {
          developer.log('Verified saved farmer data:', name: 'AuthService');
          developer.log('  ID: ${savedFarmer.id}', name: 'AuthService');
          developer.log('  Name: ${savedFarmer.name}', name: 'AuthService');
          developer.log(
            '  Contact Number: ${savedFarmer.contactNumber}',
            name: 'AuthService',
          );
          developer.log(
            '  Aadhaar Number: ${savedFarmer.aadhaarNumber}',
            name: 'AuthService',
          );
          developer.log(
            '  Village: ${savedFarmer.village}',
            name: 'AuthService',
          );
          developer.log(
            '  Landmark: ${savedFarmer.landmark}',
            name: 'AuthService',
          );
          developer.log('  Taluka: ${savedFarmer.taluka}', name: 'AuthService');
          developer.log(
            '  District: ${savedFarmer.district}',
            name: 'AuthService',
          );
          developer.log(
            '  Pincode: ${savedFarmer.pincode}',
            name: 'AuthService',
          );
          developer.log(
            '  Created At: ${savedFarmer.createdAt}',
            name: 'AuthService',
          );
          developer.log(
            '  Updated At: ${savedFarmer.updatedAt}',
            name: 'AuthService',
          );
        } else {
          developer.log(
            'WARNING: Could not verify saved farmer data',
            name: 'AuthService',
          );
        }

        return {
          'success': true,
          'message':
              'Registration successful! You can now login with your mobile number.',
          'farmerId': farmer.id,
        };
      } else {
        developer.log('Database insert failed', name: 'AuthService');
        return {'success': false, 'message': 'Registration failed'};
      }
    } catch (e) {
      developer.log('Registration error: $e', name: 'AuthService');
      return {
        'success': false,
        'message': 'Registration failed: ${e.toString()}',
      };
    }
  }

  // Register new farmer with backend (contact API)
  static Future<Map<String, dynamic>> registerFarmerWithContact({
    required String contact,
    required String name,
    required String aadhaarNumber,
    required String village,
    required String landMark,
    required String taluka,
    required String district,
    required String state,
    required String pincode,
    required double latitude,
    required double longitude,
  }) async {
    final url = Uri.parse(
      '$BASE_URL/api/farmer/register/contact',
    );
    final body = jsonEncode({
      "contact": contact,
      "name": name,
      "aadhaarNumber": aadhaarNumber,
      "village": village,
      "landMark": landMark,
      "taluka": taluka,
      "district": district,
      "state": state,
      "pincode": pincode,
      "location": {"latitude": latitude, "longitude": longitude},
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return {
          "success": false,
          "message": "Registration failed: \n ${response.body}",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Registration failed: $e"};
    }
  }

  // Logout
  static Future<void> logout() async {
    try {
      developer.log('AuthService.logout called', name: 'AuthService');

      // Use SharedPrefsService for consistent data clearing
      await SharedPrefsService.clearAuthData();

      developer.log(
        'Logout successful - all login data cleared from SharedPreferences',
        name: 'AuthService',
      );
    } catch (e) {
      developer.log('Logout error: $e', name: 'AuthService');
      rethrow;
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    try {
      developer.log('AuthService.isLoggedIn called', name: 'AuthService');
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
      developer.log('Is logged in: $isLoggedIn', name: 'AuthService');
      return isLoggedIn;
    } catch (e) {
      developer.log('isLoggedIn error: $e', name: 'AuthService');
      return false;
    }
  }

  // Common login API call
  static Future<Map<String, dynamic>> loginWithContact(String contact) async {
    try {
      developer.log('AuthService.loginWithContact called', name: 'AuthService');
      final url = Uri.parse(
        '$BASE_URL/api/auth/mobile-user/loginByContact?contact=$contact',
      );
      final response = await http.post(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Save user data based on role
  static Future<void> saveUserData(Map<String, dynamic> loginData) async {
    try {
      developer.log('Saving user data: $loginData', name: 'AuthService');

      final role = loginData['role'];
      final userData = loginData['data'];
      final token = loginData['token'];

      developer.log('Extracted role: $role', name: 'AuthService');
      developer.log('Extracted userData: $userData', name: 'AuthService');
      developer.log('Extracted token: $token', name: 'AuthService');

      // Create complete user data object with all fields
      final completeUserData = Map<String, dynamic>.from(userData);
      
      // Ensure all verifier-specific fields are preserved
      if (role == 'verifier') {
        // Add any missing fields with defaults
        completeUserData['role'] = role;
        completeUserData['token'] = token;
        completeUserData['email'] = userData['email'] ?? '';
        completeUserData['age'] = userData['age'] ?? 0;
        completeUserData['allocatedTaluka'] = userData['allocatedTaluka'] ?? [];
        completeUserData['farmerId'] = userData['farmerId'] ?? [];
        completeUserData['cropId'] = userData['cropId'] ?? [];
        completeUserData['talukaOfficerId'] = userData['talukaOfficerId'] ?? '';
      }

      // Use SharedPrefsService for consistent data storage
      await SharedPrefsService.saveUserData(completeUserData, role);
      if (token != null) {
        await SharedPrefsService.saveToken(token);
      }

      // Save role-specific data to local database if farmer
      if (role == 'farmer') {
        await _saveFarmerToDatabase(userData);
      }

      developer.log('Complete user data saved to SharedPreferences', name: 'AuthService');
    } catch (e) {
      developer.log('Error saving user data: $e', name: 'AuthService');
      rethrow;
    }
  }

  // Save farmer data to local database
  static Future<void> _saveFarmerToDatabase(
    Map<String, dynamic> farmerData,
  ) async {
    try {
      final farmer = Farmer(
        id: farmerData['_id'] ?? '',
        name: farmerData['name'] ?? '',
        contactNumber: farmerData['contact'] ?? '',
        aadhaarNumber: farmerData['aadhaarNumber'] ?? '',
        village: farmerData['village'] ?? '',
        landmark: farmerData['landMark'] ?? '',
        taluka: farmerData['taluka'] ?? '',
        district: farmerData['district'] ?? '',
        pincode: farmerData['pincode'] ?? '',
        createdAt:
            DateTime.tryParse(farmerData['createdAt'] ?? '') ?? DateTime.now(),
        updatedAt:
            DateTime.tryParse(farmerData['updatedAt'] ?? '') ?? DateTime.now(),
      );

      await DatabaseService.insertFarmer(farmer);
      developer.log('Farmer data saved to local database', name: 'AuthService');
    } catch (e) {
      developer.log('Error saving farmer to database: $e', name: 'AuthService');
    }
  }

  // Get user role
  static Future<String?> getUserRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyUserRole);
    } catch (e) {
      return null;
    }
  }

  // Save new farmer data and token after registration
  static Future<void> saveCurrentUserFromBackend(
    Map<String, dynamic> response,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    if (response['success'] == true && response['farmer'] != null) {
      final farmer = response['farmer'];
      await prefs.setBool(_keyIsLoggedIn, true);
      await prefs.setString(_keyUserId, farmer['_id'] ?? '');
      await prefs.setString(_keyUserData, json.encode(farmer));
      await prefs.setString(_keyUserEmail, farmer['contact'] ?? '');
      await prefs.setString('token', response['token'] ?? '');
    }
  }

  // Get user ID
  static Future<String?> getUserId() async {
    try {
      developer.log('AuthService.getUserId called', name: 'AuthService');
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(_keyUserId);
      developer.log('User ID: $userId', name: 'AuthService');
      return userId;
    } catch (e) {
      developer.log('getUserId error: $e', name: 'AuthService');
      return null;
    }
  }

  // Get user email
  static Future<String?> getUserEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyUserEmail);
    } catch (e) {
      return null;
    }
  }

  // Save login state
  static Future<void> _saveLoginState(Map<String, dynamic> userData) async {
    try {
      developer.log('_saveLoginState called', name: 'AuthService');
      developer.log('Saving user data: $userData', name: 'AuthService');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsLoggedIn, true);
      await prefs.setString(_keyUserId, userData['id']);
      await prefs.setString(_keyUserRole, userData['role']);
      await prefs.setString(_keyUserEmail, userData['mobile_number']);
      await prefs.setString(_keyUserData, json.encode(userData));

      developer.log(
        'Login state saved to SharedPreferences',
        name: 'AuthService',
      );
      developer.log('  IsLoggedIn: true', name: 'AuthService');
      developer.log('  UserID: ${userData['id']}', name: 'AuthService');
      developer.log('  UserRole: ${userData['role']}', name: 'AuthService');
      developer.log(
        '  UserEmail: ${userData['mobile_number']}',
        name: 'AuthService',
      );
    } catch (e) {
      developer.log('Save login state error: $e', name: 'AuthService');
      rethrow;
    }
  }
}
