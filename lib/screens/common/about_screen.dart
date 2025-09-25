import 'package:flutter/material.dart';
import '../../constants/strings.dart';
import '../../constants/app_constants.dart';
import '../../services/shared_prefs_service.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final langCode = SharedPrefsService.getLanguage() ?? 'en';
    final appVersion = AppConstants.appVersion; // Add this to your constants
    final buildNumber = AppConstants.buildNumber; // Add this to your constants

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.getString('about', langCode)),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // App Logo and Basic Info
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/smart-farmingLogo.png', // Update with your path
                        height: 100,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        AppStrings.getString('app_title', langCode),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Version $appVersion (Build $buildNumber)',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppStrings.getString('app_title', langCode),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // App Description
            _buildSection(
              title: AppStrings.getString('about_app', langCode),
              content: AppStrings.getString('app_description', langCode),
              icon: Icons.info,
            ),
            const SizedBox(height: 24),

            // Features List
            _buildSection(
              title: AppStrings.getString('key_features', langCode),
              content: '',
              icon: Icons.star,
              children: [
                _buildFeatureItem(
                  Icons.agriculture,
                  AppStrings.getString('feature_crop_tracking', langCode),
                ),
                _buildFeatureItem(
                  Icons.attach_money,
                  AppStrings.getString('feature_market_prices', langCode),
                ),
                _buildFeatureItem(
                  Icons.cloud,
                  AppStrings.getString('feature_weather_alerts', langCode),
                ),
                _buildFeatureItem(
                  Icons.school,
                  AppStrings.getString('feature_farming_tips', langCode),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Developer Info
            _buildSection(
              title: AppStrings.getString('development_team', langCode),
              content: AppStrings.getString('team_description', langCode),
              icon: Icons.code,
            ),
            const SizedBox(height: 24),

            // Contact Information
            _buildSection(
              title: AppStrings.getString('contact_us', langCode),
              content: '',
              icon: Icons.contact_mail,
              children: [
                _buildContactItem(
                  Icons.email,
                  AppStrings.getString('contact_email', langCode),
                  'support@farmerapp.com',
                ),
                _buildContactItem(
                  Icons.phone,
                  AppStrings.getString('contact_phone', langCode),
                  '+1 (555) 123-4567',
                ),
                _buildContactItem(
                  Icons.location_on,
                  AppStrings.getString('contact_address', langCode),
                  'Agricultural Tech Park, Farmville',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Social Media Links
            _buildSocialMediaLinks(),
            const SizedBox(height: 24),

            // Legal Information
            TextButton(
              onPressed: () => _showLicenseDialog(context, langCode),
              child: Text(
                AppStrings.getString('terms_and_privacy', langCode),
                style: const TextStyle(color: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    required IconData icon,
    List<Widget>? children,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (content.isNotEmpty)
              Text(
                content,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
            if (children != null) ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialMediaLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Image.asset(
            'assets/icons/facebook_icon.png',
            width: 32,
          ), // Add your assets
          onPressed: () => _launchSocialMedia('facebook'),
        ),
        IconButton(
          icon: Image.asset('assets/icons/facebook_icon.png', width: 32),
          onPressed: () => _launchSocialMedia('twitter'),
        ),
        IconButton(
          icon: Image.asset('assets/icons/facebook_icon.png', width: 32),
          onPressed: () => _launchSocialMedia('instagram'),
        ),
        IconButton(
          icon: Image.asset('assets/icons/facebook_icon.png', width: 32),
          onPressed: () => _launchSocialMedia('youtube'),
        ),
      ],
    );
  }

  void _launchSocialMedia(String platform) {
    // Implement social media URL launching
    // Example: url_launcher package can be used
  }

  void _showLicenseDialog(BuildContext context, String langCode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.getString('legal_information', langCode)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.getString('terms_of_service', langCode),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.getString('terms_content', langCode),
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.getString('privacy_policy', langCode),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.getString('privacy_content', langCode),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.getString('close', langCode)),
          ),
        ],
      ),
    );
  }
}
