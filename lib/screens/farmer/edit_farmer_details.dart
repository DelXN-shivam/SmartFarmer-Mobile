import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/farmer/farmer_bloc.dart';
import '../../blocs/farmer/farmer_event.dart';
import '../../blocs/farmer/farmer_state.dart';
import '../../constants/strings.dart';
import '../../constants/app_constants.dart';
import '../../models/farmer.dart';
import '../../services/shared_prefs_service.dart';
import 'dart:math';
import '../../services/database_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../common/profile_view_screen.dart';

class FarmerDetailsForm extends StatefulWidget {
  final Farmer? farmer;

  const FarmerDetailsForm({super.key, this.farmer});

  @override
  State<FarmerDetailsForm> createState() => _FarmerDetailsFormState();
}

class _FarmerDetailsFormState extends State<FarmerDetailsForm> {
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _aadhaarController = TextEditingController();
  final _villageController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _talukaController = TextEditingController();
  final _districtController = TextEditingController();
  final _pincodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.farmer != null) {
      _nameController.text = widget.farmer!.name;
      _contactController.text = widget.farmer!.contactNumber;
      _aadhaarController.text = widget.farmer!.aadhaarNumber;
      _villageController.text = widget.farmer!.village;
      _landmarkController.text = widget.farmer!.landmark;
      _talukaController.text = widget.farmer!.taluka;
      _districtController.text = widget.farmer!.district;
      _pincodeController.text = widget.farmer!.pincode;
    }
  }

  @override
  Widget build(BuildContext context) {
    final langCode = SharedPrefsService.getLanguage() ?? 'en';

    return BlocListener<FarmerBloc, FarmerState>(
      listener: (context, state) {
        if (state is SingleFarmerLoaded) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppStrings.getString(
                  'data_updated_successfully',
                  SharedPrefsService.getLanguage() ?? 'en'
                ), overflow: TextOverflow.ellipsis,
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileViewScreen(
                userId: state.farmer.id,
                userRole: AppConstants.roleFarmer,
                onBack: () {
                  // This callback will be called when back is pressed from ProfileViewScreen
                  // The ProfileViewScreen will handle navigation back to the appropriate screen
                },
              ),
            ),
          );
        } else if (state is FarmerError) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}', overflow: TextOverflow.ellipsis,),
              backgroundColor: Colors.red
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.farmer == null
                ? AppStrings.getString('farmer_details', langCode)
                : 'Edit ${AppStrings.getString('farmer_details', langCode)}',
          ),
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            AppStrings.getString(
                              'personal_information',
                              langCode,
                            ),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _nameController,
                        label: AppStrings.getString('name', langCode),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _contactController,
                        label: AppStrings.getString('contact_number', langCode),
                        keyboardType: TextInputType.phone,
                        maxLength: AppConstants.phoneLength,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter contact number';
                          }
                          if (value.length != AppConstants.phoneLength) {
                            return AppStrings.getString(
                              'invalid_phone',
                              langCode,
                            );
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _aadhaarController,
                        label: AppStrings.getString('aadhaar_number', langCode),
                        keyboardType: TextInputType.number,
                        maxLength: AppConstants.aadhaarLength,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Aadhaar number';
                          }
                          if (value.length != AppConstants.aadhaarLength) {
                            return AppStrings.getString(
                              'invalid_aadhaar',
                              langCode,
                            );
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2196F3).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.location_on,
                              color: Color(0xFF2196F3),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            AppStrings.getString(
                              'address_information',
                              langCode,
                            ),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _villageController,
                        label: AppStrings.getString('village', langCode),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter village';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _landmarkController,
                        label: AppStrings.getString('landmark', langCode),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter landmark';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _talukaController,
                        label: AppStrings.getString('taluka', langCode),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter taluka';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _districtController,
                        label: AppStrings.getString('district', langCode),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter district';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _pincodeController,
                        label: AppStrings.getString('pincode', langCode),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter pincode';
                          }
                          if (value.length != AppConstants.pincodeLength) {
                            return AppStrings.getString(
                              'invalid_pincode',
                              langCode,
                            );
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: EdgeInsets.only(bottom: 10),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveFarmer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          widget.farmer == null
                              ? AppStrings.getString('save', langCode)
                              : AppStrings.getString('update', langCode),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  void _saveFarmer() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // start loader
      });

      final farmer = Farmer(
        id: widget.farmer?.id ?? _generateId(),
        name: _nameController.text.trim(),
        contactNumber: _contactController.text.trim(),
        aadhaarNumber: _aadhaarController.text.trim(),
        village: _villageController.text.trim(),
        landmark: _landmarkController.text.trim(),
        taluka: _talukaController.text.trim(),
        district: _districtController.text.trim(),
        pincode: _pincodeController.text.trim(),
        createdAt: widget.farmer?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.farmer != null) {
        // Use the new BlocEvent to update all data sources
        BlocProvider.of<FarmerBloc>(context).add(UpdateAllDataSources(farmer));
        await Future.delayed(Duration(milliseconds: 300));
        Navigator.of(context).pop();
      } else {
        // Local save for new farmer (existing logic)
        try {
          await DatabaseService.deleteAllFarmers();
          await DatabaseService.insertFarmer(farmer);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppStrings.getString(
                  'data_saved_successfully',
                  SharedPrefsService.getLanguage() ?? 'en',
                ), overflow: TextOverflow.ellipsis,
              ),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {
            _isLoading = false;
          });
          Navigator.of(context).pop();
        } catch (e) {
          if (!mounted) return;
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e', overflow: TextOverflow.ellipsis,), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  String _generateId() {
    return 'farmer_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _aadhaarController.dispose();
    _villageController.dispose();
    _landmarkController.dispose();
    _talukaController.dispose();
    _districtController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }
}
