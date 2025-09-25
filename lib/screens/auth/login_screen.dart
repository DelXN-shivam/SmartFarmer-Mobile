import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../constants/strings.dart';
import '../../constants/app_theme.dart';
import '../../services/shared_prefs_service.dart';
import '../../services/auth_service.dart';
import '../farmer/farmer_dashboard_screen.dart';
import 'farmer_registration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  String selectedRole = AppConstants.roleFarmer;
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutBack,
          ),
        );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _mobileController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final langCode = SharedPrefsService.getLanguage() ?? 'en';
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Top Section with Logo and Title
                      Flexible(
                        flex: isPortrait ? 3 : 2,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: isSmallScreen ? 16 : 24,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(
                                    isSmallScreen ? 16 : 20,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.agriculture,
                                    size: isSmallScreen ? 50 : 60,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: isSmallScreen ? 16 : 24),
                                Text(
                                  AppStrings.getString('app_title', langCode),
                                  style: AppTheme.textTheme.displaySmall
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: isSmallScreen ? 24 : 28,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Smart Farming Management',
                                  style: AppTheme.textTheme.bodyLarge?.copyWith(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: isSmallScreen ? 14 : 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Login Form Section
                      Flexible(
                        flex: isPortrait ? 7 : 5,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Container(
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              color: AppTheme.backgroundColor,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(32),
                                topRight: Radius.circular(32),
                              ),
                            ),
                            child: SingleChildScrollView(
                              padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome Back',
                                    style: AppTheme.textTheme.headlineLarge
                                        ?.copyWith(
                                          fontSize: isSmallScreen ? 20 : 22,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Sign in to continue',
                                    style: AppTheme.textTheme.bodyMedium
                                        ?.copyWith(
                                          color: AppTheme.textSecondaryColor,
                                        ),
                                  ),
                                  SizedBox(height: isSmallScreen ? 20 : 32),

                                  // Role Selection
                                  // _buildRoleSelection(
                                  //   langCode,
                                  //   isSmallScreen,
                                  //   isPortrait,
                                  // ),
                                  // SizedBox(height: isSmallScreen ? 16 : 24),

                                  // Login Form
                                  Form(
                                    key: _formKey,
                                    child: Column(
                                      children: [
                                        _buildTextField(
                                          controller: _mobileController,
                                          label: 'Mobile Number',
                                          hint: 'Enter your mobile number',
                                          icon: Icons.phone,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Mobile number is required';
                                            }
                                            return null;
                                          },
                                        ),
                                        SizedBox(
                                          height: isSmallScreen ? 12 : 16,
                                        ),
                                        _buildTextField(
                                          controller: _otpController,
                                          label: 'OTP',
                                          hint:
                                              'Enter the OTP sent to your mobile',
                                          icon: Icons.lock,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'OTP is required';
                                            }
                                            return null;
                                          },
                                        ),
                                        SizedBox(
                                          height: isSmallScreen ? 12 : 16,
                                        ),
                                        _buildLoginButton(langCode),
                                      ],
                                    ),
                                  ),

                                  SizedBox(height: isSmallScreen ? 16 : 24),

                                  // Demo Credentials Info
                                  _buildDemoCredentialsInfo(
                                    langCode,
                                    isSmallScreen,
                                  ),

                                  SizedBox(height: isSmallScreen ? 16 : 24),

                                  // Register Link
                                  _buildRegisterLink(langCode),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelection(
    String langCode,
    bool isSmallScreen,
    bool isPortrait,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Your Role',
          style: AppTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 16 : 18,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose how you want to use SmartFarmer',
          style: AppTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondaryColor,
            fontSize: isSmallScreen ? 12 : 14,
          ),
        ),
        SizedBox(height: isSmallScreen ? 12 : 16),
        // Responsive role selection based on screen size and orientation
        isPortrait && isSmallScreen
            ? Column(
                children: [
                  _buildRoleChip(
                    AppConstants.roleFarmer,
                    Icons.person,
                    'Farmer',
                    'Manage crops & profile',
                    isSmallScreen,
                  ),
                  const SizedBox(height: 8),
                ],
              )
            : GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isPortrait ? 3 : 1,
                childAspectRatio: isPortrait ? 0.8 : 3.5,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _buildRoleChip(
                    AppConstants.roleFarmer,
                    Icons.person,
                    'Farmer',
                    'Manage crops & profile',
                    isSmallScreen,
                  ),
                ],
              ),
      ],
    );
  }

  Widget _buildRoleChip(
    String role,
    IconData icon,
    String title,
    String subtitle,
    bool isSmallScreen,
  ) {
    final isSelected = selectedRole == role;

    return GestureDetector(
      onTap: () => setState(() => selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          vertical: isSmallScreen ? 12 : 16,
          horizontal: isSmallScreen ? 8 : 12,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.dividerColor,
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppTheme.primaryColor,
                size: isSmallScreen ? 20 : 24,
              ),
            ),
            SizedBox(height: isSmallScreen ? 6 : 8),
            Text(
              title,
              style: AppTheme.textTheme.titleMedium?.copyWith(
                color: isSelected ? Colors.white : AppTheme.textPrimaryColor,
                fontWeight: FontWeight.w600,
                fontSize: isSmallScreen ? 14 : 16,
              ),
            ),
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                subtitle,
                style: AppTheme.textTheme.labelSmall?.copyWith(
                  color: isSelected
                      ? Colors.white70
                      : AppTheme.textSecondaryColor,
                  fontSize: isSmallScreen ? 10 : 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildLoginButton(String langCode) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Sign In',
                style: AppTheme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildDemoCredentialsInfo(String langCode, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: AppTheme.infoColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.infoColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppTheme.infoColor,
                size: isSmallScreen ? 18 : 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Demo Credentials',
                style: AppTheme.textTheme.titleSmall?.copyWith(
                  color: AppTheme.infoColor,
                  fontWeight: FontWeight.w600,
                  fontSize: isSmallScreen ? 12 : 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getDemoCredentialsText(),
            style: AppTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondaryColor,
              fontSize: isSmallScreen ? 11 : 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterLink(String langCode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: AppTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
        ),
        TextButton(
          onPressed: () => _showRegistrationChoiceDialog(),
          child: Text(
            'Register',
            style: AppTheme.textTheme.labelLarge?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _showRegistrationChoiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Register as'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.person, color: AppTheme.primaryColor),
              title: Text('Farmer'),
              onTap: () {
                Navigator.pop(context);
                _navigateToRegistration(role: AppConstants.roleFarmer);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToRegistration({String role = AppConstants.roleFarmer}) async {
    Widget screen = const FarmerRegistrationScreen(initialContact: "");
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );

    // Show success message if registration was successful
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Registration successful! You can now login with your credentials.',
            overflow: TextOverflow.ellipsis,
          ),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  String _getDemoCredentialsText() {
    return 'Available Farmer emails:\nfarmer_001@example.com\nfarmer_002@example.com\nfarmer_003@example.com\n\nUse any password for demo';
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Log the login attempt
      print('LoginScreen: Login attempt initiated');
      print('LoginScreen: Mobile: ${_mobileController.text.trim()}');
      print('LoginScreen: Role: $selectedRole');

      // Use direct AuthService call
      final result = await AuthService.login(
        mobileNumber: _mobileController.text.trim(),
        otp: _otpController.text.trim(),
        role: selectedRole,
      );

      print('LoginScreen: Login result: $result');

      if (result['success']) {
        print('LoginScreen: Login successful');
        // Navigate to appropriate dashboard based on role
        _navigateToDashboard(selectedRole);
      } else {
        print('LoginScreen: Login failed: ${result['message']}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'], overflow: TextOverflow.ellipsis),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    } catch (e) {
      print('LoginScreen: Login error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: $e', overflow: TextOverflow.ellipsis),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToDashboard(String role) {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const FarmerDashboardScreen()),
      );
    }
  }
}
