import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_farmer/screens/auth/otp_verification_screen.dart';
import 'package:smart_farmer/screens/common/about_screen.dart';
import 'package:smart_farmer/screens/common/hepl_support_screen.dart';
import 'package:smart_farmer/screens/common/notifications_screen.dart';
import '../../blocs/farmer/farmer_bloc.dart';
import '../../blocs/farmer/farmer_event.dart';
import '../../blocs/farmer/farmer_state.dart';
import '../../blocs/crop/crop_bloc.dart';
import '../../blocs/crop/crop_event.dart';
import '../../blocs/crop/crop_state.dart';
import '../../constants/strings.dart';
import '../../services/shared_prefs_service.dart';
import '../search/search_screen.dart';
import '../filter/location_filter_screen.dart';
import 'edit_farmer_details.dart';
import 'crop_add_edit__form.dart';
import '../common/crop_detail_screen.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:smart_farmer/screens/common/profile_view_screen.dart';
import '../../models/farmer.dart';
import '../../constants/api_constants.dart';
import '../../utils/data_debug_helper.dart';

const String BASE_URL = DatabaseUrl.BASE_URL;

class FarmerDashboardScreen extends StatefulWidget {
  const FarmerDashboardScreen({super.key});

  @override
  State<FarmerDashboardScreen> createState() => _FarmerDashboardScreenState();
}

class _FarmerDashboardScreenState extends State<FarmerDashboardScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late AnimationController _animationController;
  late AnimationController _fabAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _fabScaleAnimation;

  Map<String, dynamic>? _profileData;

  bool _isCropsLoading = false;
  String? _cropsError;
  bool _notificationsEnabled = true;

  // Temporary in-memory cache for fetched crops
  List<dynamic> _fetchedCrops = [];

  Future<void> _fetchCropsFromApi({bool forceRefresh = false}) async {
    final farmerId = SharedPrefsService.getUserId();
    if (_fetchedCrops.isNotEmpty && !forceRefresh) return;
    setState(() {
      _isCropsLoading = true;
      _cropsError = null;
    });
    try {
      final url = Uri.parse('$BASE_URL/api/crop/by-farmer/$farmerId');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final cropsJson = data['crops'] as List<dynamic>?;
        if (cropsJson != null) {
          _fetchedCrops = cropsJson;
        } else {
          _fetchedCrops = [];
        }
      } else {
        _cropsError = 'Failed to fetch crops: ${response.statusCode}';
      }
    } catch (e) {
      _cropsError = 'Error: $e';
    } finally {
      setState(() {
        _isCropsLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      // Debug data sources in development
      await DataDebugHelper.debugAllDataSources();
      
      await _loadProfileData();
      await _loadFarmerData();
      await _fetchCropsFromApi();
      
      // Validate data consistency
      await DataDebugHelper.validateDataConsistency();
      
      if (mounted) {
        setState(() {}); // Force rebuild after all data is loaded
      }
    } catch (e) {
      developer.log('Error initializing data: $e');
      if (mounted) {
        setState(() {
          _cropsError = 'Failed to load data: $e';
        });
      }
    }
  }

  Future<void> _loadProfileData() async {
    try {
      // Try SharedPrefsService first
      final userData = SharedPrefsService.getUserData();
      if (userData != null) {
        if (mounted) {
          setState(() {
            _profileData = userData;
          });
        }
        developer.log("Profile data loaded from SharedPrefsService: $userData");
        return;
      }

      // Fallback to direct SharedPreferences access
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');
      if (userDataString != null && userDataString.isNotEmpty) {
        final decodedData = json.decode(userDataString) as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            _profileData = decodedData;
          });
        }
        developer.log("Profile data loaded from direct prefs: $decodedData");
      } else {
        developer.log('No profile data found in SharedPreferences');
        // Try to refresh from API if user ID exists
        final userId = SharedPrefsService.getUserId();
        if (userId != null && userId.isNotEmpty) {
          await _refreshProfileData();
        }
      }
    } catch (e) {
      developer.log('Error loading profile data: $e');
    }
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _fabScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _animationController.forward();
    _fabAnimationController.forward();
  }

  Future<void> _loadFarmerData() async {
    final userId = await SharedPrefsService.getUserIdAsync();
    developer.log(
      'Fetched userId from SharedPrefsService: $userId',
      name: 'FarmerDashboardScreen',
    );
    if (userId != null && userId.isNotEmpty) {
      developer.log(
        'Dispatching LoadFarmerProfile with userId: $userId',
        name: 'FarmerDashboardScreen',
      );
      context.read<FarmerBloc>().add(LoadFarmerProfile(userId));
      context.read<CropBloc>().add(LoadCropsByFarmer(userId));
    } else {
      developer.log(
        'No valid userId found. Farmer data will not be loaded.',
        name: 'FarmerDashboardScreen',
      );
    }
  }

  Future<void> _refreshProfileData() async {
    final userId = SharedPrefsService.getUserId();
    if (userId != null && userId.isNotEmpty) {
      try {
        // Fetch fresh data from API
        final response = await http.get(
          Uri.parse('$BASE_URL/api/farmer/$userId'),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          final newFarmerData = responseData['farmer'];

          // Update all storage systems
          await _updateAllDataSources(newFarmerData);

          // Update local profile data
          setState(() {
            _profileData = newFarmerData;
          });

          developer.log('Profile data refreshed successfully');
        } else {
          developer.log(
            'Failed to refresh profile data: ${response.statusCode}',
          );
        }
      } catch (e) {
        developer.log('Error refreshing profile data: $e');
      }
    }
  }

  Future<void> _updateAllDataSources(Map<String, dynamic> newData) async {
    try {
      // 1. Update SharedPreferences
      await SharedPrefsService.saveFarmerData(newData);

      // 2. Trigger BLoC state update for app-wide consistency
      if (mounted) {
        context.read<FarmerBloc>().add(
          RefreshFarmerProfile(newData['_id'] ?? newData['id'] ?? ''),
        );
      }
    } catch (e) {
      developer.log('Failed to update data sources: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fabAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  PreferredSizeWidget _buildModernAppBar({
    String name = '',
    String initials = '',
  }) {
    final displayName =
        _profileData != null && (_profileData!['name']?.isNotEmpty ?? false)
        ? _profileData!['name']
        : name;
    final displayInitials =
        _profileData != null && (_profileData!['name']?.isNotEmpty ?? false)
        ? _profileData!['name'].substring(0, 2).toUpperCase()
        : initials;
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
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
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: const Icon(Icons.eco, color: Colors.white, size: 24),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Welcome back,',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
            gradient: const LinearGradient(
              colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)],
            ),
          ),
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 20,
            child: Text(
              displayInitials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernBottomNav(String langCode) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() => _selectedIndex = index);
            _animationController.reset();
            _animationController.forward();
          },
          selectedItemColor: const Color(0xFF2E7D32),
          unselectedItemColor: Colors.grey[900],
          backgroundColor: Colors.white,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
          items: [
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.home_rounded, 0),
              label: AppStrings.getString('home', langCode),
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.agriculture_rounded, 1),
              label: AppStrings.getString('crops', langCode),
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.person_rounded, 2),
              label: AppStrings.getString('profile', langCode),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index) {
    final isSelected = _selectedIndex == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isSelected
            ? const Color(0xFF2E7D32).withOpacity(0.1)
            : Colors.transparent,
      ),
      child: Icon(
        icon,
        size: 24,
        color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[900],
      ),
    );
  }

  Widget _buildHomeTab() {
    final langCode = SharedPrefsService.getLanguage() ?? 'en';

    return SafeArea(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: BlocBuilder<FarmerBloc, FarmerState>(
            builder: (context, state) {
              // Get the most current farmer data
              Farmer? currentFarmer;
              if (state is SingleFarmerLoaded) {
                currentFarmer = state.farmer;
              } else if (state is FarmerLoaded && state.farmers.isNotEmpty) {
                currentFarmer = state.farmers.first;
              }

              // Merge data sources - BLoC state takes priority over cached data
              final displayName =
                  currentFarmer?.name ?? _profileData?['name'] ?? '';
              final displayVillage =
                  currentFarmer?.village ?? _profileData?['village'] ?? '';
              final displayDistrict =
                  currentFarmer?.district ?? _profileData?['district'] ?? '';

              return SingleChildScrollView(
                padding: const EdgeInsets.only(
                  top: 20,
                  left: 20,
                  right: 20,
                  bottom: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGlassWelcomeCard(
                      displayName: displayName,
                      displayVillage: displayVillage,
                      displayDistrict: displayDistrict,
                    ),
                    const SizedBox(height: 32),
                    _buildSectionHeader(
                      'Quick Actions',
                      Icons.flash_on_rounded,
                    ),
                    const SizedBox(height: 16),
                    _buildModernQuickActions(),
                    const SizedBox(height: 32),
                    _buildWeatherCard(),
                    const SizedBox(height: 32),
                    _buildSectionHeader(
                      'AI Insights',
                      Icons.psychology_rounded,
                    ),
                    const SizedBox(height: 16),
                    _buildAIInsights(),
                    const SizedBox(height: 32),
                    _buildSectionHeader('Recent Crops', Icons.grass_rounded),
                    const SizedBox(height: 16),
                    _buildRecentCrops(),
                    const SizedBox(height: 100),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Updated welcome card to use parameters
  Widget _buildGlassWelcomeCard({
    required String displayName,
    required String displayVillage,
    required String displayDistrict,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.9),
            Colors.white.withOpacity(0.7),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                ),
              ),
              child: const Icon(
                Icons.waving_hand_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good Morning!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 16,
                          color: Color(0xFF4CAF50),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$displayVillage, $displayDistrict',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCropsTab() {
    final langCode = SharedPrefsService.getLanguage() ?? 'en';

    return SafeArea(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            //  Header with Search
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFE8F5E8),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.agriculture_rounded,
                        color: Color(0xFF2E7D32),
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'My Crops',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                      Spacer(),
                      IconButton(
                        icon: const Icon(
                          Icons.refresh,
                          color: Color(0xFF2E7D32),
                        ),
                        onPressed: () async {
                          _fetchedCrops.clear();
                          await _fetchCropsFromApi(forceRefresh: true);
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Crops List
            Expanded(
              child: _isCropsLoading
                  ? Center(child: CircularProgressIndicator())
                  : _cropsError != null
                  ? Center(child: Text(_cropsError!))
                  : (_fetchedCrops.isNotEmpty
                        ? ListView.builder(
                            padding: const EdgeInsets.only(
                              bottom: 60,
                              left: 20,
                              right: 20,
                            ),
                            itemCount: _fetchedCrops.length,
                            itemBuilder: (context, index) {
                              final crop = _fetchedCrops[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                child: _buildCropListCard(crop),
                              );
                            },
                          )
                        : _buildEmptyCropsState(langCode)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCropListCard(dynamic crop) {
    return InkWell(
      onTap: () {
        developer.log("$crop");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CropDetailScreen(crop: crop)),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.grey[50]!],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                child:
                    crop['images'] != null &&
                        crop['images'] is List &&
                        crop['images'].isNotEmpty &&
                        crop['images'][0] != null &&
                        crop['images'][0].toString().isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          crop['images'][0],
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                                size: 24,
                              ),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                          ),
                        ),
                        child: const Icon(
                          Icons.eco_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            crop['name'] ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E20),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Area: ${crop['area']?['value'] ?? ''} ${crop['area']?['unit'] ?? ''}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Planted: ${crop['sowingDate'] ?? "N/A"}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2196F3).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Healthy',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF1976D2),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 12,
                            color: Color(0xFF4CAF50),
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

  Widget _buildProfileTab() {
    final langCode = SharedPrefsService.getLanguage() ?? 'en';

    return SafeArea(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: RefreshIndicator(
          onRefresh: _refreshProfileData,
          color: const Color(0xFF4CAF50),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //  Profile Header
                _buildProfileHeader(),
                const SizedBox(height: 32),

                // Stats Cards
                _buildStatsCards(),
                const SizedBox(height: 32),

                // Settings Section
                _buildSectionHeader('Settings', Icons.settings_rounded),
                const SizedBox(height: 16),
                _buildSettingsList(),
                const SizedBox(height: 32),

                // Logout Button
                _buildLogoutButton(),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return BlocBuilder<FarmerBloc, FarmerState>(
      builder: (context, state) {
        String displayName = '';
        String displayAadhaar = '';

        // Priority: BLoC state first, then local storage
        if (state is SingleFarmerLoaded) {
          displayName = state.farmer.name;
          displayAadhaar = state.farmer.aadhaarNumber;
        } else if (_profileData != null) {
          displayName = _profileData!['name'] ?? '';
          // Check multiple possible field names for aadhaar
          displayAadhaar =
              _profileData!['aadhaarNumber'] ??
              _profileData!['aadhaar_number'] ??
              _profileData!['aadharNumber'] ??
              '';
        }
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4CAF50).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.white.withOpacity(0.2),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      displayName.isNotEmpty
                          ? displayName.substring(0, 2).toUpperCase()
                          : 'Loading...',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    displayAadhaar,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              final userId =
                                  SharedPrefsService.getUserId() ?? '';
                              final userRole =
                                  SharedPrefsService.getUserRole() ?? '';
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProfileViewScreen(
                                    userId: userId,
                                    userRole: userRole,
                                    onBack: () {
                                      // Switch to profile tab when back from ProfileViewScreen
                                      setState(() {
                                        _selectedIndex = 2;
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.visibility_rounded,
                                    color: Color(0xFF2E7D32),
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'View',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF2E7D32),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // const SizedBox(width: 12),
                    // Expanded(
                    //   child: Container(
                    //     decoration: BoxDecoration(
                    //       color: Colors.white.withOpacity(0.2),
                    //       borderRadius: BorderRadius.circular(16),
                    //       border: Border.all(
                    //         color: Colors.white.withOpacity(0.3),
                    //         width: 1,
                    //       ),
                    //     ),
                    //     child: Material(
                    //       color: Colors.transparent,
                    //       child: InkWell(
                    //         onTap: _navigateToProfileForm,
                    //         borderRadius: BorderRadius.circular(16),
                    //         child: const Padding(
                    //           padding: EdgeInsets.symmetric(vertical: 16),
                    //           child: Row(
                    //             mainAxisAlignment: MainAxisAlignment.center,
                    //             children: [
                    //               Icon(
                    //                 Icons.edit_outlined,
                    //                 color: Colors.white,
                    //                 size: 20,
                    //               ),
                    //               SizedBox(width: 8),
                    //               Text(
                    //                 'Edit',
                    //                 style: TextStyle(
                    //                   fontSize: 16,
                    //                   color: Colors.white,
                    //                   fontWeight: FontWeight.w600,
                    //                 ),
                    //               ),
                    //             ],
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Crops',
            '12',
            Icons.agriculture_rounded,
            const Color(0xFF4CAF50),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Total Area',
            '45 acres',
            Icons.landscape_rounded,
            const Color(0xFF2196F3),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsList() {
    final langCode = SharedPrefsService.getLanguage() ?? 'en';

    String _getLanguageDisplayName(String code) {
      switch (code) {
        case 'en':
          return 'English';
        case 'hi':
          return 'हिन्दी';
        case 'mr':
          return 'मराठी';
        default:
          return code;
      }
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingTile(
            Icons.language_rounded,
            AppStrings.getString('language', langCode),
            _getLanguageDisplayName(langCode),
            onTap: _showLanguageDialog,
          ),
          _buildDivider(),
          GestureDetector(
            onTap: () {
              setState(() {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => NotificationScreen()),
                );
              });
            },
            child: _buildSettingTile(
              Icons.notifications_rounded,
              AppStrings.getString('notifications', langCode),
              null,
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
                activeColor: const Color(0xFF4CAF50),
              ),
            ),
          ),
          _buildDivider(),
          _buildSettingTile(
            Icons.help_rounded,
            AppStrings.getString('help_support', langCode),
            null,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HelpSupportScreen(),
                ),
              );
            },
          ),
          _buildDivider(),
          _buildSettingTile(
            Icons.info_rounded,
            AppStrings.getString('about', langCode),
            null,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    IconData icon,
    String title,
    String? subtitle, {
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF4CAF50), size: 20),
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
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
              ),
              trailing ??
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Colors.grey,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 1,
      color: Colors.grey[200],
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFFF5252), Color(0xFFD32F2F)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF5252).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleLogout,
          borderRadius: BorderRadius.circular(20),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper Widgets
  Widget _buildLoadingCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Loading indicator
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                const Color(0xFF4CAF50),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Message text
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 40,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCropsState(String langCode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF4CAF50).withOpacity(0.1),
                  const Color(0xFF2E7D32).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.agriculture_rounded,
              size: 60,
              color: Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            AppStrings.getString('no_crops_found', langCode),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start your farming journey by adding your first crop',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
              ),
            ),
            child: ElevatedButton.icon(
              onPressed: () => _navigateToCropForm(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: Text(
                AppStrings.getString('add_first_crop', langCode),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF2E7D32), size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B5E20),
          ),
        ),
      ],
    );
  }

  Widget _buildModernQuickActions() {
    final langCode = SharedPrefsService.getLanguage() ?? 'en';

    final actions = [
      {
        'icon': Icons.add_circle_outline_rounded,
        'title': AppStrings.getString('add_crop', langCode),
        'color': const Color(0xFF4CAF50),
        'gradient': [const Color(0xFF4CAF50), const Color(0xFF2E7D32)],
        'onTap': () => _navigateToCropForm(),
      },
      {
        'icon': Icons.search_rounded,
        'title': AppStrings.getString('search_crops', langCode),
        'color': const Color(0xFF2196F3),
        'gradient': [const Color(0xFF2196F3), const Color(0xFF1976D2)],
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SearchScreen()),
        ),
      },
      {
        'icon': Icons.location_on_rounded,
        'title': AppStrings.getString('filter_by_location', langCode),
        'color': const Color(0xFFFF9800),
        'gradient': [const Color(0xFFFF9800), const Color(0xFFF57C00)],
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LocationFilterScreen()),
        ),
      },
      {
        'icon': Icons.analytics_rounded,
        'title': AppStrings.getString('view_reports', langCode),
        'color': const Color(0xFF9C27B0),
        'gradient': [const Color(0xFF9C27B0), const Color(0xFF7B1FA2)],
        'onTap': () {},
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive dimensions
        final isSmallScreen = constraints.maxWidth < 400;
        final crossAxisCount = isSmallScreen ? 2 : 4;
        final childAspectRatio = isSmallScreen ? 1.0 : 0.9;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return _buildModernActionCard(
              action['icon'] as IconData,
              action['title'] as String,
              action['gradient'] as List<Color>,
              action['onTap'] as VoidCallback,
            );
          },
        );
      },
    );
  }

  Widget _buildModernActionCard(
    IconData icon,
    String title,
    List<Color> gradient,
    VoidCallback onTap,
  ) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 100, // Ensure minimum height
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.grey[50]!],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(colors: gradient),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B5E20),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2196F3).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Today\'s Weather',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '28°C',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Perfect for farming',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.wb_sunny_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIInsights() {
    final langCode = SharedPrefsService.getLanguage() ?? 'en';

    return BlocBuilder<CropBloc, CropState>(
      builder: (context, state) {
        if (state is CropLoaded && state.crops.isNotEmpty) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final isSmallScreen = constraints.maxWidth < 350;

              return Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 120),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF9C27B0).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.psychology_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'AI Recommendation',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Powered by Machine Learning',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Based on weather patterns and soil conditions, consider planting drought-resistant crops this season. Expected yield increase: 15%',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isSmallScreen ? 12 : 14,
                            height: 1.4,
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
        return _buildLoadingCard(
          AppStrings.getString('no_crops_for_insights', langCode),
        );
      },
    );
  }

  Widget _buildRecentCrops() {
    final langCode = SharedPrefsService.getLanguage() ?? 'en';

    return BlocBuilder<CropBloc, CropState>(
      builder: (context, state) {
        if (state is CropLoaded && state.crops.isNotEmpty) {
          final filteredCrops = state.crops.where((crop) {
            return crop.cropName.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );
          }).toList();

          if (filteredCrops.isEmpty) {
            return _buildEmptyState(
              AppStrings.getString('no_crops_found', langCode),
            );
          }

          return SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 4),
              itemCount: filteredCrops.take(5).length,
              itemBuilder: (context, index) {
                final crop = filteredCrops[index];
                return Container(
                  width: 300,
                  margin: const EdgeInsets.only(right: 16),
                  child: _buildModernCropCard(crop),
                );
              },
            ),
          );
        }
        return _buildEmptyState(
          AppStrings.getString('no_crops_found', langCode),
        );
      },
    );
  }

  Widget _buildModernCropCard(dynamic crop) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.grey[50]!],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                    ),
                  ),
                  child: const Icon(
                    Icons.eco_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        crop.cropName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Area: ${crop.area} acres',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Planted: ${crop.sowingDate != null ? crop.sowingDate.toString().split(' ')[0] : "N/A"}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2196F3).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Healthy',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF1976D2),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Navigation Methods
  void _navigateToCropForm() {
    final userId = SharedPrefsService.getUserId();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CropDetailsForm(farmerId: userId ?? ''),
      ),
    ).then((result) {
      if (result != null) {
        // _addLocalCrop(result);
      }
    });
  }

  void _navigateToProfileForm() {
    final state = context.read<FarmerBloc>().state;

    // Try to get farmer from BLoC state first
    if (state is SingleFarmerLoaded) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FarmerDetailsForm(farmer: state.farmer),
        ),
      );
    } else if (state is FarmerLoaded && state.farmers.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FarmerDetailsForm(farmer: state.farmers.first),
        ),
      );
    } else if (_profileData != null) {
      // Convert profile data to Farmer object if BLoC data is not available
      final farmer = _createFarmerFromProfileData();
      if (farmer != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FarmerDetailsForm(farmer: farmer),
          ),
        );
      } else {
        _showProfileDataError();
      }
    } else if (state is FarmerLoading) {
      // Show loading indicator while waiting for data
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Farmer data is not loaded yet. Please try again later.',
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }
  }

  void _showLanguageDialog() {
    final langCode = SharedPrefsService.getLanguage() ?? 'en';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Select Language',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B5E20),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('English', 'en', langCode),
            const SizedBox(height: 8),
            _buildLanguageOption('हिंदी', 'hi', langCode),
            const SizedBox(height: 8),
            _buildLanguageOption('मराठी', 'mr', langCode),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String title, String value, String currentLang) {
    final isSelected = currentLang == value;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isSelected
            ? const Color(0xFF4CAF50).withOpacity(0.1)
            : Colors.transparent,
      ),
      child: RadioListTile<String>(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[700],
          ),
        ),
        value: value,
        groupValue: currentLang,
        activeColor: const Color(0xFF4CAF50),
        onChanged: (newValue) {
          if (newValue != null) {
            SharedPrefsService.setLanguage(newValue);
            Navigator.pop(context);
            setState(() {});
          }
        },
      ),
    );
  }

  // Helper method to create Farmer object from profile data
  Farmer? _createFarmerFromProfileData() {
    if (_profileData == null) return null;

    try {
      return Farmer(
        id: _profileData!['_id'] ?? _profileData!['id'] ?? '',
        name: _profileData!['name'] ?? '',
        contactNumber:
            _profileData!['contactNumber'] ??
            _profileData!['contact_number'] ??
            '',
        aadhaarNumber:
            _profileData!['aadhaarNumber'] ??
            _profileData!['aadhaar_number'] ??
            _profileData!['aadharNumber'] ??
            '',
        village: _profileData!['village'] ?? '',
        landmark: _profileData!['landmark'] ?? '',
        taluka: _profileData!['taluka'] ?? '',
        district: _profileData!['district'] ?? '',
        pincode: _profileData!['pincode'] ?? '',
        createdAt: _parseDateTime(
          _profileData!['createdAt'] ?? _profileData!['created_at'],
        ),
        updatedAt: _parseDateTime(
          _profileData!['updatedAt'] ?? _profileData!['updated_at'],
        ),
      );
    } catch (e) {
      developer.log('Error creating farmer from profile data: $e');
      return null;
    }
  }

  DateTime _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();
    if (dateValue is DateTime) return dateValue;
    if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  void _showProfileDataError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Unable to load profile data for editing. Please try refreshing.',
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Logout',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B5E20),
          ),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF2E7D32)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              SharedPrefsService.clearAll();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const MobileOTPScreen(),
                ),
                (route) => false,
              );
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Color(0xFFD32F2F)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final langCode = SharedPrefsService.getLanguage() ?? 'en';
    return BlocListener<FarmerBloc, FarmerState>(
      listener: (context, state) {
        if (state is SingleFarmerLoaded) {
          // Update profile data when farmer is loaded from BLoC
          if (mounted) {
            setState(() {
              _profileData = state.farmer.toMap();
            });
          }
        } else if (state is FarmerError) {
          developer.log('Farmer BLoC error: ${state.message}');
        }
      },
      child: BlocBuilder<FarmerBloc, FarmerState>(
        builder: (context, state) {
          String name = '';
          String initials = '';
          if (state is SingleFarmerLoaded) {
            name = state.farmer.name;
            initials = name.isNotEmpty ? name.substring(0, 2).toUpperCase() : '';
          }
          return Scaffold(
          backgroundColor: const Color(0xFFF8FFFE),
          extendBodyBehindAppBar: true,
          appBar: _buildModernAppBar(name: name, initials: initials),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFE8F5E8), Color(0xFFF8FFFE)],
              ),
            ),
            child: IndexedStack(
              index: _selectedIndex,
              children: [_buildHomeTab(), _buildCropsTab(), _buildProfileTab()],
            ),
          ),
          bottomNavigationBar: _buildModernBottomNav(langCode),
          floatingActionButton: _selectedIndex == 1
              ? ScaleTransition(
                  scale: _fabScaleAnimation,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: FloatingActionButton.extended(
                      onPressed: () => _navigateToCropForm(),
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        'Add Crop',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                )
              : null,
        );
        },
      ),
    );
  }
}
