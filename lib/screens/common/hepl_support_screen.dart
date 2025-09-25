import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/strings.dart';

import '../../services/shared_prefs_service.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final langCode = SharedPrefsService.getLanguage() ?? 'en';
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.getString('help_support', langCode)),
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
            // Header Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      Icon(Icons.help_center, size: 60, color: Colors.green),
                      const SizedBox(height: 16),
                      Text(
                        AppStrings.getString('how_can_we_help', langCode),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.getString(
                          'help_support_description',
                          langCode,
                        ),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: AppStrings.getString('quick_help', langCode),
              icon: Icons.bolt,
              children: [
                ExpansionTile(
                  leading: Icon(Icons.question_answer, color: Colors.green),
                  title: Text(AppStrings.getString('faq', langCode)),
                  children: [
                    _buildFaqItem(
                      question: "How do I reset my password?",
                      answer:
                          "Go to Profile > Settings > Change Password. You'll receive a reset link on your registered email.",
                    ),
                    _buildDivider(),
                    _buildFaqItem(
                      question: "How to report a crop issue?",
                      answer:
                          "Navigate to the 'My Crops' section, select the affected crop, and tap 'Report Issue'.",
                    ),
                    _buildDivider(),
                    _buildFaqItem(
                      question: "Where can I see market prices?",
                      answer:
                          "The 'Market' tab shows real-time prices for your region. You can filter by crop type.",
                    ),
                    _buildDivider(),
                    _buildFaqItem(
                      question: "How to contact support?",
                      answer:
                          "Use the 'Contact Support' section in this help screen or call our 24/7 helpline.",
                    ),
                  ],
                ),
                _buildDivider(),
                ExpansionTile(
                  leading: Icon(Icons.video_library, color: Colors.green),
                  title: Text(
                    AppStrings.getString('video_tutorials', langCode),
                  ),
                  children: [
                    _buildVideoTutorialItem(
                      context,
                      title: "Getting Started with Farmer App",
                      duration: "5:23",
                      thumbnail: 'assets/tutorials/getting_started.jpg',
                      onTap: () => _playVideo(
                        context,
                        "https://youtube.com/shorts/fy0SUhxY0KU?si=VgPNAi0SORWKkHAk",
                      ),
                    ),
                    _buildDivider(),
                    _buildVideoTutorialItem(
                      context,
                      title: "Crop Management Basics",
                      duration: "8:45",
                      thumbnail: 'assets/tutorials/crop_management.jpg',
                      onTap: () => _playVideo(
                        context,
                        "https://youtu.be/farmer-app-crops",
                      ),
                    ),
                    _buildDivider(),
                    _buildVideoTutorialItem(
                      context,
                      title: "Market Price Analysis",
                      duration: "6:12",
                      thumbnail: 'assets/tutorials/market_prices.jpg',
                      onTap: () => _playVideo(
                        context,
                        "https://youtu.be/farmer-app-market",
                      ),
                    ),
                  ],
                ),
                _buildDivider(),

                // Enhanced User Guide Section
                ExpansionTile(
                  leading: Icon(Icons.book, color: Colors.green),
                  title: Text(AppStrings.getString('user_guide', langCode)),
                  children: [
                    _buildGuideItem(
                      icon: Icons.agriculture,
                      title: "Crop Management Guide",
                      description:
                          "Complete guide to adding and tracking crops",
                      onTap: () => _openPdfGuide("crop_management.pdf"),
                    ),
                    _buildDivider(),
                    _buildGuideItem(
                      icon: Icons.analytics,
                      title: "Market Trends Handbook",
                      description: "Understanding and using market price data",
                      onTap: () => _openPdfGuide("market_trends.pdf"),
                    ),
                    _buildDivider(),
                    _buildGuideItem(
                      icon: Icons.settings,
                      title: "App Settings Manual",
                      description: "Customizing your app experience",
                      onTap: () => _openPdfGuide("app_settings.pdf"),
                    ),
                  ],
                ),

                _buildDivider(),
              ],
            ),

            const SizedBox(height: 24),

            // Contact Support Section
            _buildSection(
              title: AppStrings.getString('contact_support', langCode),
              icon: Icons.headset_mic,
              children: [
                _buildContactItem(
                  context,
                  Icons.email,
                  AppStrings.getString('email_us', langCode),
                  'support@farmerapp.com',
                  onTap: () => _launchEmail(),
                ),
                _buildDivider(),
                _buildContactItem(
                  context,
                  Icons.phone,
                  AppStrings.getString('call_us', langCode),
                  '+1 (800) 123-4567',
                  onTap: () => _launchPhoneCall(),
                ),
                _buildDivider(),
                _buildContactItem(
                  context,
                  Icons.chat,
                  AppStrings.getString('live_chat', langCode),
                  AppStrings.getString('available_24_7', langCode),
                  onTap: () => _startLiveChat(context),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Community Section
            _buildSection(
              title: AppStrings.getString('community', langCode),
              icon: Icons.people,
              children: [
                _buildCommunityItem(
                  context,
                  'assets/icons/whatapps_icon.png', // Add your asset
                  AppStrings.getString('community_forum', langCode),
                  onTap: () => _openForum(),
                ),
                _buildDivider(),
                _buildCommunityItem(
                  context,
                  'assets/icons/facebook_icon.png',
                  AppStrings.getString('facebook_group', langCode),
                  onTap: () => _openFacebookGroup(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Report Problem Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.bug_report),
                label: Text(AppStrings.getString('report_problem', langCode)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[50],
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.red[100]!),
                  ),
                ),
                onPressed: () => _reportProblem(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
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
            ...children,
          ],
        ),
      ),
    );
  }
  //for main quik help section

  Widget _buildContactItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle, {
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.green),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommunityItem(
    BuildContext context,
    String iconPath,
    String text, {
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.asset(iconPath, width: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  //16july
  Widget _buildFaqItem({required String question, required String answer}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          Text(answer, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildVideoTutorialItem(
    BuildContext context, {
    required String title,
    required String duration,
    required String thumbnail,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  thumbnail,
                  width: 80,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 80,
                    height: 60,
                    color: Colors.grey[200],
                    child: Icon(Icons.videocam, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.timer, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          duration,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.play_circle_filled, color: Colors.green),
            ],
          ),
        ),
      ),
    );
  }

  // User Guide Item Builder
  Widget _buildGuideItem({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.green),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  //16july 12.00 below
  Future<void> _playVideo(BuildContext context, String url) async {
    // First try to extract video ID for direct YouTube app launch
    final videoId = _getYouTubeVideoId(url);

    if (videoId != null) {
      // Try opening in YouTube app if installed
      final youtubeAppUri = Uri.parse('vnd.youtube:$videoId');

      if (await canLaunchUrl(youtubeAppUri)) {
        await launchUrl(youtubeAppUri);
        return;
      }

      // Fallback to web URL if YouTube app not available
      final youtubeWebUrl = 'https://www.youtube.com/watch?v=$videoId';
      if (await canLaunchUrl(Uri.parse(youtubeWebUrl))) {
        await launchUrl(Uri.parse(youtubeWebUrl));
        return;
      }
    }

    // If we couldn't extract video ID or launch YouTube, try direct URL
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
      return;
    }

    // If all else fails, show error
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not launch video player',
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }
  }

  // Extract video ID from URL first
  String? _getYouTubeVideoId(String url) {
    // Regular expression pattern to match YouTube video URLs
    final regExp = RegExp(
      r'^.*(youtu\.be\/|v\/|u\/\w\/|embed\/|watch\?v=|&v=)([^#&?]*).*',
      caseSensitive: false,
    );

    final match = regExp.firstMatch(url);

    // Check if match was found and video ID is 11 characters (standard YouTube ID length)
    if (match != null &&
        match.group(2) != null &&
        match.group(2)!.length == 11) {
      return match.group(2);
    }

    return null;
  }

  //end

  Future<void> _openPdfGuide(String filename) async {
    const baseUrl =
        "https://www.fao.org/fileadmin/templates/nr/sustainability_pathways/docs/Compilation_techniques_organic_agriculture_rev.pdf";
    final url = "$baseUrl$filename";

    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        ScaffoldMessenger.of(
          context as BuildContext,
        ).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not open PDF',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context as BuildContext,
      ).showSnackBar(
        SnackBar(
          content: Text(
            'Error: an internal error occured',
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }
  }
  //16 july end

  Widget _buildDivider() {
    return Divider(height: 1, color: Colors.grey[200]);
  }

  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@farmerapp.com',
      queryParameters: {
        'subject': 'Help Request from Farmer App',
        'body': 'Describe your issue here...',
      },
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      throw 'Could not launch email';
    }
  }

  Future<void> _launchPhoneCall() async {
    const url = 'tel:+18001234567';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  void _startLiveChat(BuildContext context) {
    // Implement your live chat solution
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Live Chat'),
        content: const Text('Connecting you to a support agent...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _openForum() async {
    const url = 'https://forum.farmerapp.com';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _openFacebookGroup() async {
    const url = 'https://facebook.com/groups/farmerapp';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  void _reportProblem(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        // child: const ReportProblemForm(),
      ),
    );
  }
}
