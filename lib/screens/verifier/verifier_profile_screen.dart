import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../constants/app_theme.dart';
import '../../services/shared_prefs_service.dart';

class VerifierProfileScreen extends StatefulWidget {
  final int pending;
  final int verified;
  const VerifierProfileScreen({super.key, required this.pending, required this.verified});

  @override
  State<VerifierProfileScreen> createState() => _VerifierProfileScreenState();
}

class _VerifierProfileScreenState extends State<VerifierProfileScreen> {
  Map<String, dynamic>? verifierData;

  @override
  void initState() {
    super.initState();
    _loadVerifierData();
  }

  Future<void> _loadVerifierData() async {
    try {
      await SharedPrefsService.init();
      final userData = SharedPrefsService.getUserData();
      if (userData != null) {
        setState(() {
          verifierData = Map<String, dynamic>.from(userData);
        });
      }
    } catch (e) {
      print('Error loading verifier data: $e');
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    } catch (e) {
      return dateString.split('T')[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (verifierData == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 24),
                  _buildQuickStats(),
                  const SizedBox(height: 24),
                  _buildDetailsSection(
                    title: 'Personal Information',
                    sectionIcon: Icons.person_outline,
                    details: [
                      _buildDetailRow(
                        'Name',
                        verifierData!['name'] ?? '',
                        Icons.person,
                        const Color(0xFF4CAF50),
                      ),
                      _buildDetailRow(
                        'Email',
                        verifierData!['email'] ?? '',
                        Icons.email,
                        const Color(0xFF2196F3),
                      ),
                      _buildDetailRow(
                        'Contact',
                        verifierData!['contact'] ?? '',
                        Icons.phone,
                        const Color(0xFFFF9800),
                      ),
                      _buildDetailRow(
                        'Aadhaar Number',
                        verifierData!['aadhaarNumber'] ?? '',
                        Icons.credit_card,
                        const Color(0xFFF44336),
                      ),
                      _buildDetailRow(
                        'Age',
                        verifierData!['age']?.toString() ?? '',
                        Icons.cake,
                        const Color(0xFF9C27B0),
                        isLast: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildDetailsSection(
                    title: 'Address Information',
                    sectionIcon: Icons.location_on_outlined,
                    details: [
                      _buildDetailRow(
                        'Village',
                        verifierData!['village'] ?? '',
                        Icons.location_city,
                        const Color(0xFF4CAF50),
                      ),
                      _buildDetailRow(
                        'Landmark',
                        verifierData!['landMark'] ?? '',
                        Icons.place,
                        const Color(0xFF2196F3),
                      ),
                      _buildDetailRow(
                        'Taluka',
                        verifierData!['taluka'] ?? '',
                        Icons.location_on,
                        const Color(0xFFFF9800),
                      ),
                      _buildDetailRow(
                        'District',
                        verifierData!['district'] ?? '',
                        Icons.location_on,
                        const Color(0xFFF44336),
                      ),
                      _buildDetailRow(
                        'State',
                        verifierData!['state'] ?? '',
                        Icons.map,
                        const Color(0xFF9C27B0),
                      ),
                      _buildDetailRow(
                        'Pincode',
                        verifierData!['pincode'] ?? '',
                        Icons.pin_drop,
                        const Color(0xFF607D8B),
                        isLast: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildDetailsSection(
                    title: 'Work Information',
                    sectionIcon: Icons.work_outline,
                    details: [
                      _buildDetailRow(
                        'Role',
                        verifierData!['role'] ?? '',
                        Icons.badge,
                        const Color(0xFF4CAF50),
                      ),
                      _buildDetailRow(
                        'Allocated Talukas',
                        (verifierData!['allocatedTaluka'] as List?)?.join(
                              ', ',
                            ) ??
                            '',
                        Icons.assignment,
                        const Color(0xFF2196F3),
                      ),
                      _buildDetailRow(
                        'Registration Date',
                        _formatDate(verifierData!['createdAt'] ?? ''),
                        Icons.calendar_today,
                        const Color(0xFFFF9800),
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
    );
  }

  Widget _buildSliverAppBar() {
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
        'Verifier Profile',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildProfileHeader() {
    final name = verifierData!['name'] ?? '';
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
                name.isNotEmpty ? name.substring(0, 2).toUpperCase() : 'V',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
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
                  const SizedBox(height: 4),
                  Text(
                    'Crop Verifier',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.8),
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

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Pending',
            widget.pending,
            '',
            Icons.pending_actions,
            const Color(0xFFFF9800),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Verified',
            widget.verified,
            '',
            Icons.verified,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Rejected',
            0,
            '',
            Icons.assignment,
            const Color.fromARGB(255, 247, 32, 32),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    int value,
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
              text: value.toString(),
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

  Widget _buildDetailsSection({
    required String title,
    required IconData sectionIcon,
    required List<Widget> details,
  }) {
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
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    sectionIcon,
                    color: const Color(0xFF1976D2),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[800],
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          ...details,
        ],
      ),
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
}
