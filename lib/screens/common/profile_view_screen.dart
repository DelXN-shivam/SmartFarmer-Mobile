import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../blocs/farmer/farmer_bloc.dart';
import '../../blocs/farmer/farmer_state.dart';
import '../../constants/app_constants.dart';
import '../../constants/strings.dart';
import '../../models/farmer.dart';
import '../../services/shared_prefs_service.dart';
import '../farmer/edit_farmer_details.dart';

class ProfileViewScreen extends StatefulWidget {
  final String userId;
  final String userRole;
  final VoidCallback onBack;

  const ProfileViewScreen({
    super.key,
    required this.userId,
    required this.userRole,
    required this.onBack,
  });

  @override
  State<ProfileViewScreen> createState() => _ProfileViewScreenState();
}

class _ProfileViewScreenState extends State<ProfileViewScreen> {
  Map<String, dynamic>? _profileData;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');
    if (userDataString != null) {
      setState(() {
        _profileData = json.decode(userDataString) as Map<String, dynamic>;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final langCode = SharedPrefsService.getLanguage() ?? 'en';

    String _formatDate(String dateString) {
      try {
        final date = DateTime.parse(dateString);
        return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
      } catch (e) {
        return dateString.split('T')[0];
      }
    }

    return BlocBuilder<FarmerBloc, FarmerState>(
      builder: (context, state) {
        // Get data from BLoC first, fallback to cached profile data
        final farmer = (state is SingleFarmerLoaded) ? state.farmer : null;

        // Merge data sources - BLoC state takes priority
        final name = farmer?.name ?? _profileData?['name'] ?? '';
        final aadhaar =
            farmer?.aadhaarNumber ?? _profileData?['aadhaarNumber'] ?? '';
        final contact =
            farmer?.contactNumber ?? _profileData?['contactNumber'] ?? '';
        final village = farmer?.village ?? _profileData?['village'] ?? '';
        final taluka = farmer?.taluka ?? _profileData?['taluka'] ?? '';
        final district = farmer?.district ?? _profileData?['district'] ?? '';
        final pincode = farmer?.pincode ?? _profileData?['pincode'] ?? '';
        final id = farmer?.id ?? _profileData?['id'] ?? '';

        final createdAtRaw =
            farmer?.createdAt?.toString() ?? _profileData?['createdAt'] ?? '';
        final createdAt = createdAtRaw.isNotEmpty
            ? _formatDate(createdAtRaw)
            : '';

        return WillPopScope(
          onWillPop: () async {
            widget.onBack();
            return true;
          },
          child: Scaffold(
            backgroundColor: const Color(0xFFF8FFFE),
            body: CustomScrollView(
              slivers: [
                _buildSliverAppBar(context, farmer),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileHeader(name, langCode),
                        const SizedBox(height: 24),
                        _buildQuickStats(),
                        const SizedBox(height: 24),
                        _buildDetailsSection(
                          title: AppStrings.getString(
                            'personal_information',
                            langCode,
                          ),
                          sectionIcon: Icons.person_outline,
                          details: [
                            _buildDetailRow(
                              AppStrings.getString('name', langCode),
                              name,
                              Icons.person,
                              const Color(0xFF4CAF50),
                            ),
                            _buildDetailRow(
                              AppStrings.getString('contact_number', langCode),
                              contact,
                              Icons.phone,
                              const Color(0xFF2196F3),
                            ),
                            _buildDetailRow(
                              AppStrings.getString('aadhaar_number', langCode),
                              aadhaar,
                              Icons.credit_card,
                              const Color(0xFFFF9800),
                              isLast: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildDetailsSection(
                          title: AppStrings.getString(
                            'address_information',
                            langCode,
                          ),
                          sectionIcon: Icons.location_on_outlined,
                          details: [
                            _buildDetailRow(
                              AppStrings.getString('village', langCode),
                              village,
                              Icons.location_city,
                              const Color(0xFF4CAF50),
                            ),
                            _buildDetailRow(
                              AppStrings.getString('taluka', langCode),
                              taluka,
                              Icons.location_on,
                              const Color(0xFF2196F3),
                            ),
                            _buildDetailRow(
                              AppStrings.getString('district', langCode),
                              district,
                              Icons.location_on,
                              const Color(0xFFFF9800),
                            ),
                            _buildDetailRow(
                              AppStrings.getString('pincode', langCode),
                              pincode,
                              Icons.pin_drop,
                              const Color(0xFFF44336),
                              isLast: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildDetailsSection(
                          title: AppStrings.getString(
                            'account_information',
                            langCode,
                          ),
                          sectionIcon: Icons.badge_outlined,
                          details: [
                            _buildDetailRow(
                              AppStrings.getString(
                                'registration_date',
                                langCode,
                              ),
                              createdAt,
                              Icons.calendar_today,
                              const Color(0xFF2196F3),
                              isLast: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar(BuildContext context, Farmer? farmer) {
    return SliverAppBar(
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
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
      title: const Text(
        'Profile Details',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              color: Colors.white,
              size: 20,
            ),
            tooltip: 'Edit Profile',
            onPressed: () => _navigateToEditProfile(context, farmer),
          ),
        ),
      ],
    );
  }

  void _navigateToEditProfile(BuildContext context, Farmer? farmer) {
    if (farmer != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FarmerDetailsForm(farmer: farmer),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Farmer details not available for editing.', overflow: TextOverflow.ellipsis,),
        ),
      );
    }
  }

  Widget _buildProfileHeader(String name, String langCode) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundColor: Colors.white.withOpacity(0.25),
              child: Text(
                name.isNotEmpty ? name.substring(0, 2).toUpperCase() : '',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Crops',
            '12',
            '',
            Icons.agriculture,
            const Color(0xFF2196F3),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Total Area',
            '45',
            'acres',
            Icons.area_chart,
            const Color(0xFFFF9800),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Verified Crops',
            '8',
            '',
            Icons.verified,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String unit,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              text: value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
              children: [
                TextSpan(
                  text: ' $unit',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildDetailsSection({
  //   required String title,
  //   required IconData sectionIcon,
  //   required List<Widget> details,
  // }) {
  //   return Container(
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(20),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.05),
  //           blurRadius: 15,
  //           offset: const Offset(0, 5),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Padding(
  //           padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
  //           child: Row(
  //             children: [
  //               Container(
  //                 padding: const EdgeInsets.all(8),
  //                 decoration: BoxDecoration(
  //                   color: const Color(0xFFE3F2FD),
  //                   borderRadius: BorderRadius.circular(10),
  //                 ),
  //                 child: Icon(
  //                   sectionIcon,
  //                   color: const Color(0xFF1976D2),
  //                   size: 20,
  //                 ),
  //               ),
  //               const SizedBox(width: 12),
  //               Text(
  //                 title,
  //                 style: TextStyle(
  //                   fontSize: 18,
  //                   fontWeight: FontWeight.w700,
  //                   color: Colors.grey[800],
  //                   overflow: TextOverflow.ellipsis,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         ...details,
  //       ],
  //     ),
  //   );
  // }
  Widget _buildDetailsSection({
    required String title,
    required IconData sectionIcon,
    required List<Widget> details,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive values based on screen width
        final bool isSmallScreen = constraints.maxWidth < 400;
        final double titleFontSize = isSmallScreen ? 16.0 : 18.0;
        final double iconSize = isSmallScreen ? 18.0 : 20.0;
        final double horizontalPadding = isSmallScreen ? 16.0 : 24.0;
        final double verticalPadding = isSmallScreen ? 16.0 : 24.0;
        final double iconPadding = isSmallScreen ? 6.0 : 8.0;
        final double iconBoxRadius = isSmallScreen ? 8.0 : 10.0;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  verticalPadding,
                  horizontalPadding,
                  verticalPadding * 0.66, // 16 if 24, ~10.6 if 16
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(iconPadding),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(iconBoxRadius),
                      ),
                      child: Icon(
                        sectionIcon,
                        color: const Color(0xFF1976D2),
                        size: iconSize,
                      ),
                    ),
                    SizedBox(width: isSmallScreen ? 8 : 12),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[800],
                          overflow: TextOverflow.ellipsis,
                        ),
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
              ...details,
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(
    String title,
    String value,
    IconData icon,
    Color color, {
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: Colors.grey[100]!, width: 1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF37474F),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Colors.black87,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _getRoleDisplayName(String role, String langCode) {
    switch (role) {
      case AppConstants.roleFarmer:
        return AppStrings.getString('farmer', langCode);
      default:
        return role;
    }
  }
}
