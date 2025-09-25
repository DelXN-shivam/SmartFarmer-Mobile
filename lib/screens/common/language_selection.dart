import 'package:flutter/material.dart';
import 'package:smart_farmer/screens/auth/farmer_registration_screen.dart';
import '../../constants/strings.dart';
import '../../services/shared_prefs_service.dart';

class LanguageSelectionScreen extends StatefulWidget {
  final String initialContact;
  const LanguageSelectionScreen({super.key, required this.initialContact});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String? _selectedLanguage;
  late String _langCode;
  final List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English', 'native': 'English'},
    {'code': 'hi', 'name': 'Hindi', 'native': 'हिन्दी'},
    {'code': 'mr', 'name': 'Marathi', 'native': 'मराठी'},
  ];

  @override
  void initState() {
    super.initState();
    _langCode = SharedPrefsService.getLanguage() ?? 'en';
    _selectedLanguage = _langCode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive sizing based on screen dimensions
          final bool isSmallScreen = constraints.maxWidth < 350;
          final double logoSize = isSmallScreen ? 80.0 : 120.0;
          final double titleFontSize = isSmallScreen ? 22.0 : 28.0;
          final double itemPadding = isSmallScreen ? 12.0 : 16.0;
          final double buttonPadding = isSmallScreen ? 14.0 : 16.0;

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: constraints.maxWidth * 0.05,
                vertical: constraints.maxHeight * 0.02,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: constraints.maxHeight * 0.05),

                  // App Logo
                  Image.asset(
                    'assets/images/smart-farmingLogo.png', // Replace with your logo path
                    height: logoSize,
                    width: logoSize,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: constraints.maxHeight * 0.03),

                  // App Title
                  Text(
                    AppStrings.getString(
                      'app_title',
                      _selectedLanguage ?? 'en',
                    ),
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                  SizedBox(height: constraints.maxHeight * 0.01),

                  // Subtitle
                  Text(
                    AppStrings.getString(
                      'choose_language',
                      _selectedLanguage ?? 'en',
                    ),
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14.0 : 16.0,
                      color: Colors.green[700],
                    ),
                  ),
                  SizedBox(height: constraints.maxHeight * 0.05),

                  // Language Selection List
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _languages.length,
                      separatorBuilder: (context, index) =>
                          Divider(height: 1, color: Colors.green[100]),
                      itemBuilder: (context, index) {
                        final language = _languages[index];
                        return Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: itemPadding,
                            vertical: itemPadding * 0.5,
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  language['code']!.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 12.0 : 14.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[800],
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              language['name']!,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 14.0 : 16.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              language['native']!,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 12.0 : 14.0,
                                color: Colors.grey[600],
                              ),
                            ),
                            trailing: _selectedLanguage == language['code']
                                ? Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: isSmallScreen ? 20.0 : 24.0,
                                  )
                                : null,
                            onTap: () {
                              setState(() {
                                _selectedLanguage = language['code'];
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: constraints.maxHeight * 0.05),

                  // Continue Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(vertical: buttonPadding),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _selectedLanguage == null
                          ? null
                          : () async {
                              await SharedPrefsService.setLanguage(
                                _selectedLanguage!,
                              );
                              setState(() {
                                _langCode = _selectedLanguage!;
                              });
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      FarmerRegistrationScreen(
                                        initialContact: widget.initialContact,
                                      ),
                                ),
                              );
                            },
                      child: Text(
                        AppStrings.getString(
                          'continue',
                          _selectedLanguage ?? 'en',
                        ),
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16.0 : 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: constraints.maxHeight * 0.03),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
