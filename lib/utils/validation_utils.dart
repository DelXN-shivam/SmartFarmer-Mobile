class ValidationUtils {
  /// Validate Aadhaar number (12 digits)
  static String? validateAadhaar(String? value) {
    if (value == null || value.isEmpty) {
      return 'Aadhaar number is required';
    }
    if (value.length != 12) {
      return 'Aadhaar number must be 12 digits';
    }
    if (!RegExp(r'^\d{12}$').hasMatch(value)) {
      return 'Aadhaar number must contain only digits';
    }
    return null;
  }

  /// Validate phone number (10 digits)
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (value.length != 10) {
      return 'Phone number must be 10 digits';
    }
    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
      return 'Phone number must contain only digits';
    }
    return null;
  }

  /// Validate pincode (6 digits)
  static String? validatePincode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Pincode is required';
    }
    if (value.length != 6) {
      return 'Pincode must be 6 digits';
    }
    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'Pincode must contain only digits';
    }
    return null;
  }

  /// Validate required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate numeric value
  static String? validateNumeric(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    if (double.tryParse(value) == null) {
      return '$fieldName must be a valid number';
    }
    if (double.parse(value) <= 0) {
      return '$fieldName must be greater than 0';
    }
    return null;
  }

  /// Validate date
  static String? validateDate(DateTime? date, String fieldName) {
    if (date == null) {
      return '$fieldName is required';
    }
    if (date.isAfter(DateTime.now())) {
      return '$fieldName cannot be in the future';
    }
    return null;
  }

  /// Validate sowing date vs harvest date
  static String? validateHarvestDate(
    DateTime sowingDate,
    DateTime harvestDate,
  ) {
    if (harvestDate.isBefore(sowingDate)) {
      return 'Harvest date cannot be before sowing date';
    }
    if (harvestDate.isBefore(DateTime.now())) {
      return 'Harvest date cannot be in the past';
    }
    return null;
  }

  /// Validate image count
  static String? validateImageCount(int currentCount, int maxCount) {
    if (currentCount >= maxCount) {
      return 'Maximum $maxCount images allowed';
    }
    return null;
  }

  /// Validate location coordinates
  static String? validateLocation(double latitude, double longitude) {
    if (latitude < -90 || latitude > 90) {
      return 'Invalid latitude value';
    }
    if (longitude < -180 || longitude > 180) {
      return 'Invalid longitude value';
    }
    return null;
  }

  /// Validate crop area
  static String? validateCropArea(String? value) {
    final numericValidation = validateNumeric(value, 'Area');
    if (numericValidation != null) {
      return numericValidation;
    }

    final area = double.parse(value!);
    if (area > 1000) {
      return 'Area cannot exceed 1000 acres';
    }
    return null;
  }

  /// Validate expected yield
  static String? validateExpectedYield(String? value) {
    final numericValidation = validateNumeric(value, 'Expected yield');
    if (numericValidation != null) {
      return numericValidation;
    }

    final yield = double.parse(value!);
    if (yield > 10000) {
      return 'Expected yield cannot exceed 10,000 tons';
    }
    return null;
  }

  /// Validate farmer name (letters and spaces only)
  static String? validateFarmerName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Farmer name is required';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
      return 'Name can only contain letters and spaces';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters long';
    }
    return null;
  }

  /// Validate crop name
  static String? validateCropName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Crop name is required';
    }
    if (value.trim().length < 2) {
      return 'Crop name must be at least 2 characters long';
    }
    return null;
  }

  /// Validate address fields
  static String? validateAddress(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    if (value.trim().length < 3) {
      return '$fieldName must be at least 3 characters long';
    }
    return null;
  }

  /// Validate verification comments
  static String? validateComments(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Verification comments are required';
    }
    if (value.trim().length < 10) {
      return 'Comments must be at least 10 characters long';
    }
    return null;
  }

  /// Format phone number with spaces
  static String formatPhoneNumber(String phone) {
    if (phone.length == 10) {
      return '${phone.substring(0, 5)} ${phone.substring(5)}';
    }
    return phone;
  }

  /// Format Aadhaar number with spaces
  static String formatAadhaarNumber(String aadhaar) {
    if (aadhaar.length == 12) {
      return '${aadhaar.substring(0, 4)} ${aadhaar.substring(4, 8)} ${aadhaar.substring(8)}';
    }
    return aadhaar;
  }

  /// Format pincode
  static String formatPincode(String pincode) {
    if (pincode.length == 6) {
      return '${pincode.substring(0, 3)} ${pincode.substring(3)}';
    }
    return pincode;
  }

  /// Validate mobile number
  static String? validateMobileNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mobile number is required';
    }
    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
      return 'Please enter a valid 10-digit mobile number';
    }
    return null;
  }
}
