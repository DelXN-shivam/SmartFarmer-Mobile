abstract class AuthEvent {
  const AuthEvent();
}

class AppStarted extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String role;
  final String mobileNumber;
  final String otp;

  const LoginRequested({
    required this.role,
    required this.mobileNumber,
    required this.otp,
  });
}

class RegistrationRequested extends AuthEvent {
  final String name;
  final String mobileNumber;
  final String contactNumber;
  final String aadhaarNumber;
  final String village;
  final String landmark;
  final String taluka;
  final String district;
  final String pincode;

  const RegistrationRequested({
    required this.name,
    required this.mobileNumber,
    required this.contactNumber,
    required this.aadhaarNumber,
    required this.village,
    required this.landmark,
    required this.taluka,
    required this.district,
    required this.pincode,
  });
}

class LogoutRequested extends AuthEvent {}
