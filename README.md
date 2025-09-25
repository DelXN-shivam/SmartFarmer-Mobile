# SmartFarmer - Smart Farming Management Application

A comprehensive Flutter mobile application for managing farming operations with AI-powered insights, crop verification, and multi-role support.

## Features

### 🌾 Farmer Side
- **Dashboard**: Overview of crops, profile, and quick actions
- **Farmer Details Entry**: Complete profile management with validation
- **Crop Details Entry**: Comprehensive crop information with auto-calculated harvest dates
- **Add New Crop**: Bottom sheet for adding multiple crops
- **Crop Lifespan Calculation**: AI-powered insights based on crop age
- **Profile Search & View**: Search and view farmer profiles
- **Location Filtering**: Filter by village, taluka, or district
- **Update Cycle**: Edit crops before verification

### 🔍 Crop Verifier Side
- **Dashboard**: Pending verifications and verified crops overview
- **Field Verification**: Verify crops with comments and geo-tagged images
- **Location Filtering**: Filter farmers and crops by location
- **Profile Search**: Search and view farmer profiles with verification status

### 👨‍💼 Admin Dashboard
- **Overview**: Statistics and insights for all farmers and crops
- **Data Management**: View and manage all farmer and crop data
- **Advanced Insights**: AI-driven insights and trend analysis
- **Reports**: Generate and export reports
- **Charts**: Visual data representation using fl_chart

### 🤖 AI Integration
- **Crop Age Insights**: Growth stage analysis and recommendations
- **Smart Recommendations**: AI-powered farming suggestions
- **Yield Prediction**: Predictive analytics for crop yields
- **Seasonal Insights**: Weather and seasonal recommendations

### 🌐 Multilanguage Support
- **English & Hindi**: Complete UI translation
- **User Preferences**: Language selection stored in SharedPreferences
- **Dynamic Switching**: Real-time language changes

## Technical Stack

- **Framework**: Flutter 3.8+
- **State Management**: flutter_bloc
- **Local Database**: SQFLite
- **Local Storage**: SharedPreferences
- **Location Services**: geolocator
- **Image Handling**: image_picker
- **Charts**: fl_chart
- **Localization**: flutter_localizations

## Project Structure

```
lib/
├── blocs/                    # State management
│   ├── auth/                # Authentication
│   ├── farmer/              # Farmer management
│   ├── crop/                # Crop management
│   ├── verification/        # Verification process
│   └── filter/              # Location filtering
├── models/                  # Data models
│   ├── farmer.dart
│   ├── crop.dart
│   └── verification.dart
├── screens/                 # UI screens
│   ├── auth/               # Authentication screens
│   ├── farmer/             # Farmer side screens
│   ├── verifier/           # Verifier side screens
│   ├── admin/              # Admin screens
│   ├── search/             # Search functionality
│   └── filter/             # Filter screens
├── services/               # Business logic
│   ├── database_service.dart
│   └── shared_prefs_service.dart
├── widgets/                # Reusable components
│   ├── ai_insights_widget.dart
│   └── crop_card_widget.dart
├── utils/                  # Utilities
│   ├── ai_service.dart
│   └── validation_utils.dart
└── constants/              # App constants
    ├── app_constants.dart
    └── strings.dart
```

## Installation & Setup

### Prerequisites
- Flutter SDK 3.8.1 or higher
- Dart SDK 3.8.1 or higher
- Android Studio / VS Code
- Android SDK (for Android development)
- Xcode (for iOS development, macOS only)

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd smart_farmer
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

### Platform Setup

#### Android
- Minimum SDK: API 21 (Android 5.0)
- Target SDK: API 33 (Android 13)
- Permissions required:
  - Location access
  - Camera access
  - Storage access

#### iOS
- Minimum iOS version: 12.0
- Permissions required:
  - Location access
  - Camera access
  - Photo library access

## Database Schema

### Farmers Table
- id (TEXT PRIMARY KEY)
- name (TEXT)
- contact_number (TEXT)
- aadhaar_number (TEXT)
- village (TEXT)
- landmark (TEXT)
- taluka (TEXT)
- district (TEXT)
- pincode (TEXT)
- created_at (TEXT)
- updated_at (TEXT)

### Crops Table
- id (TEXT PRIMARY KEY)
- farmer_id (TEXT FOREIGN KEY)
- crop_name (TEXT)
- area (REAL)
- crop_type (TEXT)
- soil_type (TEXT)
- sowing_date (TEXT)
- expected_harvest_date (TEXT)
- expected_yield (REAL)
- previous_crop (TEXT)
- latitude (REAL)
- longitude (REAL)
- image_paths (TEXT)
- status (TEXT)
- created_at (TEXT)
- updated_at (TEXT)

### Verifications Table
- id (TEXT PRIMARY KEY)
- crop_id (TEXT FOREIGN KEY)
- farmer_id (TEXT FOREIGN KEY)
- verifier_id (TEXT)
- status (TEXT)
- comments (TEXT)
- verification_images (TEXT)
- verification_latitude (REAL)
- verification_longitude (REAL)
- verification_date (TEXT)
- created_at (TEXT)
- updated_at (TEXT)

## Usage Guide

### For Farmers
1. **Login**: Select "Farmer" role and enter user ID
2. **Profile Setup**: Complete farmer details entry
3. **Add Crops**: Use the "Add New Crop" feature
4. **Monitor**: View crop age insights and AI recommendations
5. **Update**: Edit crop details before verification

### For Crop Verifiers
1. **Login**: Select "Crop Verifier" role
2. **View Pending**: Check pending verifications
3. **Field Visit**: Verify crops with location and images
4. **Submit**: Provide verification status and comments

### For Admins
1. **Login**: Select "Admin" role
2. **Dashboard**: View system overview and statistics
3. **Reports**: Generate and export data reports
4. **Insights**: Analyze AI-driven insights and trends

## AI Features

### Crop Age Analysis
- Automatic calculation of crop age in days
- Growth stage determination (Germination, Vegetative, Flowering, Fruiting, Harvesting)
- Days to harvest prediction

### Smart Recommendations
- Soil type specific advice
- Crop type specific insights
- Seasonal recommendations
- Weather-based suggestions

### Yield Prediction
- AI-powered yield estimation
- Historical data analysis
- Environmental factor consideration

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support and questions:
- Create an issue in the repository
- Contact the development team
- Check the documentation

## Future Enhancements

- [ ] Real-time weather integration
- [ ] Advanced AI/ML models
- [ ] Offline-first architecture
- [ ] Push notifications
- [ ] Social features
- [ ] Marketplace integration
- [ ] Blockchain integration for verification
- [ ] IoT sensor integration
- [ ] Advanced analytics dashboard
- [ ] Multi-language support expansion

## Acknowledgments

- Flutter team for the amazing framework
- All contributors and testers
- Agricultural experts for domain knowledge
- Open source community for libraries and tools
