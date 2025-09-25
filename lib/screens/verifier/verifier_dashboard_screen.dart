import 'package:flutter/material.dart';
import 'package:smart_farmer/screens/auth/otp_verification_screen.dart';
import 'package:smart_farmer/screens/common/about_screen.dart';
import 'package:smart_farmer/screens/common/hepl_support_screen.dart';
import 'package:smart_farmer/screens/common/notifications_screen.dart';
import '../../constants/strings.dart';
import '../../services/shared_prefs_service.dart';
import '../../services/auth_service.dart';
import 'verifier_profile_screen.dart';
import '../search/search_screen.dart';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'verifier_crop_details_screen.dart';

class VerifierDashboardScreen extends StatefulWidget {
  const VerifierDashboardScreen({super.key});

  @override
  State<VerifierDashboardScreen> createState() =>
      _VerifierDashboardScreenState();
}

class _VerifierDashboardScreenState extends State<VerifierDashboardScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  Map<String, dynamic>? verifierData;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  bool _notificationsEnabled = true;
  List<dynamic> _verificationCrops = [];
  bool _isLoadingCrops = false;
  String? _cropsError;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _debugSharedPrefs(); // Debug what's in SharedPrefs
    _loadVerifierData(); // This will trigger crop loading after data is loaded
  }
  
  Future<void> _debugSharedPrefs() async {
    try {
      // Initialize SharedPrefs if not already done
      await SharedPrefsService.init();
      
      final prefs = await SharedPrefsService.getPrefs();
      final keys = prefs.getKeys();
      developer.log('All SharedPrefs keys: $keys', name: 'VerifierDashboard');
      
      for (String key in keys) {
        final value = prefs.get(key);
        developer.log('$key: $value', name: 'VerifierDashboard');
      }
      
      final userData = SharedPrefsService.getUserData();
      developer.log('getUserData result: $userData', name: 'VerifierDashboard');
      
      final userId = SharedPrefsService.getUserId();
      developer.log('getUserId result: $userId', name: 'VerifierDashboard');
      
      final userRole = SharedPrefsService.getUserRole();
      developer.log('getUserRole result: $userRole', name: 'VerifierDashboard');
      
      final isLoggedIn = SharedPrefsService.isLoggedIn();
      developer.log('isLoggedIn result: $isLoggedIn', name: 'VerifierDashboard');
    } catch (e) {
      developer.log('Debug SharedPrefs error: $e', name: 'VerifierDashboard');
    }
  }

  Future<void> _loadVerifierData() async {
    try {
      // Try multiple ways to get user data
      final userData = SharedPrefsService.getUserData();
      if (userData != null) {
        setState(() {
          verifierData = Map<String, dynamic>.from(userData);
        });
        developer.log('Verifier data loaded: $verifierData', name: 'VerifierDashboard');
        _fetchVerificationCrops();
        return;
      }
      
      // Fallback: try direct SharedPreferences access
      final prefs = await SharedPrefsService.getPrefs();
      final userDataString = prefs.getString('user_data');
      if (userDataString != null) {
        final decodedData = SharedPrefsService.decodeJson(userDataString);
        if (decodedData != null) {
          setState(() {
            verifierData = Map<String, dynamic>.from(decodedData);
          });
          developer.log('Verifier data loaded from fallback: $verifierData', name: 'VerifierDashboard');
          _fetchVerificationCrops();
          return;
        }
      }
      
      // If no data found, set empty data to stop loading
      developer.log('No verifier data found, setting empty data', name: 'VerifierDashboard');
      setState(() {
        verifierData = {
          '_id': '',
          'name': 'Verifier',
          'email': '',
          'contact': '',
          'aadhaarNumber': '',
          'age': 0,
          'village': '',
          'landMark': '',
          'taluka': '',
          'allocatedTaluka': [],
          'district': '',
          'state': '',
          'pincode': '',
          'role': 'verifier',
          'farmerId': [],
          'cropId': [],
          'talukaOfficerId': '',
          'createdAt': '',
          'updatedAt': '',
        };
      });
    } catch (e) {
      developer.log('Error loading verifier data: $e', name: 'VerifierDashboard');
      setState(() {
        verifierData = {
          '_id': '',
          'name': 'Verifier',
          'email': '',
          'contact': '',
          'aadhaarNumber': '',
          'age': 0,
          'village': '',
          'landMark': '',
          'taluka': '',
          'allocatedTaluka': [],
          'district': '',
          'state': '',
          'pincode': '',
          'role': 'verifier',
          'farmerId': [],
          'cropId': [],
          'talukaOfficerId': '',
          'createdAt': '',
          'updatedAt': '',
        };
      });
    }
  }

  Future<void> _fetchVerificationCrops() async {
    if (verifierData == null) return;
    
    final cropIdData = verifierData!['cropId'];
    if (cropIdData == null) return;

    setState(() {
      _isLoadingCrops = true;
      _cropsError = null;
    });

    try {
      List<String> cropIds = [];
      if (cropIdData is List) {
        cropIds = cropIdData.map((e) => e.toString()).toList();
      } else if (cropIdData is String) {
        cropIds = [cropIdData];
      }
      
      if (cropIds.isEmpty) {
        setState(() {
          _verificationCrops = [];
          _isLoadingCrops = false;
        });
        return;
      }

      final response = await http.post(
        Uri.parse(
          'https://smart-farmer-backend.vercel.app/api/crop/get-by-ids/',
        ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'ids': cropIds}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _verificationCrops = data['crops'] ?? [];
          _isLoadingCrops = false;
        });
      } else {
        setState(() {
          _cropsError = 'Failed to fetch crops: ${response.statusCode}';
          _isLoadingCrops = false;
        });
      }
    } catch (e) {
      setState(() {
        _cropsError = 'Error: $e';
        _isLoadingCrops = false;
      });
    }
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  PreferredSizeWidget _buildModernAppBar() {
    final displayName = verifierData?['name'] ?? '';
    final displayInitials = displayName.isNotEmpty
        ? displayName.substring(0, 2).toUpperCase()
        : '';
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
        child: const Icon(
          Icons.verified_user_rounded,
          color: Colors.white,
          size: 24,
        ),
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
              icon: _buildNavIcon(Icons.assignment_rounded, 1),
              label: 'Verifications',
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
    return SafeArea(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: verifierData == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    const Text('Loading verifier data...'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadVerifierData,
                      child: const Text('Retry'),
                    ),
                  ],
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeCard(),
                      const SizedBox(height: 32),
                      _buildStatsCards(),
                      const SizedBox(height: 32),
                      _buildSectionHeader(
                        'Quick Actions',
                        Icons.flash_on_rounded,
                      ),
                      const SizedBox(height: 16),
                      _buildModernQuickActions(),

                      const SizedBox(height: 32),
                      _buildSectionHeader(
                        'Recent Activity',
                        Icons.history_rounded,
                      ),
                      const SizedBox(height: 16),
                      _buildRecentActivity(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildVerificationsTab() {
    return SafeArea(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
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
              child: Row(
                children: [
                  const Icon(
                    Icons.assignment_rounded,
                    color: Color(0xFF2E7D32),
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'My Verifications',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Color(0xFF2E7D32)),
                    onPressed: _fetchVerificationCrops,
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoadingCrops && _verificationCrops.isEmpty
                  ? _buildSkeletonLoader()
                  : _cropsError != null && _verificationCrops.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading crops',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _cropsError!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _fetchVerificationCrops,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : _verificationCrops.isEmpty && !_isLoadingCrops
                  ? _buildEmptyState(
                      'No verifications assigned yet',
                      Icons.assignment_late_rounded,
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchVerificationCrops,
                      child: ListView.builder(
                        padding: const EdgeInsets.only(
                          bottom: 60,
                          left: 20,
                          right: 20,
                        ),
                        itemCount: _verificationCrops.length,
                        itemBuilder: (context, index) {
                          final crop = _verificationCrops[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: _buildVerificationCropCard(crop),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    final langCode = SharedPrefsService.getLanguage() ?? 'en';
    return SafeArea(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 32),
              _buildStatsCards(),
              const SizedBox(height: 32),
              _buildSectionHeader('Settings', Icons.settings_rounded),
              const SizedBox(height: 16),
              _buildSettingsList(),
              const SizedBox(height: 32),
              _buildLogoutButton(),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    final displayName = verifierData?['name'] ?? '';
    final displayDistrict = verifierData?['district'] ?? '';
    final displayTalukas =
        (verifierData?['allocatedTaluka'] as List?)?.join(', ') ?? '';

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
                Icons.verified_user_rounded,
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
                          displayDistrict,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (displayTalukas.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Talukas: $displayTalukas',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernQuickActions() {
    final actions = [
      {
        'icon': Icons.search_rounded,
        'title': 'Search Farmers',
        'color': const Color(0xFF2196F3),
        'gradient': [const Color(0xFF2196F3), const Color(0xFF1976D2)],
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SearchScreen()),
        ),
      },
      {
        'icon': Icons.location_on_rounded,
        'title': 'Field Verification',
        'color': const Color(0xFFFF9800),
        'gradient': [const Color(0xFFFF9800), const Color(0xFFF57C00)],
        'onTap': () {},
      },
      {
        'icon': Icons.assignment_rounded,
        'title': 'Pending Tasks',
        'color': const Color(0xFF4CAF50),
        'gradient': [const Color(0xFF4CAF50), const Color(0xFF2E7D32)],
        'onTap': () {},
      },
      {
        'icon': Icons.analytics_rounded,
        'title': 'Reports',
        'color': const Color(0xFF9C27B0),
        'gradient': [const Color(0xFF9C27B0), const Color(0xFF7B1FA2)],
        'onTap': () {},
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
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
  }

  Widget _buildModernActionCard(
    IconData icon,
    String title,
    List<Color> gradient,
    VoidCallback onTap,
  ) {
    return Container(
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
                Text(
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    final pendingCount = _verificationCrops
        .where((crop) => crop['applicationStatus'] == 'pending')
        .length;
    final completedCount = _verificationCrops
        .where((crop) => crop['applicationStatus'] == 'approved')
        .length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Pending \nVerifications',
            pendingCount.toString(),
            Icons.pending_actions_rounded,
            const Color(0xFF4CAF50),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Completed Verifications',
            completedCount.toString(),
            Icons.verified_rounded,
            const Color(0xFF2196F3),
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 60, left: 20, right: 20),
      itemCount: 5,
      itemBuilder: (context, index) => _buildSkeletonCard(),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.grey[300],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 18,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.grey[300],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 14,
                        width: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.grey[300],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 14,
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.grey[300],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 80,
                  height: 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[300],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 12,
              width: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.grey[300],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationCropCard(dynamic crop) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CropDetailsScreen(crop: crop)),
      ),
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                      ),
                    ),
                    child: crop['images'] != null && crop['images'].isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              crop['images'][0],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.eco_rounded,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                            ),
                          )
                        : const Icon(
                            Icons.eco_rounded,
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
                          crop['name'] ?? 'Unknown Crop',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Area: ${crop['area']?['value'] ?? 0} ${crop['area']?['unit'] ?? 'acre'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sowing: ${crop['sowingDate'] ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        crop['applicationStatus'],
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      crop['applicationStatus']?.toUpperCase() ?? 'PENDING',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(crop['applicationStatus']),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Lat: ${crop['latitude']?.toStringAsFixed(4) ?? 'N/A'}, Lng: ${crop['longitude']?.toStringAsFixed(4) ?? 'N/A'}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return const Color(0xFF4CAF50);
      case 'rejected':
        return const Color(0xFFFF5252);
      default:
        return const Color(0xFFFF9800);
    }
  }

  void _updateCropStatus(String cropId, String status) {
    setState(() {
      final cropIndex = _verificationCrops.indexWhere(
        (crop) => crop['_id'] == cropId,
      );
      if (cropIndex != -1) {
        _verificationCrops[cropIndex]['applicationStatus'] = status;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Crop ${status == 'approved' ? 'approved' : 'rejected'} successfully', overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: status == 'approved' ? Colors.green : Colors.red,
      ),
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
            textAlign: TextAlign.center,
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

  Widget _buildRecentActivity() {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildEmptyState('No recent activity', Icons.history_rounded),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final displayName = verifierData?['name'] ?? '';
    final displayContact = verifierData?['contact'] ?? '';
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
                      : 'V',
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                displayContact,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VerifierProfileScreen(
                          pending: _verificationCrops
                              .where(
                                (crop) =>
                                    crop['applicationStatus'] == 'pending',
                              )
                              .length,
                          verified: _verificationCrops
                              .where(
                                (crop) =>
                                    crop['applicationStatus'] == 'approved',
                              )
                              .length,
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
                          'View Profile',
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
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsList() {
    final langCode = SharedPrefsService.getLanguage() ?? 'en';
    String getLanguageDisplayName(String code) {
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
            getLanguageDisplayName(langCode),
            onTap: _showLanguageDialog,
          ),
          _buildDivider(),
          _buildSettingTile(
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

  Widget _buildEmptyState(String message, IconData icon) {
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
            child: Icon(icon, size: 40, color: Colors.grey[400]),
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

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 1,
      color: Colors.grey[200],
    );
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

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
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
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF2E7D32)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Logout',
              style: TextStyle(color: Color(0xFFD32F2F)),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MobileOTPScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final langCode = SharedPrefsService.getLanguage() ?? 'en';
    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      extendBodyBehindAppBar: true,
      appBar: _buildModernAppBar(),
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
          children: [
            _buildHomeTab(),
            _buildVerificationsTab(),
            _buildProfileTab(),
          ],
        ),
      ),
      bottomNavigationBar: _buildModernBottomNav(langCode),
    );
  }
}
