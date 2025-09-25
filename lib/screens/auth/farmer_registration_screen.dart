import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_farmer/screens/farmer/farmer_dashboard_screen.dart';
import '../../constants/app_theme.dart';
import '../../services/auth_service.dart';
import '../../constants/strings.dart';
import '../../services/shared_prefs_service.dart';
import '../../constants/app_constants.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/farmer.dart';
import '../../services/database_service.dart';

class FarmerRegistrationScreen extends StatefulWidget {
  final String initialContact;
  const FarmerRegistrationScreen({Key? key, required this.initialContact})
    : super(key: key);

  @override
  State<FarmerRegistrationScreen> createState() =>
      _FarmerRegistrationScreenState();
}

class _FarmerRegistrationScreenState extends State<FarmerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  // final _emailController = TextEditingController();
  final _contactController = TextEditingController();
  final _aadhaarController = TextEditingController();
  final _villageController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _talukaController = TextEditingController();
  final _districtController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _stateController = TextEditingController();

  bool _isLoading = false;
  int _currentStep = 0;
  late PageController _pageController;

  List<String> availableTalukas = [];
  final FocusNode _districtFocusNode = FocusNode();
  final FocusNode _talukaFocusNode = FocusNode();
  bool _isDistrictSelected = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    if (widget.initialContact != null) {
      _contactController.text = widget.initialContact!;
    }
    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? 0;
      if (page != _currentStep) {
        setState(() => _currentStep = page);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    // _emailController.dispose();
    _contactController.dispose();
    _aadhaarController.dispose();
    _villageController.dispose();
    _landmarkController.dispose();
    _talukaController.dispose();
    _districtController.dispose();
    _pincodeController.dispose();
    _pageController.dispose();
    //suraj add
    _districtFocusNode.dispose();
    _talukaFocusNode.dispose();

    //
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;
    final langCode = SharedPrefsService.getLanguage() ?? 'en';

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.getString('registration', langCode)),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.backgroundColor, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Progress Indicator (now only 2 steps)
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                child: Row(
                  children: [
                    _buildProgressStep(
                      0,
                      AppStrings.getString('personal_information', langCode),
                      Icons.person,
                      isSmallScreen,
                    ),
                    _buildProgressLine(),
                    _buildProgressStep(
                      1,
                      AppStrings.getString('address_information', langCode),
                      Icons.location_on,
                      isSmallScreen,
                    ),
                  ],
                ),
              ),

              // Form Content
              Expanded(
                child: Form(
                  key: _formKey,
                  child: PageView(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: _pageController,
                    children: [
                      _buildPersonalInfoStep(isSmallScreen, langCode),
                      _buildAddressStep(isSmallScreen, langCode),
                    ],
                  ),
                ),
              ),

              // Navigation Buttons
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        if (_currentStep > 0)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _previousStep,
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  vertical: isSmallScreen ? 12 : 16,
                                ),
                              ),
                              child: Text(
                                AppStrings.getString('previous', langCode),
                              ),
                            ),
                          ),
                        if (_currentStep > 0) const SizedBox(width: 16),
                        if (_currentStep == 0)
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleStepAction,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  vertical: isSmallScreen ? 12 : 16,
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : Text(
                                      AppStrings.getString('next', langCode),
                                    ),
                            ),
                          ),
                        if (_currentStep == 1)
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      if (_validateCurrentStep()) {
                                        _handleRegistration();
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  vertical: isSmallScreen ? 12 : 16,
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : Text(
                                      AppStrings.getString(
                                        'register',
                                        langCode,
                                      ),
                                    ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressStep(
    int step,
    String title,
    IconData icon,
    bool isSmallScreen,
  ) {
    final isActive = _currentStep >= step;
    final isCompleted = _currentStep > step;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: isSmallScreen ? 32 : 40,
            height: isSmallScreen ? 32 : 40,
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppTheme.successColor
                  : isActive
                  ? AppTheme.primaryColor
                  : AppTheme.textSecondaryColor.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCompleted ? Icons.check : icon,
              color: Colors.white,
              size: isSmallScreen ? 16 : 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTheme.textTheme.labelSmall?.copyWith(
              color: isActive
                  ? AppTheme.primaryColor
                  : AppTheme.textSecondaryColor,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              fontSize: isSmallScreen ? 10 : 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressLine() {
    return Container(
      height: 2,
      width: 20,
      color: _currentStep > 0 ? AppTheme.primaryColor : AppTheme.dividerColor,
    );
  }

  Widget _buildPersonalInfoStep(bool isSmallScreen, String langCode) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.getString('personal_information', langCode),
            style: AppTheme.textTheme.headlineMedium?.copyWith(
              fontSize: isSmallScreen ? 18 : 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.getString('please_provide_basic_info', langCode),
            style: AppTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondaryColor,
              fontSize: isSmallScreen ? 12 : 14,
            ),
          ),
          SizedBox(height: isSmallScreen ? 16 : 24),

          _buildTextField(
            controller: _nameController,
            label: AppStrings.getString('full_name', langCode),
            hint: AppStrings.getString('enter_full_name', langCode),
            icon: Icons.person,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppStrings.getString('name_required', langCode);
              }
              if (value.length < 2) {
                return AppStrings.getString('name_min_length', langCode);
              }
              return null;
            },
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),

          // _buildTextField(
          //   controller: _emailController,
          //   label: AppStrings.getString('email', langCode),
          //   hint: AppStrings.getString('enter_email', langCode),
          //   icon: Icons.email,
          //   validator: (value) {
          //     if (value == null || value.isEmpty) {
          //       return AppStrings.getString('email_required', langCode);
          //     }
          //     if (!value.contains('@')) {
          //       return AppStrings.getString('invalid_email', langCode);
          //     }
          //     return null;
          //   },
          // ),
          // SizedBox(height: isSmallScreen ? 12 : 16),
          _buildTextField(
            controller: _contactController,
            label: AppStrings.getString('contact_number', langCode),
            hint: AppStrings.getString('enter_mobile_number', langCode),
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppStrings.getString('phone_required', langCode);
              }
              if (value.length != 10) {
                return AppStrings.getString('invalid_phone', langCode);
              }
              return null;
            },
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),

          _buildTextField(
            controller: _aadhaarController,
            label: AppStrings.getString('aadhaar_number', langCode),
            hint: AppStrings.getString('enter_aadhaar_number', langCode),
            icon: Icons.credit_card,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(12),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppStrings.getString('aadhaar_required', langCode);
              }
              if (value.length != 12) {
                return AppStrings.getString('invalid_aadhaar', langCode);
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddressStep(bool isSmallScreen, String langCode) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.getString('address_information', langCode),
            style: AppTheme.textTheme.headlineMedium?.copyWith(
              fontSize: isSmallScreen ? 18 : 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.getString('please_provide_address', langCode),
            style: AppTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondaryColor,
              fontSize: isSmallScreen ? 12 : 14,
            ),
          ),
          SizedBox(height: isSmallScreen ? 16 : 24),

          _buildTextField(
            controller: _stateController
              ..text = AppStrings.getString(
                AppConstants.stateMaharashtra,
                langCode,
              ),
            label: AppStrings.getString('state', langCode),
            hint: AppStrings.getString('your_state', langCode),
            icon: Icons.account_balance,
            enabled: false,
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),

          // District Autocomplete
          RawAutocomplete<String>(
            focusNode: _districtFocusNode,
            textEditingController: _districtController,
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return const Iterable<String>.empty();
              }
              final localizedDistricts = getLocalizedDistricts(langCode);
              return localizedDistricts.where((translated) {
                return translated.toLowerCase().contains(
                  textEditingValue.text.toLowerCase(),
                );
              });
            },
            onSelected: (String selection) {
              final englishDistrict = getEnglishDistrictFromLocalized(
                selection,
                langCode,
              );
              setState(() {
                _districtController.text = selection;
                availableTalukas =
                    AppConstants.maharashtraDistricts[englishDistrict] ?? [];
                _isDistrictSelected = true;
                _talukaController.clear();
                FocusScope.of(context).requestFocus(_talukaFocusNode);
              });
            },
            fieldViewBuilder:
                (
                  BuildContext context,
                  TextEditingController textEditingController,
                  FocusNode focusNode,
                  VoidCallback onFieldSubmitted,
                ) {
                  return _buildTextField(
                    controller: textEditingController,
                    label: AppStrings.getString('district', langCode),
                    hint: AppStrings.getString('enter_district', langCode),
                    icon: Icons.flag,
                    focusNode: focusNode,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppStrings.getString(
                          'district_required',
                          langCode,
                        );
                      }
                      final englishDistrict = getEnglishDistrictFromLocalized(
                        value,
                        langCode,
                      );
                      if (!AppConstants.maharashtraDistricts.containsKey(
                        englishDistrict,
                      )) {
                        return AppStrings.getString(
                          'select_from_suggestions',
                          langCode,
                        );
                      }
                      return null;
                    },
                  );
                },
            optionsViewBuilder:
                (
                  BuildContext context,
                  AutocompleteOnSelected<String> onSelected,
                  Iterable<String> options,
                ) {
                  return Material(
                    elevation: 4.0,
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: options.length,
                      itemBuilder: (BuildContext context, int index) {
                        final String option = options.elementAt(index);
                        return InkWell(
                          onTap: () => onSelected(option),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(option),
                          ),
                        );
                      },
                    ),
                  );
                },
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),

          // Taluka Autocomplete
          RawAutocomplete<String>(
            focusNode: _talukaFocusNode,
            textEditingController: _talukaController,
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (!_isDistrictSelected) return const Iterable<String>.empty();
              if (textEditingValue.text.isEmpty) {
                final englishDistrict = getEnglishDistrictFromLocalized(
                  _districtController.text,
                  langCode,
                );
                return getLocalizedTalukas(englishDistrict, langCode);
              }
              final englishDistrict = getEnglishDistrictFromLocalized(
                _districtController.text,
                langCode,
              );
              return getLocalizedTalukas(englishDistrict, langCode).where((
                translated,
              ) {
                return translated.toLowerCase().contains(
                  textEditingValue.text.toLowerCase(),
                );
              });
            },
            onSelected: (String selection) {
              final englishDistrict = getEnglishDistrictFromLocalized(
                _districtController.text,
                langCode,
              );
              final englishTaluka = getEnglishTalukaFromLocalized(
                englishDistrict,
                selection,
                langCode,
              );
              setState(() {
                _talukaController.text = selection;
              });
            },
            fieldViewBuilder:
                (
                  BuildContext context,
                  TextEditingController textEditingController,
                  FocusNode focusNode,
                  VoidCallback onFieldSubmitted,
                ) {
                  return _buildTextField(
                    controller: textEditingController,
                    label: AppStrings.getString('taluka', langCode),
                    hint: _isDistrictSelected
                        ? AppStrings.getString('select_your_taluka', langCode)
                        : AppStrings.getString(
                            'select_district_first',
                            langCode,
                          ),
                    icon: Icons.map,
                    focusNode: focusNode,
                    enabled: _isDistrictSelected,
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return AppStrings.getString(
                          'taluka_required',
                          langCode,
                        );
                      final englishDistrict = getEnglishDistrictFromLocalized(
                        _districtController.text,
                        langCode,
                      );
                      final englishTaluka = getEnglishTalukaFromLocalized(
                        englishDistrict,
                        value,
                        langCode,
                      );
                      final talukas =
                          AppConstants.maharashtraDistricts[englishDistrict] ??
                          [];
                      if (!talukas.contains(englishTaluka)) {
                        return AppStrings.getString(
                          'select_from_suggestions',
                          langCode,
                        );
                      }
                      return null;
                    },
                  );
                },
            optionsViewBuilder:
                (
                  BuildContext context,
                  AutocompleteOnSelected<String> onSelected,
                  Iterable<String> options,
                ) {
                  return Material(
                    elevation: 4.0,
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: options.length,
                      itemBuilder: (BuildContext context, int index) {
                        final String option = options.elementAt(index);
                        return InkWell(
                          onTap: () => onSelected(option),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(option),
                          ),
                        );
                      },
                    ),
                  );
                },
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          _buildTextField(
            controller: _villageController,
            label: AppStrings.getString('village', langCode),
            hint: AppStrings.getString('enter_village', langCode),
            icon: Icons.map,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppStrings.getString('village_required', langCode);
              }
              return null;
            },
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          _buildTextField(
            controller: _landmarkController,
            label: AppStrings.getString('landmark', langCode),
            hint: AppStrings.getString('enter_landmark', langCode),
            icon: Icons.place,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppStrings.getString('landmark_required', langCode);
              }
              return null;
            },
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          _buildTextField(
            controller: _pincodeController,
            label: AppStrings.getString('pincode', langCode),
            hint: AppStrings.getString('enter_pincode', langCode),
            icon: Icons.pin_drop,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppStrings.getString('pincode_required', langCode);
              }
              if (value.length != 6) {
                return AppStrings.getString('invalid_pincode', langCode);
              }
              return null;
            },
          ),
          SizedBox(height: isSmallScreen ? 24 : 32),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    FocusNode? focusNode,
    bool enabled = true,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextStep() {
    if (_currentStep < 1) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handleStepAction() {
    if (_currentStep < 1) {
      if (_validateCurrentStep()) {
        _nextStep();
      }
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _formKey.currentState!.validate() &&
            _nameController.text.isNotEmpty &&
            // _emailController.text.isNotEmpty &&
            _contactController.text.isNotEmpty &&
            _aadhaarController.text.isNotEmpty;
      case 1:
        return _formKey.currentState!.validate() &&
            _villageController.text.isNotEmpty &&
            _landmarkController.text.isNotEmpty &&
            _talukaController.text.isNotEmpty &&
            _districtController.text.isNotEmpty &&
            _pincodeController.text.isNotEmpty;
      default:
        return false;
    }
  }

  Future<void> _handleRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Request location permission and get current position
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied.');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final result = await AuthService.registerFarmerWithContact(
        contact: _contactController.text.trim(),
        name: _nameController.text.trim(),
        aadhaarNumber: _aadhaarController.text.trim(),
        village: _villageController.text.trim(),
        landMark: _landmarkController.text.trim(),
        taluka: _talukaController.text.trim(),
        district: _districtController.text.trim(),
        state: _stateController.text.trim(),
        pincode: _pincodeController.text.trim(),
        latitude: position.latitude,
        longitude: position.longitude,
      );

      print('Backend registration result:');
      print(result);

      if (result['success']) {
        await AuthService.saveCurrentUserFromBackend(result);
        // Insert the new farmer into the local database
        final farmerJson = result['farmer'];
        final farmer = Farmer(
          id: farmerJson['_id'],
          name: farmerJson['name'],
          contactNumber: farmerJson['contact'],
          aadhaarNumber: farmerJson['aadhaarNumber'],
          village: farmerJson['village'],
          landmark: farmerJson['landMark'],
          taluka: farmerJson['taluka'],
          district: farmerJson['district'],
          pincode: farmerJson['pincode'],
          createdAt: DateTime.parse(farmerJson['createdAt']),
          updatedAt: DateTime.parse(farmerJson['updatedAt']),
        );
        await DatabaseService.deleteAllFarmers();
        await DatabaseService.insertFarmer(farmer);
        // TODO: Update state management with new user profile here, e.g.:
        // context.read<UserProvider>().setUser(result['farmer']);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Registration successful!'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => FarmerDashboardScreen()),
            (route) => false,
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Registration failed'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          // content: Text('Registration failed: ${e.toString()}'),
          content: Text('Registration failed: an internal error occured'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<String> getLocalizedDistricts(String langCode) {
    return AppConstants.maharashtraDistricts.keys
        .map((district) => AppStrings.getString(district, langCode))
        .toList();
  }

  String getEnglishDistrictFromLocalized(String localized, String langCode) {
    return AppConstants.maharashtraDistricts.keys.firstWhere(
      (district) => AppStrings.getString(district, langCode) == localized,
      orElse: () => localized,
    );
  }

  List<String> getLocalizedTalukas(String district, String langCode) {
    final talukas = AppConstants.maharashtraDistricts[district] ?? [];
    return talukas
        .map((taluka) => AppStrings.getString(taluka, langCode))
        .toList();
  }

  String getEnglishTalukaFromLocalized(
    String district,
    String localized,
    String langCode,
  ) {
    final talukas = AppConstants.maharashtraDistricts[district] ?? [];
    return talukas.firstWhere(
      (taluka) => AppStrings.getString(taluka, langCode) == localized,
      orElse: () => localized,
    );
  }
}
