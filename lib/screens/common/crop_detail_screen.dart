import 'package:flutter/material.dart';
import '../farmer/crop_add_edit__form.dart';
import '../../data/crop_data.dart';
import '../../models/crop.dart';

class CropDetailScreen extends StatelessWidget {
  final dynamic crop;
  const CropDetailScreen({Key? key, required this.crop}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Helper to get images list from crop (map or model)
    List<dynamic> images = [];
    if (crop is Map && crop['images'] != null && crop['images'] is List) {
      images = crop['images'];
    } else if (crop.imagePaths != null) {
      images = crop.imagePaths;
    }

    // Helper to check if rejected reason exists
    bool hasRejectedReason() {
      if (crop is Map) {
        return crop['rejectedReason'] != null &&
            crop['rejectedReason'].toString().isNotEmpty;
      } else {
        return crop.rejectedReason != null &&
            crop.rejectedReason.toString().isNotEmpty;
      }
    }

    // Helper getters for all fields
    String getCropName() => crop is Map
        ? (crop['name'] ?? 'Unknown Crop')
        : (crop.name ?? 'Unknown Crop');
    String getArea() => crop is Map
        ? (crop['area'] != null
              ? '${crop['area']['value'] ?? '-'} ${crop['area']['unit'] ?? ''}'
              : 'Not specified')
        : (crop.area != null
              ? '${crop.area.value ?? '-'} ${crop.area.unit ?? ''}'
              : 'Not specified');
    String getSowingDate() => crop is Map
        ? (crop['sowingDate'] ?? 'Not specified')
        : (crop.sowingDate ?? 'Not specified');
    String getExpectedFirstHarvestDate() => crop is Map
        ? (crop['expectedFirstHarvestDate'] != null
              ? _formatDate(crop['expectedFirstHarvestDate'])
              : 'Not specified')
        : (crop.expectedFirstHarvestDate != null
              ? _formatDate(crop.expectedFirstHarvestDate.toString())
              : 'Not specified');
    String getExpectedLastHarvestDate() => crop is Map
        ? (crop['expectedLastHarvestDate'] != null
              ? _formatDate(crop['expectedLastHarvestDate'])
              : 'Not specified')
        : (crop.expectedLastHarvestDate != null
              ? _formatDate(crop.expectedLastHarvestDate.toString())
              : 'Not specified');
    String getExpectedHarvestDate() => crop is Map
        ? (crop['expectedHarvestDate'] ?? 'Not specified')
        : (crop.expectedHarvestDate ?? 'Not specified');
    String getExpectedYield() => crop is Map
        ? (crop['expectedYield'] != null
              ? '${crop['expectedYield']} tons'
              : 'Not specified')
        : (crop.expectedYield != null
              ? '${crop.expectedYield} tons'
              : 'Not specified');
    String getPreviousCrop() => crop is Map
        ? (crop['previousCrop'] ?? 'None')
        : (crop.previousCrop ?? 'None');
    String getLatitude() => crop is Map
        ? (crop['latitude']?.toString() ?? '-')
        : (crop.latitude?.toString() ?? '-');
    String getLongitude() => crop is Map
        ? (crop['longitude']?.toString() ?? '-')
        : (crop.longitude?.toString() ?? '-');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Crop Header Card
                  _buildCropHeader(),
                  const SizedBox(height: 24),

                  // Quick Stats Cards
                  _buildQuickStats(),
                  const SizedBox(height: 24),

                  // Rejected Reason Section - Only show if rejected reason exists
                  if (hasRejectedReason()) ...[
                    _buildRejectedReasonSection(),
                    const SizedBox(height: 24),
                  ],

                  // Main Details Section
                  _buildMainDetailsSection(),
                  const SizedBox(height: 24),

                  // Location Section
                  _buildLocationSection(),
                  const SizedBox(height: 24),

                  // Images Section
                  if (images.isNotEmpty) _buildImagesSection(context, images),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    } catch (e) {
      return dateString.split('T')[0];
    }
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      // expandedHeight: 120,
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
        'Crop Details',
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
            tooltip: 'Edit Crop',
            onPressed: () => _handleEditCrop(context),
          ),
        ),
      ],
    );
  }

  Widget _buildCropHeader() {
    final cropName = crop is Map
        ? (crop['name'] ?? 'Unknown Crop')
        : (crop.name ?? 'Unknown Crop');

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 20),
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
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white.withOpacity(0.25),
              ),
              child: const Icon(
                Icons.eco_outlined,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cropName,
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      crop['applicationStatus'],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
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
    // Area extraction
    final areaValue = crop is Map
        ? (crop['area'] != null ? '${crop['area']['value'] ?? '0'}' : '0')
        : (crop.area != null ? '${crop.area.value ?? '0'}' : '0');
    final areaUnit = crop is Map
        ? (crop['area'] != null ? '${crop['area']['unit'] ?? ''}' : '')
        : (crop.area != null ? '${crop.area.unit ?? ''}' : '');

    // Expected Yield extraction
    final yieldValue = crop is Map
        ? (crop['expectedYield'] != null
              ? '${crop['expectedYield']['value'] ?? '0'}'
              : '0')
        : (crop.expectedYield != null
              ? '${crop.expectedYield.value ?? '0'}'
              : '0');
    final yieldUnit = crop is Map
        ? (crop['expectedYield'] != null
              ? '${crop['expectedYield']['unit'] ?? ''}'
              : '')
        : (crop.expectedYield != null
              ? '${crop.expectedYield.unit ?? ''}'
              : '');

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Area',
            areaValue,
            areaUnit,
            Icons.landscape_outlined,
            const Color(0xFF2196F3),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Expected Yield',
            yieldValue,
            yieldUnit.isNotEmpty
                ? yieldUnit
                : 'units', // fallback to 'units' if empty
            Icons.trending_up_outlined,
            const Color(0xFFFF9800),
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
                    fontSize: 14,
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

  Widget _buildMainDetailsSection() {
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
            child: Text(
              'Crop Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
              ),
            ),
          ),
          _buildDetailRow(
            'Sowing Date',
            crop is Map
                ? (crop['sowingDate'] ?? 'Not specified')
                : (crop.sowingDate ?? 'Not specified'),
            Icons.calendar_today_outlined,
            const Color(0xFF4CAF50),
          ),
          _buildDetailRow(
            'Expected Harvest Start',
            crop is Map
                ? (crop['expectedFirstHarvestDate'] != null
                      ? _formatDate(crop['expectedFirstHarvestDate'])
                      : 'Not specified')
                : (crop.expectedFirstHarvestDate != null
                      ? _formatDate(crop.expectedFirstHarvestDate.toString())
                      : 'Not specified'),
            Icons.event_available_outlined,
            const Color(0xFFFF9800),
          ),
          _buildDetailRow(
            'Expected Harvest End',
            crop is Map
                ? (crop['expectedLastHarvestDate'] != null
                      ? _formatDate(crop['expectedLastHarvestDate'])
                      : 'Not specified')
                : (crop.expectedLastHarvestDate != null
                      ? _formatDate(crop.expectedLastHarvestDate.toString())
                      : 'Not specified'),
            Icons.event_busy_outlined,
            const Color(0xFFF44336),
          ),
          _buildDetailRow(
            'Previous Crop',
            crop is Map
                ? (crop['previousCrop'] ?? 'None')
                : (crop.previousCrop ?? 'None'),
            Icons.history_outlined,
            const Color(0xFF9C27B0),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildRejectedReasonSection() {
    // Helper to get rejected reason
    String getRejectedReason() {
      if (crop is Map) {
        return crop['rejectedReason'] ?? 'No reason provided';
      } else {
        return crop.rejectedReason ?? 'No reason provided';
      }
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.red[300],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rejected Reason',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              getRejectedReason(),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    final lat = crop is Map
        ? (crop['latitude']?.toString() ?? '0')
        : (crop.latitude?.toString() ?? '0');
    final lng = crop is Map
        ? (crop['longitude']?.toString() ?? '0')
        : (crop.longitude?.toString() ?? '0');

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
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.location_on_outlined,
                    color: Color(0xFF1976D2),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Location',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Latitude',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lat,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 40, color: Colors.grey[300]),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Longitude',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lng,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
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

  Widget _buildImagesSection(BuildContext context, List<dynamic> images) {
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
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.photo_library_outlined,
                    color: Color(0xFF2E7D32),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Crop Images',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Colors.grey[800],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${images.length} photos',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final imgUrl = images[index];
                  return GestureDetector(
                    onTap: () => _showImageGallery(context, images, index),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          imgUrl,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 120,
                                height: 120,
                                color: Colors.grey[200],
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.broken_image_outlined,
                                      color: Colors.grey[400],
                                      size: 32,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Failed to load',
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // New: Gallery dialog with PageView
  void _showImageGallery(
    BuildContext context,
    List<dynamic> images,
    int initialIndex,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        PageController controller = PageController(initialPage: initialIndex);
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: 320,
                  height: 320,
                  child: PageView.builder(
                    controller: controller,
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      final imgUrl = images[index];
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          imgUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 300,
                                height: 300,
                                color: Colors.grey[100],
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.broken_image_outlined,
                                      color: Colors.grey[400],
                                      size: 48,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Failed to load image',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleEditCrop(BuildContext context) async {
    final updatedCropData = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CropDetailsForm(
          crop: crop is Map ? Crop.fromApiJson(crop) : crop,
          farmerId: crop is Map ? crop['farmerId'] : crop.farmerId,
        ),
      ),
    );

    if (updatedCropData != null) {
      // The edit form returned new data. Refresh the detail screen.
      Navigator.of(context).pop(); // Close the current detail screen.
      Navigator.of(context).push(
        // Open a new one with the updated data.
        MaterialPageRoute(
          builder: (context) => CropDetailScreen(crop: updatedCropData),
        ),
      );
    }
  }
}




// import 'package:flutter/material.dart';
// import '../farmer/crop_add_edit__form.dart';
// import '../../data/crop_data.dart';
// import '../../models/crop.dart';

// class CropDetailScreen extends StatelessWidget {
//   final dynamic crop;
//   const CropDetailScreen({Key? key, required this.crop}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // Helper to get images list from crop (map or model)
//     List<dynamic> images = [];
//     if (crop is Map && crop['images'] != null && crop['images'] is List) {
//       images = crop['images'];
//     } else if (crop.imagePaths != null) {
//       images = crop.imagePaths;
//     }

//     // Helper getters for all fields
//     String getCropName() => crop is Map
//         ? (crop['name'] ?? 'Unknown Crop')
//         : (crop.name ?? 'Unknown Crop');
//     String getArea() => crop is Map
//         ? (crop['area'] != null
//               ? '${crop['area']['value'] ?? '-'} ${crop['area']['unit'] ?? ''}'
//               : 'Not specified')
//         : (crop.area != null
//               ? '${crop.area.value ?? '-'} ${crop.area.unit ?? ''}'
//               : 'Not specified');
//     String getSowingDate() => crop is Map
//         ? (crop['sowingDate'] ?? 'Not specified')
//         : (crop.sowingDate ?? 'Not specified');
//     String getExpectedFirstHarvestDate() => crop is Map
//         ? (crop['expectedFirstHarvestDate'] != null
//               ? _formatDate(crop['expectedFirstHarvestDate'])
//               : 'Not specified')
//         : (crop.expectedFirstHarvestDate != null
//               ? _formatDate(crop.expectedFirstHarvestDate.toString())
//               : 'Not specified');
//     String getExpectedLastHarvestDate() => crop is Map
//         ? (crop['expectedLastHarvestDate'] != null
//               ? _formatDate(crop['expectedLastHarvestDate'])
//               : 'Not specified')
//         : (crop.expectedLastHarvestDate != null
//               ? _formatDate(crop.expectedLastHarvestDate.toString())
//               : 'Not specified');
//     String getExpectedHarvestDate() => crop is Map
//         ? (crop['expectedHarvestDate'] ?? 'Not specified')
//         : (crop.expectedHarvestDate ?? 'Not specified');
//     String getExpectedYield() => crop is Map
//         ? (crop['expectedYield'] != null
//               ? '${crop['expectedYield']} tons'
//               : 'Not specified')
//         : (crop.expectedYield != null
//               ? '${crop.expectedYield} tons'
//               : 'Not specified');
//     String getPreviousCrop() => crop is Map
//         ? (crop['previousCrop'] ?? 'None')
//         : (crop.previousCrop ?? 'None');
//     String getLatitude() => crop is Map
//         ? (crop['latitude']?.toString() ?? '-')
//         : (crop.latitude?.toString() ?? '-');
//     String getLongitude() => crop is Map
//         ? (crop['longitude']?.toString() ?? '-')
//         : (crop.longitude?.toString() ?? '-');

//     return Scaffold(
//       backgroundColor: const Color(0xFFF8FFFE),
//       body: CustomScrollView(
//         slivers: [
//           _buildSliverAppBar(context),
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Crop Header Card
//                   _buildCropHeader(),
//                   const SizedBox(height: 24),

//                   Text(crop['rejectedReason']),
//                   const SizedBox(height: 24),

//                   // Quick Stats Cards
//                   _buildQuickStats(),
//                   const SizedBox(height: 24),

//                   // Rejected Reason Section
//                   _buildRejectedReasonSection(),
//                   const SizedBox(height: 24),

//                   // Main Details Section
//                   _buildMainDetailsSection(),
//                   const SizedBox(height: 24),

//                   // Location Section
//                   _buildLocationSection(),
//                   const SizedBox(height: 24),

//                   // Images Section
//                   if (images.isNotEmpty) _buildImagesSection(context, images),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatDate(String dateString) {
//     try {
//       final date = DateTime.parse(dateString);
//       return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
//     } catch (e) {
//       return dateString.split('T')[0];
//     }
//   }

//   Widget _buildSliverAppBar(BuildContext context) {
//     return SliverAppBar(
//       // expandedHeight: 120,
//       floating: false,
//       pinned: true,
//       elevation: 0,
//       backgroundColor: Colors.transparent,
//       flexibleSpace: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//       ),
//       leading: Container(
//         margin: const EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           color: Colors.white.withOpacity(0.2),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: IconButton(
//           icon: const Icon(
//             Icons.arrow_back_ios_new,
//             color: Colors.white,
//             size: 20,
//           ),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//       ),
//       title: const Text(
//         'Crop Details',
//         style: TextStyle(
//           color: Colors.white,
//           fontWeight: FontWeight.w600,
//           fontSize: 20,
//         ),
//       ),
//       centerTitle: true,
//       actions: [
//         Container(
//           margin: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.2),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: IconButton(
//             icon: const Icon(
//               Icons.edit_outlined,
//               color: Colors.white,
//               size: 20,
//             ),
//             tooltip: 'Edit Crop',
//             onPressed: () => _handleEditCrop(context),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildCropHeader() {
//     final cropName = crop is Map
//         ? (crop['name'] ?? 'Unknown Crop')
//         : (crop.name ?? 'Unknown Crop');

//     return Container(
//       width: double.infinity,
//       margin: EdgeInsets.only(top: 20),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(20),
//         gradient: const LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)],
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: const Color(0xFF4CAF50).withOpacity(0.3),
//             blurRadius: 15,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Row(
//           children: [
//             Container(
//               width: 70,
//               height: 70,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(20),
//                 color: Colors.white.withOpacity(0.25),
//               ),
//               child: const Icon(
//                 Icons.eco_outlined,
//                 color: Colors.white,
//                 size: 32,
//               ),
//             ),
//             const SizedBox(width: 20),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     cropName,
//                     style: const TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.w700,
//                       color: Colors.white,
//                       letterSpacing: -0.5,
//                     ),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   const SizedBox(height: 4),
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 4,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       crop['applicationStatus'],
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 12,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildQuickStats() {
//     // Area extraction
//     final areaValue = crop is Map
//         ? (crop['area'] != null ? '${crop['area']['value'] ?? '0'}' : '0')
//         : (crop.area != null ? '${crop.area.value ?? '0'}' : '0');
//     final areaUnit = crop is Map
//         ? (crop['area'] != null ? '${crop['area']['unit'] ?? ''}' : '')
//         : (crop.area != null ? '${crop.area.unit ?? ''}' : '');

//     // Expected Yield extraction
//     final yieldValue = crop is Map
//         ? (crop['expectedYield'] != null
//               ? '${crop['expectedYield']['value'] ?? '0'}'
//               : '0')
//         : (crop.expectedYield != null
//               ? '${crop.expectedYield.value ?? '0'}'
//               : '0');
//     final yieldUnit = crop is Map
//         ? (crop['expectedYield'] != null
//               ? '${crop['expectedYield']['unit'] ?? ''}'
//               : '')
//         : (crop.expectedYield != null
//               ? '${crop.expectedYield.unit ?? ''}'
//               : '');

//     return Row(
//       children: [
//         Expanded(
//           child: _buildStatCard(
//             'Area',
//             areaValue,
//             areaUnit,
//             Icons.landscape_outlined,
//             const Color(0xFF2196F3),
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: _buildStatCard(
//             'Expected Yield',
//             yieldValue,
//             yieldUnit.isNotEmpty
//                 ? yieldUnit
//                 : 'units', // fallback to 'units' if empty
//             Icons.trending_up_outlined,
//             const Color(0xFFFF9800),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildStatCard(
//     String title,
//     String value,
//     String unit,
//     IconData icon,
//     Color color,
//   ) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(icon, color: color, size: 20),
//           ),
//           const SizedBox(height: 12),
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: 12,
//               color: Colors.grey[600],
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const SizedBox(height: 4),
//           RichText(
//             text: TextSpan(
//               text: value,
//               style: const TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w700,
//                 color: Colors.black87,
//               ),
//               children: [
//                 TextSpan(
//                   text: ' $unit',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMainDetailsSection() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 15,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
//             child: Text(
//               'Crop Information',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w700,
//                 color: Colors.grey[800],
//               ),
//             ),
//           ),
//           _buildDetailRow(
//             'Sowing Date',
//             crop is Map
//                 ? (crop['sowingDate'] ?? 'Not specified')
//                 : (crop.sowingDate ?? 'Not specified'),
//             Icons.calendar_today_outlined,
//             const Color(0xFF4CAF50),
//           ),
//           _buildDetailRow(
//             'Expected Harvest Start',
//             crop is Map
//                 ? (crop['expectedFirstHarvestDate'] != null
//                       ? _formatDate(crop['expectedFirstHarvestDate'])
//                       : 'Not specified')
//                 : (crop.expectedFirstHarvestDate != null
//                       ? _formatDate(crop.expectedFirstHarvestDate.toString())
//                       : 'Not specified'),
//             Icons.event_available_outlined,
//             const Color(0xFFFF9800),
//           ),
//           _buildDetailRow(
//             'Expected Harvest End',
//             crop is Map
//                 ? (crop['expectedLastHarvestDate'] != null
//                       ? _formatDate(crop['expectedLastHarvestDate'])
//                       : 'Not specified')
//                 : (crop.expectedLastHarvestDate != null
//                       ? _formatDate(crop.expectedLastHarvestDate.toString())
//                       : 'Not specified'),
//             Icons.event_busy_outlined,
//             const Color(0xFFF44336),
//           ),
//           _buildDetailRow(
//             'Previous Crop',
//             crop is Map
//                 ? (crop['previousCrop'] ?? 'None')
//                 : (crop.previousCrop ?? 'None'),
//             Icons.history_outlined,
//             const Color(0xFF9C27B0),
//             isLast: true,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRejectedReasonSection() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.red[300],
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 15,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Rejected Reason',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w700,
//                 color: Colors.white,
//               ),
//             ),
//             const SizedBox(height: 10),
//             Text(
//               crop['rejectedReason'],
//               style: const TextStyle(
//                 fontWeight: FontWeight.w600,
//                 fontSize: 14,
//                 color: Colors.white,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildLocationSection() {
//     final lat = crop is Map
//         ? (crop['latitude']?.toString() ?? '0')
//         : (crop.latitude?.toString() ?? '0');
//     final lng = crop is Map
//         ? (crop['longitude']?.toString() ?? '0')
//         : (crop.longitude?.toString() ?? '0');

//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 15,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFE3F2FD),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: const Icon(
//                     Icons.location_on_outlined,
//                     color: Color(0xFF1976D2),
//                     size: 20,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Text(
//                   'Location',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w700,
//                     color: Colors.grey[800],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.grey[50],
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Latitude',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey[600],
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           lat,
//                           style: const TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.black87,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Container(width: 1, height: 40, color: Colors.grey[300]),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         Text(
//                           'Longitude',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey[600],
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           lng,
//                           style: const TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.black87,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailRow(
//     String title,
//     String value,
//     IconData icon,
//     Color color, {
//     bool isLast = false,
//   }) {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
//       decoration: BoxDecoration(
//         border: isLast
//             ? null
//             : Border(bottom: BorderSide(color: Colors.grey[100]!, width: 1)),
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Icon(icon, color: color, size: 16),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             flex: 2,
//             child: Text(
//               title,
//               style: const TextStyle(
//                 fontWeight: FontWeight.w600,
//                 fontSize: 14,
//                 color: Color(0xFF37474F),
//               ),
//             ),
//           ),
//           Expanded(
//             flex: 3,
//             child: Text(
//               value,
//               style: const TextStyle(
//                 fontWeight: FontWeight.w500,
//                 fontSize: 14,
//                 color: Colors.black87,
//               ),
//               textAlign: TextAlign.right,
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildImagesSection(BuildContext context, List<dynamic> images) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 15,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFE8F5E8),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: const Icon(
//                     Icons.photo_library_outlined,
//                     color: Color(0xFF2E7D32),
//                     size: 20,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Text(
//                   'Crop Images',
//                   style: TextStyle(
//                     fontWeight: FontWeight.w700,
//                     fontSize: 18,
//                     color: Colors.grey[800],
//                   ),
//                 ),
//                 const Spacer(),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 8,
//                     vertical: 4,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.grey[100],
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     '${images.length} photos',
//                     style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             SizedBox(
//               height: 120,
//               child: ListView.separated(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: images.length,
//                 separatorBuilder: (context, index) => const SizedBox(width: 12),
//                 itemBuilder: (context, index) {
//                   final imgUrl = images[index];
//                   return GestureDetector(
//                     onTap: () => _showImageGallery(context, images, index),
//                     child: Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(16),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.1),
//                             blurRadius: 8,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(16),
//                         child: Image.network(
//                           imgUrl,
//                           width: 120,
//                           height: 120,
//                           fit: BoxFit.cover,
//                           errorBuilder: (context, error, stackTrace) =>
//                               Container(
//                                 width: 120,
//                                 height: 120,
//                                 color: Colors.grey[200],
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Icon(
//                                       Icons.broken_image_outlined,
//                                       color: Colors.grey[400],
//                                       size: 32,
//                                     ),
//                                     const SizedBox(height: 4),
//                                     Text(
//                                       'Failed to load',
//                                       style: TextStyle(
//                                         color: Colors.grey[500],
//                                         fontSize: 10,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // New: Gallery dialog with PageView
//   void _showImageGallery(
//     BuildContext context,
//     List<dynamic> images,
//     int initialIndex,
//   ) {
//     showDialog(
//       context: context,
//       barrierDismissible: true,
//       builder: (context) {
//         PageController controller = PageController(initialPage: initialIndex);
//         return Dialog(
//           backgroundColor: Colors.transparent,
//           insetPadding: const EdgeInsets.all(20),
//           child: Stack(
//             children: [
//               Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(20),
//                   color: Colors.white,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.3),
//                       blurRadius: 20,
//                       offset: const Offset(0, 10),
//                     ),
//                   ],
//                 ),
//                 padding: const EdgeInsets.all(16),
//                 child: SizedBox(
//                   width: 320,
//                   height: 320,
//                   child: PageView.builder(
//                     controller: controller,
//                     itemCount: images.length,
//                     itemBuilder: (context, index) {
//                       final imgUrl = images[index];
//                       return ClipRRect(
//                         borderRadius: BorderRadius.circular(12),
//                         child: Image.network(
//                           imgUrl,
//                           fit: BoxFit.contain,
//                           errorBuilder: (context, error, stackTrace) =>
//                               Container(
//                                 width: 300,
//                                 height: 300,
//                                 color: Colors.grey[100],
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Icon(
//                                       Icons.broken_image_outlined,
//                                       color: Colors.grey[400],
//                                       size: 48,
//                                     ),
//                                     const SizedBox(height: 8),
//                                     Text(
//                                       'Failed to load image',
//                                       style: TextStyle(color: Colors.grey[600]),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//               Positioned(
//                 top: 8,
//                 right: 8,
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Colors.black.withOpacity(0.5),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: IconButton(
//                     icon: const Icon(
//                       Icons.close,
//                       color: Colors.white,
//                       size: 20,
//                     ),
//                     onPressed: () => Navigator.of(context).pop(),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   void _handleEditCrop(BuildContext context) async {
//     final updatedCropData = await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => CropDetailsForm(
//           crop: crop is Map ? Crop.fromApiJson(crop) : crop,
//           farmerId: crop is Map ? crop['farmerId'] : crop.farmerId,
//         ),
//       ),
//     );

//     if (updatedCropData != null) {
//       // The edit form returned new data. Refresh the detail screen.
//       Navigator.of(context).pop(); // Close the current detail screen.
//       Navigator.of(context).push(
//         // Open a new one with the updated data.
//         MaterialPageRoute(
//           builder: (context) => CropDetailScreen(crop: updatedCropData),
//         ),
//       );
//     }
//   }
// }
