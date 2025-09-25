import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class BackendIntegrationTest {
  static const String BASE_URL = 'YOUR_BASE_URL_HERE'; // Replace with actual base URL
  
  // Test different API endpoints for crop updates
  static Future<void> testCropUpdateEndpoints(String cropId) async {
    final endpoints = [
      '$BASE_URL/api/crop/$cropId',
      '$BASE_URL/api/crop/update/$cropId',
      '$BASE_URL/api/crops/$cropId',
      '$BASE_URL/api/crops/update/$cropId',
    ];
    
    final testData = {
      "applicationStatus": "verified",
      "verifiedImages": ["https://test-image-url.com/image1.jpg"],
      "rejectedReason": "Sample rejection reason",
      "verifiedTime": DateTime.now().toIso8601String(),
    };
    
    log('=== TESTING CROP UPDATE ENDPOINTS ===');
    
    for (String endpoint in endpoints) {
      log('Testing endpoint: $endpoint');
      
      try {
        // Test GET first
        final getResponse = await http.get(Uri.parse(endpoint));
        log('GET $endpoint - Status: ${getResponse.statusCode}');
        
        if (getResponse.statusCode == 200) {
          // Test PATCH
          final patchResponse = await http.patch(
            Uri.parse(endpoint),
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: jsonEncode(testData),
          );
          
          log('PATCH $endpoint - Status: ${patchResponse.statusCode}');
          log('PATCH Response: ${patchResponse.body}');
          
          if (patchResponse.statusCode == 200 || patchResponse.statusCode == 201) {
            final responseData = jsonDecode(patchResponse.body);
            log('✅ SUCCESS: $endpoint works!');
            log('Response data: $responseData');
            
            // Check if verifiedImages and rejectedReason are in response
            if (responseData['crop'] != null) {
              log('Verified Images in response: ${responseData['crop']['verifiedImages']}');
              log('Rejected Reason in response: ${responseData['crop']['rejectedReason']}');
            }
            break;
          }
        }
        
        // Test PUT as alternative
        final putResponse = await http.put(
          Uri.parse(endpoint),
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
          },
          body: jsonEncode(testData),
        );
        
        log('PUT $endpoint - Status: ${putResponse.statusCode}');
        if (putResponse.statusCode == 200 || putResponse.statusCode == 201) {
          log('✅ PUT SUCCESS: $endpoint works with PUT!');
          log('PUT Response: ${putResponse.body}');
        }
        
      } catch (e) {
        log('❌ ERROR testing $endpoint: $e');
      }
      
      log('---');
    }
    
    log('=== END ENDPOINT TESTING ===');
  }
  
  // Test Cloudinary upload
  static Future<void> testCloudinaryUpload() async {
    const String cloudinaryCloudName = 'dijjftmm8';
    const String cloudinaryApiKey = '751899995943581';
    const String cloudinaryUploadUrl = 'https://api.cloudinary.com/v1_1/$cloudinaryCloudName/image/upload';
    
    log('=== TESTING CLOUDINARY UPLOAD ===');
    
    try {
      // Create a test request (without actual file)
      var request = http.MultipartRequest('POST', Uri.parse(cloudinaryUploadUrl));
      request.fields['upload_preset'] = 'SmartFarming';
      request.fields['api_key'] = cloudinaryApiKey;
      request.fields['folder'] = 'smart_farmer/verification_images';
      
      log('Cloudinary URL: $cloudinaryUploadUrl');
      log('Upload preset: SmartFarming');
      log('API Key: $cloudinaryApiKey');
      
      // Note: This will fail without actual file, but will test connectivity
      var response = await request.send();
      final respStr = await response.stream.bytesToString();
      
      log('Cloudinary response status: ${response.statusCode}');
      log('Cloudinary response: $respStr');
      
      if (response.statusCode == 400 && respStr.contains('Missing required parameter - file')) {
        log('✅ Cloudinary connectivity OK (missing file is expected)');
      } else if (response.statusCode == 401) {
        log('❌ Cloudinary authentication failed - check API key and upload preset');
      } else {
        log('❌ Unexpected Cloudinary response');
      }
      
    } catch (e) {
      log('❌ Cloudinary test error: $e');
    }
    
    log('=== END CLOUDINARY TESTING ===');
  }
  
  // Test complete crop verification flow
  static Future<void> testCompleteVerificationFlow(String cropId) async {
    log('=== TESTING COMPLETE VERIFICATION FLOW ===');
    
    // Step 1: Get current crop data
    try {
      final getCropResponse = await http.get(Uri.parse('$BASE_URL/api/crop/$cropId'));
      log('Get crop status: ${getCropResponse.statusCode}');
      
      if (getCropResponse.statusCode == 200) {
        final cropData = jsonDecode(getCropResponse.body);
        log('Current crop data: $cropData');
        
        // Step 2: Test verification update
        final verificationData = {
          "applicationStatus": "verified",
          "verifiedImages": [
            "https://res.cloudinary.com/dijjftmm8/image/upload/v1234567890/smart_farmer/verification_images/test1.jpg",
            "https://res.cloudinary.com/dijjftmm8/image/upload/v1234567890/smart_farmer/verification_images/test2.jpg"
          ],
          "verifiedTime": DateTime.now().toIso8601String(),
          "verifierId": "sample_verifier_id"
        };
        
        final updateResponse = await http.patch(
          Uri.parse('$BASE_URL/api/crop/$cropId'),
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
          },
          body: jsonEncode(verificationData),
        );
        
        log('Update response status: ${updateResponse.statusCode}');
        log('Update response body: ${updateResponse.body}');
        
        if (updateResponse.statusCode == 200 || updateResponse.statusCode == 201) {
          // Step 3: Verify the update worked
          final verifyResponse = await http.get(Uri.parse('$BASE_URL/api/crop/$cropId'));
          if (verifyResponse.statusCode == 200) {
            final updatedCrop = jsonDecode(verifyResponse.body);
            log('Updated crop data: $updatedCrop');
            
            // Check if fields were saved
            final crop = updatedCrop['crop'] ?? updatedCrop;
            log('Application Status: ${crop['applicationStatus']}');
            log('Verified Images: ${crop['verifiedImages']}');
            log('Verified Time: ${crop['verifiedTime']}');
            
            if (crop['verifiedImages'] != null && crop['verifiedImages'].isNotEmpty) {
              log('✅ SUCCESS: verifiedImages saved correctly');
            } else {
              log('❌ FAILED: verifiedImages not saved');
            }
          }
        }
        
        // Step 4: Test rejection flow
        final rejectionData = {
          "applicationStatus": "rejected",
          "rejectedReason": "Sample rejection reason - crop quality not meeting standards"
        };
        
        final rejectResponse = await http.patch(
          Uri.parse('$BASE_URL/api/crop/$cropId'),
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
          },
          body: jsonEncode(rejectionData),
        );
        
        log('Rejection response status: ${rejectResponse.statusCode}');
        log('Rejection response body: ${rejectResponse.body}');
        
      }
    } catch (e) {
      log('❌ Complete flow test error: $e');
    }
    
    log('=== END COMPLETE VERIFICATION FLOW TESTING ===');
  }
  
  // Generate test report
  static Future<void> generateTestReport(String cropId) async {
    log('=== BACKEND INTEGRATION TEST REPORT ===');
    log('Crop ID: $cropId');
    log('Base URL: $BASE_URL');
    log('Timestamp: ${DateTime.now().toIso8601String()}');
    log('');
    
    await testCropUpdateEndpoints(cropId);
    log('');
    await testCloudinaryUpload();
    log('');
    await testCompleteVerificationFlow(cropId);
    
    log('=== END TEST REPORT ===');
  }
}

// Usage example:
// BackendIntegrationTest.generateTestReport('your_crop_id_here');