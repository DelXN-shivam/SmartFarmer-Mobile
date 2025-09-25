import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_farmer/services/shared_prefs_service.dart';
import 'dart:developer' as developer;
import 'auth_event.dart';
import 'auth_state.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AppStarted>((event, emit) async {
      try {
        developer.log('AppStarted event triggered', name: 'AuthBloc');
        
        // Check if user is logged in using SharedPrefsService
        final isLoggedIn = SharedPrefsService.isLoggedIn();
        developer.log('Is logged in: $isLoggedIn', name: 'AuthBloc');

        if (isLoggedIn) {
          // Get user data using SharedPrefsService with fallback
          final userId = SharedPrefsService.getUserId();
          final userRole = SharedPrefsService.getUserRole() ?? 'farmer';
          final userData = SharedPrefsService.getUserData();
          
          developer.log('User ID: $userId', name: 'AuthBloc');
          developer.log('User Role: $userRole', name: 'AuthBloc');
          developer.log('User data: $userData', name: 'AuthBloc');

          if (userId != null && userId.isNotEmpty) {
            emit(Authenticated(role: userRole, userId: userId));
            developer.log(
              'User authenticated successfully with role: $userRole',
              name: 'AuthBloc',
            );
          } else {
            // Clear corrupted data and force re-login
            await SharedPrefsService.clearAuthData();
            emit(Unauthenticated());
            developer.log(
              'User data corrupted, cleared and unauthenticated',
              name: 'AuthBloc',
            );
          }
        } else {
          emit(Unauthenticated());
          developer.log('User not logged in', name: 'AuthBloc');
        }
      } catch (e) {
        developer.log('AppStarted error: $e', name: 'AuthBloc');
        emit(Unauthenticated());
      }
    });

    on<LoginRequested>((event, emit) async {
      try {
        developer.log('LoginRequested event triggered', name: 'AuthBloc');
        developer.log(
          'Login attempt - Mobile: ${event.mobileNumber}, OTP: ${event.otp}, Role: ${event.role}',
          name: 'AuthBloc',
        );

        emit(AuthLoading());

        // Call the actual login method with mobileNumber, otp, and role
        final result = await AuthService.login(
          mobileNumber: event.mobileNumber,
          otp: event.otp,
          role: event.role,
        );

        developer.log('Login result: $result', name: 'AuthBloc');

        if (result['success']) {
          // Save user data using SharedPrefsService for consistency
          if (result['userData'] != null) {
            await SharedPrefsService.saveUserData(result['userData'], event.role);
            
            // If token is present in result, save it as well
            if (result['token'] != null) {
              await SharedPrefsService.saveToken(result['token']);
            }
          }
          
          // Get userId after saving - give it a moment to save
          await Future.delayed(Duration(milliseconds: 100));
          final userId = SharedPrefsService.getUserId() ?? result['userData']['id'] ?? '';
          developer.log('Final userId for authentication: $userId', name: 'AuthBloc');
          emit(Authenticated(role: event.role, userId: userId));
        } else {
          developer.log('Login failed: ${result['message']}', name: 'AuthBloc');
          emit(AuthError(message: result['message']));
        }
      } catch (e) {
        developer.log('Login error: $e', name: 'AuthBloc');
        emit(AuthError(message: e.toString()));
      }
    });

    on<RegistrationRequested>((event, emit) async {
      try {
        developer.log(
          'RegistrationRequested event triggered',
          name: 'AuthBloc',
        );
        developer.log('Registration data received:', name: 'AuthBloc');
        developer.log('  Name: ${event.name}', name: 'AuthBloc');
        developer.log('  Mobile: ${event.mobileNumber}', name: 'AuthBloc');
        developer.log(
          '  Contact Number: ${event.contactNumber}',
          name: 'AuthBloc',
        );
        developer.log(
          '  Aadhaar Number: ${event.aadhaarNumber}',
          name: 'AuthBloc',
        );
        developer.log('  Village: ${event.village}', name: 'AuthBloc');
        developer.log('  Landmark: ${event.landmark}', name: 'AuthBloc');
        developer.log('  Taluka: ${event.taluka}', name: 'AuthBloc');
        developer.log('  District: ${event.district}', name: 'AuthBloc');
        developer.log('  Pincode: ${event.pincode}', name: 'AuthBloc');

        emit(AuthLoading());

        // Registration should use the new backend and save user data
        // You may need to update this to use registerFarmerWithContact and save user
        // For now, just emit Unauthenticated after registration
        emit(Unauthenticated());
      } catch (e) {
        developer.log('Registration error: $e', name: 'AuthBloc');
        emit(AuthError(message: e.toString()));
      }
    });

    on<LogoutRequested>((event, emit) async {
      try {
        developer.log('LogoutRequested event triggered', name: 'AuthBloc');
        await AuthService.logout();
        developer.log('User logged out successfully', name: 'AuthBloc');
        emit(Unauthenticated());
      } catch (e) {
        developer.log('Logout error: $e', name: 'AuthBloc');
        emit(AuthError(message: e.toString()));
      }
    });
  }

  // Helper method to get saved farmer data for logging
  Future<Map<String, dynamic>?> _getSavedFarmerData(String farmerId) async {
    try {
      final farmer = await DatabaseService.getFarmerById(farmerId);
      return farmer?.toMap();
    } catch (e) {
      developer.log('Error getting saved farmer data: $e', name: 'AuthBloc');
      return null;
    }
  }
}
