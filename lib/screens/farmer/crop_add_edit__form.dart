import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_farmer/screens/farmer/CameraScreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../blocs/crop/crop_bloc.dart';
import '../../blocs/crop/crop_event.dart';
import '../../constants/strings.dart';
import '../../constants/app_constants.dart';
import '../../models/crop.dart';
import '../../services/shared_prefs_service.dart';
import 'dart:math';
import '../../data/crop_data.dart';

import '../../constants/api_constants.dart';

// Removed: import '../../constants/api_constants.dart';

// Cloudinary credentials from CLOUDINARY_URL
typedef CloudinaryUploadResult = Map<String, dynamic>;
const String cloudinaryCloudName = 'dijjftmm8';
const String cloudinaryApiKey = '751899995943581';
const String cloudinaryApiSecret = '0DV2G8tTOMG5uLr_NtGW3256BH4';
const String cloudinaryUploadUrl =
    'https://api.cloudinary.com/v1_1/$cloudinaryCloudName/image/upload';

const String BASE_URL = DatabaseUrl.BASE_URL;

class CropDetailsForm extends StatefulWidget {
  final Crop? crop;
  final String farmerId;

  const CropDetailsForm({super.key, this.crop, required this.farmerId});

  @override
  State<CropDetailsForm> createState() => _CropDetailsFormState();
}

class _CropDetailsFormState extends State<CropDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  final _cropNameController = TextEditingController();
  final _areaController = TextEditingController();
  final _expectedYieldController = TextEditingController();
  final _previousCropController = TextEditingController();

  DateTime _sowingDate = DateTime.now();
  DateTime _expectedFirstHarvestDate = DateTime.now();
  DateTime _expectedLastHarvestDate = DateTime.now();
  double _latitude = AppConstants.defaultLatitude;
  double _longitude = AppConstants.defaultLongitude;
  List<String> _imageCloudinaryUrls = [];
  List<String> _imageCloudinaryPublicIds = [];
  List<String> _verifiedImageUrls = [];
  final ImagePicker _imagePicker = ImagePicker();
  List<String> _imageSources = [];
  final List<String> _areaUnits = ['acre', 'guntha'];
  String _selectedAreaUnit = 'acre';
  final List<String> _yieldUnits = ['kg', 'quintal', 'ton', 'carat'];
  String _selectedYieldUnit = 'kg';
  List<String> _filteredCrops = [];
  final FocusNode _cropNameFocusNode = FocusNode();
  String? _applicationStatus;
  String? _rejectedReason;

  // --- New loading states ---
  bool _isImageUploading = false;
  bool _isSubmitting = false;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _cropNameFocusNode.addListener(() {
      if (!_cropNameFocusNode.hasFocus) {
        setState(() => _showSuggestions = false);
      }
    });
    if (widget.crop != null) {
      _cropNameController.text = widget.crop!.cropName;
      _areaController.text = widget.crop!.area.toString();
      _expectedYieldController.text = widget.crop!.expectedYield.toString();
      _previousCropController.text = widget.crop!.previousCrop;
      _sowingDate = widget.crop!.sowingDate;
      _expectedFirstHarvestDate = widget.crop!.expectedFirstHarvestDate;
      _expectedLastHarvestDate = widget.crop!.expectedLastHarvestDate;
      _latitude = widget.crop!.latitude;
      _longitude = widget.crop!.longitude;
      _imageCloudinaryUrls = List.from(widget.crop!.imagePaths);
      _imageCloudinaryPublicIds = List.from(widget.crop!.imagePublicIds);
      _selectedAreaUnit = widget.crop!.areaUnit;
      _selectedYieldUnit = widget.crop!.expectedYieldUnit;
      _applicationStatus = widget.crop!.status;
      // Load verified images and rejection reason from backend
      _loadCropVerificationData();
    } else {
      _calculateExpectedHarvestDates();
    }
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    final langCode = SharedPrefsService.getLanguage() ?? 'en';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      appBar: _buildAppBar(langCode),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSection(langCode),
              const SizedBox(height: 32),
              _buildFormSection(langCode),
              const SizedBox(height: 32),
              _buildActionSection(langCode),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(String langCode) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2E7D32).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 18,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      title: Text(
        widget.crop == null
            ? AppStrings.getString('crop_details', langCode)
            : 'Edit ${AppStrings.getString('crop_details', langCode)}',
        style: const TextStyle(
          color: Color(0xFF1B5E20),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: widget.crop == null
                ? const Color(0xFFE8F5E8)
                : const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.crop == null
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFFFF9800),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.crop == null ? Icons.add_circle : Icons.edit,
                color: widget.crop == null
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFFE65100),
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                widget.crop == null ? 'New' : 'Edit',
                style: TextStyle(
                  color: widget.crop == null
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFFE65100),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderSection(String langCode) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.agriculture, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.crop == null ? 'New Crop Entry' : 'Edit Crop Details',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.crop == null
                      ? 'Fill in the details to register your crop'
                      : 'Update the crop information as needed',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection(String langCode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Basic Information', Icons.info_outline),
        const SizedBox(height: 16),
        _buildCropNameField(langCode),

        const SizedBox(height: 16),
        _buildAreaField(langCode),

        const SizedBox(height: 16),
        _buildSectionTitle('Dates & Yield', Icons.schedule),

        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                AppStrings.getString('sowing_date', langCode),
                _sowingDate,
                Icons.event_available,
                (date) {
                  setState(() {
                    _sowingDate = date;
                    _calculateExpectedHarvestDates();
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDateField(
                AppStrings.getString('expected_first_harvest_date', langCode),
                _expectedFirstHarvestDate,
                Icons.event_note,
                (date) {
                  setState(() {
                    _expectedFirstHarvestDate = date;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                AppStrings.getString('expected_last_harvest_date', langCode),
                _expectedLastHarvestDate,
                Icons.event_note,
                (date) {
                  setState(() {
                    _expectedLastHarvestDate = date;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Container()),
          ],
        ),
        // const SizedBox(height: 16),
        // _buildTextField(
        //   controller: _expectedYieldController,
        //   label: AppStrings.getString('expected_yield', langCode),
        //   hint: 'Enter expected yield',
        //   icon: Icons.bar_chart,
        //   keyboardType: TextInputType.number,
        //   validator: (value) {
        //     if (value == null || value.isEmpty) {
        //       return 'Please enter expected yield';
        //     }
        //     if (double.tryParse(value) == null) {
        //       return 'Please enter a valid number';
        //     }
        //     return null;
        //   },
        // ),
        const SizedBox(height: 16),
        _buildYieldField(langCode),
        const SizedBox(height: 16),
        _buildTextAreaField(
          '${AppStrings.getString('previous_crop', langCode)} (Optional)',
          _previousCropController,
        ),
        const SizedBox(height: 24),
        _buildSectionTitle('Location & Images', Icons.location_on),
        const SizedBox(height: 16),
        _buildLocationSection(langCode),
        const SizedBox(height: 16),
        _buildImageSection(langCode),
        if (_applicationStatus == 'verified' &&
            _verifiedImageUrls.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildVerifiedImagesSection(langCode),
        ],
        if (_applicationStatus == 'rejected' && _rejectedReason != null) ...[
          const SizedBox(height: 16),
          _buildRejectionReasonSection(langCode),
        ],
      ],
    );
  }

  Widget _buildCropNameField(String langCode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.getString('crop_name', langCode),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1B5E20),
          ),
        ),
        const SizedBox(height: 8),
        Column(
          children: [
            TextFormField(
              controller: _cropNameController,
              focusNode: _cropNameFocusNode,
              enabled: _applicationStatus != 'verified',
              onChanged: _applicationStatus == 'verified'
                  ? null
                  : (value) {
                setState(() {
                  _filteredCrops = AppConstants.maharashtraCrops
                      .where(
                        (crop) =>
                            crop.toLowerCase().contains(value.toLowerCase()),
                      )
                      .toList();
                  _showSuggestions = value.isNotEmpty;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter crop name';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: 'e.g. Rice, Cotton, Sugarcane',
                hintStyle: TextStyle(color: Colors.grey[500]),
                prefixIcon: Icon(Icons.eco, color: Color(0xFF4CAF50), size: 20),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
            if (_showSuggestions && _filteredCrops.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _filteredCrops.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_filteredCrops[index]),
                      onTap: () {
                        setState(() {
                          _cropNameController.text = _filteredCrops[index];
                          _showSuggestions = false;
                          FocusScope.of(context).unfocus();
                        });
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E8),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF2E7D32), size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1B5E20),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1B5E20),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E0E0)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2E7D32).withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[500]),
              prefixIcon: Icon(icon, color: const Color(0xFF4CAF50), size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildYieldField(String langCode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.getString('expected_yield', langCode),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1B5E20),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2E7D32).withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _expectedYieldController,
                  enabled: _applicationStatus != 'verified',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter expected yield';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    hintText: 'Enter expected yield',
                    hintStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(
                      Icons.bar_chart,
                      color: Color(0xFF4CAF50),
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2E7D32).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedYieldUnit,
                  dropdownColor: Colors.white,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  items: _yieldUnits.map((String unit) {
                    return DropdownMenuItem<String>(
                      value: unit,
                      child: Text(
                        unit,
                        style: const TextStyle(
                          color: Color(0xFF1B5E20),
                          fontSize: 18,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: _applicationStatus == 'verified'
                      ? null
                      : (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedYieldUnit = newValue;
                            });
                          }
                        },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAreaField(String langCode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.getString('area', langCode),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1B5E20),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2E7D32).withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _areaController,
                  enabled: _applicationStatus != 'verified',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter area';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    hintText: 'Enter area',
                    hintStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(
                      Icons.square_foot,
                      color: Color(0xFF4CAF50),
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2E7D32).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedAreaUnit,
                  dropdownColor: Colors.white,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  items: _areaUnits.map((String unit) {
                    return DropdownMenuItem<String>(
                      value: unit,
                      child: Text(
                        unit,
                        style: const TextStyle(
                          color: Color(0xFF1B5E20),
                          fontSize: 18,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: _applicationStatus == 'verified'
                      ? null
                      : (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedAreaUnit = newValue;
                      });
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdownField(
    String label,
    String hint,
    String? value,
    List<String> items,
    IconData icon,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1B5E20),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: MediaQuery.of(context).size.width * 0.8,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E0E0)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2E7D32).withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            value: value,
            hint: Text(hint, style: TextStyle(color: Colors.grey[500])),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: const Color(0xFF4CAF50), size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            items: items.map((String item) {
              return DropdownMenuItem<String>(value: item, child: Text(item));
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(
    String label,
    DateTime value,
    IconData icon,
    ValueChanged<DateTime> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1B5E20),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _applicationStatus == 'verified'
              ? null
              : () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: value,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Color(0xFF4CAF50),
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: Colors.black,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              onChanged(picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0E0E0)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2E7D32).withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF4CAF50), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${value.day}/${value.month}/${value.year}',
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextAreaField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1B5E20),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E0E0)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2E7D32).withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            enabled: _applicationStatus != 'verified',
            maxLines: 2,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Enter previous crop details...',
              hintStyle: TextStyle(color: Colors.grey),
              prefixIcon: Padding(
                padding: EdgeInsets.only(top: 12),
                child: Icon(Icons.history, color: Color(0xFF4CAF50), size: 20),
              ),
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection(String langCode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Color(0xFF2E7D32),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                AppStrings.getString('live_location', langCode),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FFFE),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE8F5E8)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.my_location,
                      color: Color(0xFF4CAF50),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Latitude: ${_latitude.toStringAsFixed(6)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.location_searching,
                      color: Color(0xFF4CAF50),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Longitude: ${_longitude.toStringAsFixed(6)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.gps_fixed, color: Colors.white, size: 18),
              label: const Text(
                'Update Current Location',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: _applicationStatus == 'verified'
                  ? null
                  : _getCurrentLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(String langCode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.photo_library,
                  color: Color(0xFF2E7D32),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                AppStrings.getString('upload_images', langCode),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_imageCloudinaryUrls.isNotEmpty)
            Container(
              height: 120,
              margin: const EdgeInsets.only(bottom: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _imageCloudinaryUrls.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            showGeneralDialog(
                              context: context,
                              barrierDismissible: true,
                              barrierLabel: "Image Preview",
                              pageBuilder: (context, anim1, anim2) {
                                return Scaffold(
                                  backgroundColor: Colors.black,
                                  body: SafeArea(
                                    child: GestureDetector(
                                      onTap: () => Navigator.pop(context),
                                      child: Center(
                                        child: InteractiveViewer(
                                          child: Image.network(
                                            _imageCloudinaryUrls[index],
                                            fit: BoxFit.contain,
                                            width: double.infinity,
                                            height: double.infinity,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FFFE),
                              border: Border.all(
                                color: const Color(0xFFE8F5E8),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Image.network(
                              _imageCloudinaryUrls[index],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        if (_applicationStatus != 'verified')
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () async {
                                if (index < _imageCloudinaryPublicIds.length) {
                                  final publicId =
                                      _imageCloudinaryPublicIds[index];
                                  // Delete from Cloudinary
                                  await _deleteImageFromCloudinary(publicId);
                                  setState(() {
                                    _imageCloudinaryUrls.removeAt(index);
                                    _imageCloudinaryPublicIds.removeAt(index);
                                  });
                                } else {
                                  debugPrint(
                                    'Image index $index out of range for public IDs list',
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          if (_imageCloudinaryUrls.length < AppConstants.maxCropImages &&
              _applicationStatus != 'verified')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: _isImageUploading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.add_photo_alternate,
                        color: Colors.white,
                        size: 18,
                      ),
                label: Text(
                  'Add Image (${_imageCloudinaryUrls.length}/${AppConstants.maxCropImages})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed:
                    (_imageCloudinaryUrls.length >=
                            AppConstants.maxCropImages ||
                        _isImageUploading ||
                        _applicationStatus == 'verified')
                    ? null
                    : _showImageSourceActionSheet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionSection(String langCode) {
    final bool isVerified = _applicationStatus == 'verified';
    final bool canEdit = _applicationStatus != 'verified';
    
    return Column(
      children: [
        if (canEdit)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _saveCrop,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                  const SizedBox(width: 8),
                  Text(
                    widget.crop == null
                        ? AppStrings.getString(
                            'Send for Verification',
                            langCode,
                          )
                        : AppStrings.getString('update', langCode),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (isVerified)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF4CAF50)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.verified, color: Color(0xFF4CAF50), size: 20),
                const SizedBox(width: 8),
                Text(
                  'Crop Verified - Editing Disabled',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _getStatusBackgroundColor(),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _getStatusBorderColor()),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _getStatusColor(),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Status: ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _getStatusText(),
                style: TextStyle(
                  fontSize: 14,
                  color: _getStatusColor(),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- New Cloudinary upload logic ---
  Future<CloudinaryUploadResult?> _uploadImageToCloudinary(File file) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(cloudinaryUploadUrl),
      );
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      request.fields['upload_preset'] =
          'SmartFarming'; // Use your preset if needed
      request.fields['api_key'] = cloudinaryApiKey;
      // For signed uploads, you would need to generate a signature, but for now, let's use unsigned
      var response = await request.send();
      if (response.statusCode == 200 || response.statusCode == 201) {
        final respStr = await response.stream.bytesToString();
        final data = jsonDecode(respStr);
        return data;
      } else {
        final respStr = await response.stream.bytesToString();
        debugPrint('Cloudinary upload failed: $respStr');
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(
            SnackBar(
              content: Text(
                'Cloudinary error: $respStr',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }
        return null;
      }
    } catch (e) {
      debugPrint('Cloudinary upload error: $e');
      return null;
    }
  }

  Future<void> _pickImage() async {
    if (_imageCloudinaryUrls.length >= AppConstants.maxCropImages ||
        _isImageUploading)
      return;
    setState(() {
      _isImageUploading = true;
    });
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null && mounted) {
        final uploadResult = await _uploadImageToCloudinary(
          File(pickedFile.path),
        );
        if (uploadResult != null && uploadResult['secure_url'] != null) {
          setState(() {
            _imageCloudinaryUrls.add(uploadResult['secure_url']);
            _imageCloudinaryPublicIds.add(uploadResult['public_id']);
          });
          _showSuccessSnackbar('Image uploaded successfully!');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to upload image to Cloudinary.',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to pick/upload image:  an internal error occured',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      }
      debugPrint('Error picking/uploading image: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isImageUploading = false;
        });
      }
    }
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _captureImage();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _captureImage() async {
    final startTime = DateTime.now();
    debugPrint('Capture: Start at: ' + startTime.toIso8601String());
    if (_isImageUploading) return;
    setState(() {
      _isImageUploading = true;
    });
    try {
      final cameraStatus = await Permission.camera.status;
      debugPrint(
        'Capture: Permission checked at: ' + DateTime.now().toIso8601String(),
      );
      if (!cameraStatus.isGranted) {
        final result = await Permission.camera.request();
        debugPrint(
          'Capture: Permission requested at: ' +
              DateTime.now().toIso8601String(),
        );
        if (!result.isGranted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Camera permission required',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          }
          return;
        }
      }
      final cameras = await availableCameras();
      debugPrint(
        'Capture: Cameras available at: ' + DateTime.now().toIso8601String(),
      );
      if (cameras.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(
            const SnackBar(
              content: Text(
                'No cameras available',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }
        return;
      }
      final imagePath = await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (context) => CameraScreen(
            camera: cameras.first,
            latitude: _latitude,
            longitude: _longitude,
          ),
        ),
      );
      debugPrint(
        'Capture: Returned from CameraScreen at: ' +
            DateTime.now().toIso8601String(),
      );
      if (imagePath != null && mounted) {
        final uploadResult = await _uploadImageToCloudinary(File(imagePath));
        debugPrint(
          'Capture: Uploaded to Cloudinary at: ' +
              DateTime.now().toIso8601String(),
        );
        if (uploadResult != null && uploadResult['secure_url'] != null) {
          setState(() {
            _imageCloudinaryUrls.add(uploadResult['secure_url']);
            _imageCloudinaryPublicIds.add(uploadResult['public_id']);
          });
          _showSuccessSnackbar('Image captured & uploaded successfully!');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to upload image to Cloudinary.',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            // content: Text('Failed to capture/upload image:  [${e.toString()}', overflow: TextOverflow.ellipsis,),
            content: Text(
              'Failed to capture/upload image:  an internal error occured',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      }
      debugPrint('Error capturing/uploading image: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isImageUploading = false;
        });
      }
      debugPrint('Capture: End at: ' + DateTime.now().toIso8601String());
    }
  }

  Future<void> _deleteImageFromCloudinary(String publicId) async {
    // Use Cloudinary destroy API (requires basic auth)
    final url =
        'https://api.cloudinary.com/v1_1/$cloudinaryCloudName/image/destroy';
    final basicAuth =
        'Basic ' +
        base64Encode(utf8.encode('$cloudinaryApiKey:$cloudinaryApiSecret'));
    final response = await http.post(
      Uri.parse(url),
      headers: {'Authorization': basicAuth, 'Content-Type': 'application/json'},
      body: jsonEncode({'public_id': publicId}),
    );
    if (response.statusCode == 200) {
      debugPrint('Image deleted from Cloudinary');
    } else {
      debugPrint('Failed to delete image: ${response.body}');
    }
  }

  Future<void> submitCropToBackend(Crop crop) async {
    // Use the image paths from the crop object directly. These are the full URLs.
    final List<String> imageUrls = crop.imagePaths;

    final isUpdate = widget.crop != null;
    final url = isUpdate
        ? '$BASE_URL/api/crop/update/${widget.crop!.id}'
        : '$BASE_URL/api/crop/add/${widget.farmerId}';

    final method = isUpdate ? 'PATCH' : 'POST';

    try {
      final request = http.Request(method, Uri.parse(url));
      request.headers["Content-Type"] = "application/json";
      request.body = jsonEncode({
        "name": crop.cropName,
        "area": {"value": crop.area, "unit": _selectedAreaUnit},
        "sowingDate": crop.sowingDate.toIso8601String(),
        "expectedFirstHarvestDate": crop.expectedFirstHarvestDate
            .toIso8601String(),
        "expectedLastHarvestDate": crop.expectedLastHarvestDate
            .toIso8601String(),
        "expectedYield": {
          "value": crop.expectedYield,
          "unit": _selectedYieldUnit,
        },
        "previousCrop": crop.previousCrop,
        "latitude": crop.latitude,
        "longitude": crop.longitude,
        "images": imageUrls,
      });
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                responseData['message'] ??
                    (isUpdate
                        ? 'Crop updated successfully'
                        : 'Crop added successfully'),
                overflow: TextOverflow.ellipsis,
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
        debugPrint(
          'Crop ${isUpdate ? 'updated' : 'added'} successfully: \\${response.body}',
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to ${isUpdate ? 'update' : 'add'} crop: \\${response.body}',
                overflow: TextOverflow.ellipsis,
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        debugPrint(
          'Failed to ${isUpdate ? 'update' : 'add'} crop: \\${response.body}',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error submitting crop: $e',
              overflow: TextOverflow.ellipsis,
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      debugPrint('Error submitting crop: $e');
    }
  }

  void _saveCrop() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });
      final crop = Crop(
        id: widget.crop?.id ?? _generateId(),
        farmerId: widget.farmerId,
        cropName: _cropNameController.text.trim(),
        area: double.parse(_areaController.text),
        areaUnit: _selectedAreaUnit,
        sowingDate: _sowingDate,
        expectedHarvestDate:
            _expectedLastHarvestDate, // for backward compatibility
        expectedFirstHarvestDate: _expectedFirstHarvestDate,
        expectedLastHarvestDate: _expectedLastHarvestDate,
        expectedYield: double.parse(_expectedYieldController.text),
        expectedYieldUnit: _selectedYieldUnit,
        previousCrop: _previousCropController.text.trim(),
        latitude: _latitude,
        longitude: _longitude,
        imagePaths: _imageCloudinaryUrls,
        imagePublicIds: _imageCloudinaryPublicIds,
        status: widget.crop?.status ?? AppConstants.statusPending,
        createdAt: widget.crop?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.crop == null) {
        context.read<CropBloc>().add(AddCrop(crop));
        globalCropList.add(crop);
      } else {
        context.read<CropBloc>().add(UpdateCrop(crop));
      }

      // Submit to backend
      await submitCropToBackend(crop);

      if (mounted) {
        if (widget.crop != null) {
          // It's an update, fetch the latest data and pass it back.
          final updatedCropData = await _fetchCropById(widget.crop!.id);
          Navigator.of(context).pop(updatedCropData);
        } else {
          // It's a new crop, just pop.
          Navigator.of(context).pop();
        }
      }
      setState(() {
        _isSubmitting = false;
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Please fill all required fields correctly',
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            backgroundColor: const Color(0xFFF44336),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<Map<String, dynamic>?> _fetchCropById(String cropId) async {
    try {
      final url = '$BASE_URL/api/crop/$cropId';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['crop'] as Map<String, dynamic>?;
      } else {
        debugPrint('Failed to fetch crop by ID: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching crop by ID: $e');
      return null;
    }
  }

  String _generateId() {
    return 'crop_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  void _calculateExpectedHarvestDates() {
    final lifespan =
        AppConstants.cropLifespan['rice'] ?? 120; // Default to rice lifespan
    _expectedFirstHarvestDate = _sowingDate.add(Duration(days: lifespan - 30));
    _expectedLastHarvestDate = _sowingDate.add(Duration(days: lifespan));
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Location updated successfully!',
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          backgroundColor: const Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildVerifiedImagesSection(String langCode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.verified,
                  color: Color(0xFF4CAF50),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Verified Images',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _verifiedImageUrls.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () {
                      showGeneralDialog(
                        context: context,
                        barrierDismissible: true,
                        barrierLabel: "Image Preview",
                        pageBuilder: (context, anim1, anim2) {
                          return Scaffold(
                            backgroundColor: Colors.black,
                            body: SafeArea(
                              child: GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Center(
                                  child: InteractiveViewer(
                                    child: Image.network(
                                      _verifiedImageUrls[index],
                                      fit: BoxFit.contain,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FFFE),
                        border: Border.all(
                          color: const Color(0xFF4CAF50),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              _verifiedImageUrls[index],
                              fit: BoxFit.cover,
                              width: 120,
                              height: 120,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Color(0xFF4CAF50),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.verified,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRejectionReasonSection(String langCode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFCDD2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF5252).withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.cancel,
                  color: Color(0xFFFF5252),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Rejection Reason',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFD32F2F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8F8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFCDD2)),
            ),
            child: Text(
              _rejectedReason ?? 'No reason provided',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFFD32F2F),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (_applicationStatus?.toLowerCase()) {
      case 'verified':
        return const Color(0xFF4CAF50);
      case 'rejected':
        return const Color(0xFFFF5252);
      default:
        return const Color(0xFFFF9800);
    }
  }

  Color _getStatusBackgroundColor() {
    switch (_applicationStatus?.toLowerCase()) {
      case 'verified':
        return const Color(0xFFE8F5E8);
      case 'rejected':
        return const Color(0xFFFFEBEE);
      default:
        return const Color(0xFFFFF8E1);
    }
  }

  Color _getStatusBorderColor() {
    switch (_applicationStatus?.toLowerCase()) {
      case 'verified':
        return const Color(0xFFC8E6C9);
      case 'rejected':
        return const Color(0xFFFFCDD2);
      default:
        return const Color(0xFFFFE082);
    }
  }

  String _getStatusText() {
    if (widget.crop == null) return 'Ready to Save';

    switch (_applicationStatus?.toLowerCase()) {
      case 'verified':
        return 'Verified';
      case 'rejected':
        return 'Rejected - Can Edit';
      case 'pending':
        return 'Pending Verification';
      default:
        return 'Ready to Update';
    }
  }

  Future<void> _loadCropVerificationData() async {
    if (widget.crop?.id == null) return;

    try {
      final url = '$BASE_URL/api/crop/${widget.crop!.id}';
      debugPrint('Loading crop verification data from: $url');

      final response = await http.get(Uri.parse(url));
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final cropData = data['crop'] as Map<String, dynamic>?;

        if (cropData != null && mounted) {
          debugPrint(
            'Crop data loaded: applicationStatus=${cropData['applicationStatus']}, verifiedImages=${cropData['verifiedImages']}, rejectedReason=${cropData['rejectedReason']}',
          );

          setState(() {
            _applicationStatus = cropData['applicationStatus'];
            _rejectedReason = cropData['rejectedReason'];
            if (cropData['verifiedImages'] != null &&
                cropData['verifiedImages'] is List) {
              _verifiedImageUrls = List<String>.from(
                cropData['verifiedImages'],
              );
            }
          });
        }
      } else {
        debugPrint(
          'Failed to load crop data: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('Error loading crop verification data: $e');
    }
  }

  void _showSuccessSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(message, overflow: TextOverflow.ellipsis),
            ],
          ),
          backgroundColor: const Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _cropNameFocusNode.dispose();
    _cropNameController.dispose();
    _areaController.dispose();
    _expectedYieldController.dispose();
    _previousCropController.dispose();
    super.dispose();
  }
}
