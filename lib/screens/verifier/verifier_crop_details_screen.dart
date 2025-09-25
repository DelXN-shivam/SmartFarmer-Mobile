import 'dart:io';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:smart_farmer/constants/api_constants.dart';
import 'package:smart_farmer/widgets/backend_debug_widget.dart';

// Cloudinary credentials
typedef CloudinaryUploadResult = Map<String, dynamic>;
const String cloudinaryCloudName = 'dijjftmm8';
const String cloudinaryApiKey = '751899995943581';
const String cloudinaryApiSecret = '0DV2G8tTOMG5uLr_NtGW3256BH4';
const String cloudinaryUploadUrl =
    'https://api.cloudinary.com/v1_1/$cloudinaryCloudName/image/upload';

const String BASE_URL = DatabaseUrl.BASE_URL;

class CropDetailsScreen extends StatefulWidget {
  final dynamic crop;

  const CropDetailsScreen({super.key, required this.crop});

  @override
  State<CropDetailsScreen> createState() => _CropDetailsScreenState();
}

class _CropDetailsScreenState extends State<CropDetailsScreen> {
  List<File> _verificationImages = [];
  List<String> _verificationImageUrls = [];
  List<String> _verificationImagePublicIds = [];
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  bool _isImageUploading = false;
  String? _rejectionReason;

  @override
  void initState() {
    log("Crop Data:- ${widget.crop}");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCropHeader(),
            _buildCropDetails(),
            _buildCropImages(),
            _buildVerificationImages(),
            _buildActionButtons(),
            // DEBUG WIDGET - REMOVE IN PRODUCTION
            // BackendDebugWidget(
            //   cropId: widget.crop['_id'] ?? '',
            //   baseUrl: BASE_URL,
            // ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
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
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCropHeader() {
    return Container(
      margin: const EdgeInsets.all(20),
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
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white.withOpacity(0.2),
              ),
              child:
                  widget.crop['images'] != null &&
                      widget.crop['images'].isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        widget.crop['images'][0],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.eco_rounded,
                              color: Colors.white,
                              size: 40,
                            ),
                      ),
                    )
                  : const Icon(
                      Icons.eco_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.crop['name'] ?? 'Unknown Crop',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        widget.crop['applicationStatus'],
                      ).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.crop['applicationStatus']?.toUpperCase() ??
                          'PENDING',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
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

  Widget _buildCropDetails() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Crop Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              'Area',
              '${widget.crop['area']?['value'] ?? 0} ${widget.crop['area']?['unit'] ?? 'acre'}',
            ),
            _buildDetailRow('Sowing Date', widget.crop['sowingDate'] ?? 'N/A'),
            _buildDetailRow(
              'Expected First Harvest',
              widget.crop['expectedFirstHarvestDate'] ?? 'N/A',
            ),
            _buildDetailRow(
              'Expected Last Harvest',
              widget.crop['expectedLastHarvestDate'] ?? 'N/A',
            ),
            _buildDetailRow(
              'Expected Yield',
              '${widget.crop['expectedYield']?['value'] ?? 0} ${widget.crop['expectedYield']?['unit'] ?? 'quintal'}',
            ),
            _buildDetailRow(
              'Previous Crop',
              widget.crop['previousCrop'] ?? 'N/A',
            ),
            _buildDetailRow(
              'Location',
              'Lat: ${widget.crop['latitude']?.toStringAsFixed(4) ?? 'N/A'}, Lng: ${widget.crop['longitude']?.toStringAsFixed(4) ?? 'N/A'}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCropImages() {
    final List<dynamic> images = widget.crop['images'] ?? [];
    
    return Container(
      margin: const EdgeInsets.all(20),
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Crop Images',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
            ),
            const SizedBox(height: 16),
            if (images.isEmpty)
              Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.photo_library,
                        size: 40,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No images available',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              )
            else
              Container(
                height: 120,
                margin: const EdgeInsets.only(bottom: 16),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () {
                          showGeneralDialog(
                            context: context,
                            barrierDismissible: true,
                            barrierLabel: "Image Preview",
                            pageBuilder: (context, anim1, anim2) {
                              return Scaffold(
                                backgroundColor: Colors.black,
                                body: SafeArea(
                                  child: GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: Center(
                                      child: InteractiveViewer(
                                        child: Image.network(
                                          images[index],
                                          fit: BoxFit.contain,
                                          width: double.infinity,
                                          height: double.infinity,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FFFE),
                            border: Border.all(
                              color: const Color(0xFFE8F5E8),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Image.network(
                            images[index],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          const Text(': ', style: TextStyle(fontWeight: FontWeight.w600)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1B5E20),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationImages() {
    // Don't show verification images section if crop is already verified
    if (widget.crop['applicationStatus'] == 'verified') {
      return _buildVerifiedImagesDisplay();
    }
    
    return Container(
      margin: const EdgeInsets.all(20),
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Verification Images',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                const Spacer(),
                if (widget.crop['applicationStatus'] == 'pending')
                  IconButton(
                    onPressed: _showImageSourceDialog,
                    icon: const Icon(Icons.add_a_photo, color: Color(0xFF4CAF50)),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (_verificationImageUrls.isEmpty && _verificationImages.isEmpty)
              Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate,
                        size: 40,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add verification images',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _verificationImageUrls.length + _verificationImages.length,
                itemBuilder: (context, index) {
                  if (index < _verificationImageUrls.length) {
                    // Show already uploaded verification images
                    return Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: NetworkImage(_verificationImageUrls[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    // Show newly added images (not yet uploaded)
                    final fileIndex = index - _verificationImageUrls.length;
                    return Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: FileImage(_verificationImages[fileIndex]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _removeImage(fileIndex),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    if (widget.crop['applicationStatus'] != 'pending') {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
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
                  onTap: _isLoading
                      ? null
                      : () => _showRejectionDialog(),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isLoading)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        else
                          const Icon(Icons.close, color: Colors.white),
                        const SizedBox(width: 8),
                        const Text(
                          'Reject',
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
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isLoading
                      ? null
                      : () => _updateCropStatus('verified'),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isLoading)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        else
                          const Icon(Icons.check, color: Colors.white),
                        const SizedBox(width: 8),
                        const Text(
                          'Verify',
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
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'verified':
        return const Color(0xFF4CAF50);
      case 'rejected':
        return const Color(0xFFFF5252);
      default:
        return const Color(0xFFFF9800);
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add Verification Image',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageSourceOption(
                  Icons.camera_alt,
                  'Camera',
                  () => _pickImage(ImageSource.camera),
                ),
                _buildImageSourceOption(
                  Icons.photo_library,
                  'Gallery',
                  () => _pickImage(ImageSource.gallery),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSourceOption(
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF4CAF50).withOpacity(0.1),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: const Color(0xFF4CAF50)),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1B5E20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context);
    
    if (_isImageUploading) return;
    
    setState(() {
      _isImageUploading = true;
    });
    
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        // Upload to Cloudinary
        final uploadResult = await _uploadImageToCloudinary(File(image.path));
        if (uploadResult != null && uploadResult['secure_url'] != null) {
          setState(() {
            _verificationImageUrls.add(uploadResult['secure_url']);
            _verificationImagePublicIds.add(uploadResult['public_id']);
          });
          _showSuccessSnackbar('Image uploaded successfully!');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload image to Cloudinary.', overflow: TextOverflow.ellipsis,)),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e', overflow: TextOverflow.ellipsis,)));
    } finally {
      setState(() {
        _isImageUploading = false;
      });
    }
  }

  // Test different API endpoints to find the correct one
  Future<String?> _findWorkingEndpoint(String cropId) async {
    final endpoints = [
      '$BASE_URL/api/crop/$cropId',
      '$BASE_URL/api/crop/update/$cropId',
      '$BASE_URL/api/crops/$cropId',
      '$BASE_URL/api/crops/update/$cropId',
    ];
    
    for (String endpoint in endpoints) {
      try {
        final response = await http.get(Uri.parse(endpoint));
        if (response.statusCode == 200) {
          debugPrint('Working endpoint found: $endpoint');
          return endpoint;
        }
      } catch (e) {
        debugPrint('Endpoint $endpoint failed: $e');
      }
    }
    
    debugPrint('No working endpoint found');
    return null;
  }

  // Cloudinary upload logic with better error handling
  Future<CloudinaryUploadResult?> _uploadImageToCloudinary(File file) async {
    try {
      debugPrint('Starting Cloudinary upload for file: ${file.path}');
      
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(cloudinaryUploadUrl),
      );
      
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      request.fields['upload_preset'] = 'SmartFarming';
      request.fields['api_key'] = cloudinaryApiKey;
      request.fields['folder'] = 'smart_farmer/verification_images';
      
      debugPrint('Cloudinary request fields: ${request.fields}');
      
      var response = await request.send();
      final respStr = await response.stream.bytesToString();
      
      debugPrint('Cloudinary response status: ${response.statusCode}');
      debugPrint('Cloudinary response body: $respStr');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(respStr);
        debugPrint('Cloudinary upload successful: ${data['secure_url']}');
        return data;
      } else {
        debugPrint('Cloudinary upload failed with status ${response.statusCode}: $respStr');
        return null;
      }
    } catch (e) {
      debugPrint('Cloudinary upload error: $e');
      return null;
    }
  }

  Future<void> _deleteImageFromCloudinary(String publicId) async {
    final url = 'https://api.cloudinary.com/v1_1/$cloudinaryCloudName/image/destroy';
    final basicAuth = 'Basic ' + base64Encode(utf8.encode('$cloudinaryApiKey:$cloudinaryApiSecret'));
    
    final response = await http.post(
      Uri.parse(url),
      headers: {'Authorization': basicAuth, 'Content-Type': 'application/json'},
      body: jsonEncode({'public_id': publicId}),
    );
    
    if (response.statusCode == 200) {
      debugPrint('Image deleted from Cloudinary');
    } else {
      debugPrint('Failed to delete image: ${response.body}');
    }
  }

  void _removeImage(int index) {
    if (index < _verificationImageUrls.length) {
      // Delete from Cloudinary and remove from list
      final publicId = _verificationImagePublicIds[index];
      _deleteImageFromCloudinary(publicId);
      
      setState(() {
        _verificationImageUrls.removeAt(index);
        _verificationImagePublicIds.removeAt(index);
      });
    } else {
      // Remove from local files list
      final fileIndex = index - _verificationImageUrls.length;
      setState(() {
        _verificationImages.removeAt(fileIndex);
      });
    }
  }

  Future<void> _updateCropStatus(String status) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Upload any remaining local images first
      List<String> uploadedImageUrls = [];
      for (var imageFile in _verificationImages) {
        final uploadResult = await _uploadImageToCloudinary(imageFile);
        if (uploadResult != null && uploadResult['secure_url'] != null) {
          uploadedImageUrls.add(uploadResult['secure_url']);
          _verificationImagePublicIds.add(uploadResult['public_id']);
        }
      }
      
      // Combine existing uploaded URLs with newly uploaded ones
      final allVerificationImages = [..._verificationImageUrls, ...uploadedImageUrls];
      
      // Clear local files after upload
      _verificationImages.clear();

      // Prepare update data based on backend schema
      Map<String, dynamic> updateData = {
        "applicationStatus": status,
      };
      
      // Add verifiedImages and verifiedTime only for verified status
      if (status == 'verified') {
        updateData["verifiedImages"] = allVerificationImages;
        updateData["verifiedTime"] = DateTime.now().toIso8601String();
        // Ensure verifierId is included
        // updateData["verifierId"] = "verifier_id_placeholder"; // Replace with actual verifier ID
      }
      
      // Add rejection reason if status is rejected
      if (status == 'rejected' && _rejectionReason != null && _rejectionReason!.isNotEmpty) {
        updateData["verifiedImages"] = allVerificationImages;
        updateData["verifiedTime"] = DateTime.now().toIso8601String();
        updateData["rejectedReason"] = _rejectionReason;
      }
      
      // Debug logging
      debugPrint('=== CROP UPDATE DEBUG ===');
      debugPrint('Status: $status');
      debugPrint('Crop ID: ${widget.crop['_id']}');
      debugPrint('All verification images: $allVerificationImages');
      debugPrint('Rejection reason: $_rejectionReason');
      debugPrint('Update data: ${jsonEncode(updateData)}');
      debugPrint('========================');

      // Update crop status - try different endpoint patterns
      final cropId = widget.crop['_id'];
      final url = '$BASE_URL/api/crop/update/$cropId'; // Try without 'update' path
      
      debugPrint('Making PATCH request to: $url');
      
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(updateData),
      );

      debugPrint('=== RESPONSE DEBUG ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Headers: ${response.headers}');
      debugPrint('Response Body: ${response.body}');
      debugPrint('===================');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final responseData = jsonDecode(response.body);
          
          // Verify the response contains updated data
          debugPrint('Response data keys: ${responseData.keys}');
          if (responseData['crop'] != null) {
            debugPrint('Updated crop verifiedImages: ${responseData['crop']['verifiedImages']}');
            debugPrint('Updated crop rejectedReason: ${responseData['crop']['rejectedReason']}');
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                responseData['message'] ?? 'Crop status updated successfully', overflow: TextOverflow.ellipsis,
              ),
              backgroundColor: Colors.green,
            ),
          );
          
          // Return the updated status to the previous screen
          Navigator.pop(context, status);
        } catch (e) {
          debugPrint('Error parsing response: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Crop updated but response parsing failed', overflow: TextOverflow.ellipsis,),
              backgroundColor: Colors.orange,
            ),
          );
          Navigator.pop(context, status);
        }
      } else {
        // Try alternative endpoint if first one fails
        final alternativeUrl = '$BASE_URL/api/crop/update/$cropId';
        debugPrint('Trying alternative endpoint: $alternativeUrl');
        
        final alternativeResponse = await http.patch(
          Uri.parse(alternativeUrl),
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
          },
          body: jsonEncode(updateData),
        );
        
        debugPrint('Alternative response status: ${alternativeResponse.statusCode}');
        debugPrint('Alternative response body: ${alternativeResponse.body}');
        
        if (alternativeResponse.statusCode == 200 || alternativeResponse.statusCode == 201) {
          final responseData = jsonDecode(alternativeResponse.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                responseData['message'] ?? 'Crop status updated successfully', overflow: TextOverflow.ellipsis,
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, status);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update crop status. Status: ${response.statusCode}', overflow: TextOverflow.ellipsis,),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error updating crop status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating crop status: $e', overflow: TextOverflow.ellipsis,),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildVerifiedImagesDisplay() {
    final List<dynamic> verifiedImages = widget.crop['verifiedImages'] ?? [];
    
    if (verifiedImages.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      margin: const EdgeInsets.all(20),
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.verified,
                    color: Color(0xFF4CAF50),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Verified Images',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: verifiedImages.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () {
                        showGeneralDialog(
                          context: context,
                          barrierDismissible: true,
                          barrierLabel: "Image Preview",
                          pageBuilder: (context, anim1, anim2) {
                            return Scaffold(
                              backgroundColor: Colors.black,
                              body: SafeArea(
                                child: GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Center(
                                    child: InteractiveViewer(
                                      child: Image.network(
                                        verifiedImages[index],
                                        fit: BoxFit.contain,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FFFE),
                          border: Border.all(
                            color: const Color(0xFF4CAF50),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                verifiedImages[index],
                                fit: BoxFit.cover,
                                width: 120,
                                height: 120,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF4CAF50),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.verified,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
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

  void _showRejectionDialog() {
    final TextEditingController reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.cancel, color: Color(0xFFFF5252)),
              SizedBox(width: 8),
              Text('Reject Crop'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Please provide a reason for rejection:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter rejection reason...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFFF5252)),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final reason = reasonController.text.trim();
                if (reason.isNotEmpty) {
                  _rejectionReason = reason;
                  Navigator.of(context).pop();
                  _updateCropStatus('rejected');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please provide a rejection reason', overflow: TextOverflow.ellipsis,),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5252),
              ),
              child: const Text(
                'Reject',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(message, overflow: TextOverflow.ellipsis,),
          ],
        ),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}




// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';

// class CropDetailsScreen extends StatefulWidget {
//   final dynamic crop;

//   const CropDetailsScreen({super.key, required this.crop});

//   @override
//   State<CropDetailsScreen> createState() => _CropDetailsScreenState();
// }

// class _CropDetailsScreenState extends State<CropDetailsScreen> {
//   List<File> _verificationImages = [];
//   final ImagePicker _picker = ImagePicker();
//   bool _isLoading = false;

//   @override
//   void initState() {
//     log("Crop Data:- ${widget.crop}");
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8FFFE),
//       appBar: _buildAppBar(),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildCropHeader(),
//             _buildCropDetails(),
//             _buidCropPreviousImages(),
//             _buildVerificationImages(),
//             _buildActionButtons(),
//             const SizedBox(height: 100),
//           ],
//         ),
//       ),
//     );
//   }

//   PreferredSizeWidget _buildAppBar() {
//     return AppBar(
//       backgroundColor: Colors.transparent,
//       elevation: 0,
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
//         style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//       ),
//     );
//   }

//   Widget _buildCropHeader() {
//     return Container(
//       margin: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(24),
//         gradient: const LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: const Color(0xFF4CAF50).withOpacity(0.3),
//             blurRadius: 20,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Row(
//           children: [
//             Container(
//               width: 80,
//               height: 80,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(20),
//                 color: Colors.white.withOpacity(0.2),
//               ),
//               child:
//                   widget.crop['images'] != null &&
//                       widget.crop['images'].isNotEmpty
//                   ? ClipRRect(
//                       borderRadius: BorderRadius.circular(20),
//                       child: Image.network(
//                         widget.crop['images'][0],
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stackTrace) =>
//                             const Icon(
//                               Icons.eco_rounded,
//                               color: Colors.white,
//                               size: 40,
//                             ),
//                       ),
//                     )
//                   : const Icon(
//                       Icons.eco_rounded,
//                       color: Colors.white,
//                       size: 40,
//                     ),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     widget.crop['name'] ?? 'Unknown Crop',
//                     style: const TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 6,
//                     ),
//                     decoration: BoxDecoration(
//                       color: _getStatusColor(
//                         widget.crop['applicationStatus'],
//                       ).withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       widget.crop['applicationStatus']?.toUpperCase() ??
//                           'PENDING',
//                       style: const TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.white,
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

//   Widget _buildCropDetails() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(20),
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.06),
//             blurRadius: 15,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Crop Information',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFF1B5E20),
//               ),
//             ),
//             const SizedBox(height: 16),
//             _buildDetailRow(
//               'Area',
//               '${widget.crop['area']?['value'] ?? 0} ${widget.crop['area']?['unit'] ?? 'acre'}',
//             ),
//             _buildDetailRow('Sowing Date', widget.crop['sowingDate'] ?? 'N/A'),
//             _buildDetailRow(
//               'Expected Harvest',
//               widget.crop['expectedHarvestDate'] ?? 'N/A',
//             ),
//             _buildDetailRow(
//               'Expected Yield',
//               '${widget.crop['expectedYield']?['value'] ?? 0} ${widget.crop['expectedYield']?['unit'] ?? 'quintal'}',
//             ),
//             _buildDetailRow(
//               'Previous Crop',
//               widget.crop['previousCrop'] ?? 'N/A',
//             ),
//             _buildDetailRow(
//               'Location',
//               'Lat: ${widget.crop['latitude']?.toStringAsFixed(4) ?? 'N/A'}, Lng: ${widget.crop['longitude']?.toStringAsFixed(4) ?? 'N/A'}',
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buidCropPreviousImages() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(20),
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.06),
//             blurRadius: 15,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Crop Images',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFF1B5E20),
//               ),
//             ),
//             const SizedBox(height: 16),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 120,
//             child: Text(
//               label,
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey[700],
//               ),
//             ),
//           ),
//           const Text(': ', style: TextStyle(fontWeight: FontWeight.w600)),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(
//                 fontSize: 14,
//                 color: Color(0xFF1B5E20),
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildVerificationImages() {
//     return Container(
//       margin: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(20),
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.06),
//             blurRadius: 15,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 const Text(
//                   'Verification Images',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF1B5E20),
//                   ),
//                 ),
//                 const Spacer(),
//                 IconButton(
//                   onPressed: _showImageSourceDialog,
//                   icon: const Icon(Icons.add_a_photo, color: Color(0xFF4CAF50)),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             if (_verificationImages.isEmpty)
//               Container(
//                 height: 120,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.grey[300]!),
//                 ),
//                 child: Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.add_photo_alternate,
//                         size: 40,
//                         color: Colors.grey[400],
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         'Add verification images',
//                         style: TextStyle(color: Colors.grey[600]),
//                       ),
//                     ],
//                   ),
//                 ),
//               )
//             else
//               GridView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 3,
//                   crossAxisSpacing: 8,
//                   mainAxisSpacing: 8,
//                 ),
//                 itemCount: _verificationImages.length,
//                 itemBuilder: (context, index) {
//                   return Stack(
//                     children: [
//                       Container(
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(12),
//                           image: DecorationImage(
//                             image: FileImage(_verificationImages[index]),
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                       ),
//                       Positioned(
//                         top: 4,
//                         right: 4,
//                         child: GestureDetector(
//                           onTap: () => _removeImage(index),
//                           child: Container(
//                             padding: const EdgeInsets.all(4),
//                             decoration: const BoxDecoration(
//                               color: Colors.red,
//                               shape: BoxShape.circle,
//                             ),
//                             child: const Icon(
//                               Icons.close,
//                               color: Colors.white,
//                               size: 16,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   );
//                 },
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildActionButtons() {
//     if (widget.crop['applicationStatus'] != 'pending') {
//       return const SizedBox.shrink();
//     }

//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20),
//       child: Row(
//         children: [
//           Expanded(
//             child: Container(
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(16),
//                 gradient: const LinearGradient(
//                   colors: [Color(0xFFFF5252), Color(0xFFD32F2F)],
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: const Color(0xFFFF5252).withOpacity(0.3),
//                     blurRadius: 15,
//                     offset: const Offset(0, 8),
//                   ),
//                 ],
//               ),
//               child: Material(
//                 color: Colors.transparent,
//                 child: InkWell(
//                   onTap: _isLoading
//                       ? null
//                       : () => _updateCropStatus('rejected'),
//                   borderRadius: BorderRadius.circular(16),
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         if (_isLoading)
//                           const SizedBox(
//                             width: 20,
//                             height: 20,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               valueColor: AlwaysStoppedAnimation<Color>(
//                                 Colors.white,
//                               ),
//                             ),
//                           )
//                         else
//                           const Icon(Icons.close, color: Colors.white),
//                         const SizedBox(width: 8),
//                         const Text(
//                           'Reject',
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: Colors.white,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Container(
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(16),
//                 gradient: const LinearGradient(
//                   colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: const Color(0xFF4CAF50).withOpacity(0.3),
//                     blurRadius: 15,
//                     offset: const Offset(0, 8),
//                   ),
//                 ],
//               ),
//               child: Material(
//                 color: Colors.transparent,
//                 child: InkWell(
//                   onTap: _isLoading
//                       ? null
//                       : () => _updateCropStatus('approved'),
//                   borderRadius: BorderRadius.circular(16),
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         if (_isLoading)
//                           const SizedBox(
//                             width: 20,
//                             height: 20,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               valueColor: AlwaysStoppedAnimation<Color>(
//                                 Colors.white,
//                               ),
//                             ),
//                           )
//                         else
//                           const Icon(Icons.check, color: Colors.white),
//                         const SizedBox(width: 8),
//                         const Text(
//                           'Verify',
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: Colors.white,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Color _getStatusColor(String? status) {
//     switch (status?.toLowerCase()) {
//       case 'approved':
//         return const Color(0xFF4CAF50);
//       case 'rejected':
//         return const Color(0xFFFF5252);
//       default:
//         return const Color(0xFFFF9800);
//     }
//   }

//   void _showImageSourceDialog() {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => Container(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text(
//               'Add Verification Image',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFF1B5E20),
//               ),
//             ),
//             const SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 _buildImageSourceOption(
//                   Icons.camera_alt,
//                   'Camera',
//                   () => _pickImage(ImageSource.camera),
//                 ),
//                 _buildImageSourceOption(
//                   Icons.photo_library,
//                   'Gallery',
//                   () => _pickImage(ImageSource.gallery),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildImageSourceOption(
//     IconData icon,
//     String label,
//     VoidCallback onTap,
//   ) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(16),
//           color: const Color(0xFF4CAF50).withOpacity(0.1),
//         ),
//         child: Column(
//           children: [
//             Icon(icon, size: 40, color: const Color(0xFF4CAF50)),
//             const SizedBox(height: 8),
//             Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xFF1B5E20),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _pickImage(ImageSource source) async {
//     Navigator.pop(context);
//     try {
//       final XFile? image = await _picker.pickImage(source: source);
//       if (image != null) {
//         setState(() {
//           _verificationImages.add(File(image.path));
//         });
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
//     }
//   }

//   void _removeImage(int index) {
//     setState(() {
//       _verificationImages.removeAt(index);
//     });
//   }

//   Future<void> _updateCropStatus(String status) async {
//     setState(() {
//       _isLoading = true;
//     });

//     // Simulate API call
//     await Future.delayed(const Duration(seconds: 2));

//     setState(() {
//       _isLoading = false;
//     });

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           'Crop ${status == 'approved' ? 'verified' : 'rejected'} successfully',
//         ),
//         backgroundColor: status == 'approved' ? Colors.green : Colors.red,
//       ),
//     );

//     Navigator.pop(context, status);
//   }
// }
