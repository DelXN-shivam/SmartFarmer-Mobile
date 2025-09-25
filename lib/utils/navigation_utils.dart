import 'package:flutter/material.dart';
import '../screens/farmer/farmer_dashboard_screen.dart';
import '../screens/verifier/verifier_dashboard_screen.dart';
import '../screens/auth/otp_verification_screen.dart';

class NavigationUtils {
  static void navigateBasedOnRole(BuildContext context, String role) {
    Widget destination;

    switch (role.toLowerCase()) {
      case 'farmer':
        destination = const FarmerDashboardScreen();
        break;
      case 'verifier':
        destination = const VerifierDashboardScreen();
        break;
      default:
        // Default to farmer dashboard if role is unknown
        destination = const FarmerDashboardScreen();
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => destination),
      (route) => false,
    );
  }

  static void navigateToLogin(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MobileOTPScreen()),
      (route) => false,
    );
  }
}