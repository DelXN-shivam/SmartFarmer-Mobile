import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BackendDebugWidget extends StatefulWidget {
  final String cropId;
  final String baseUrl;
  
  const BackendDebugWidget({
    Key? key,
    required this.cropId,
    required this.baseUrl,
  }) : super(key: key);

  @override
  State<BackendDebugWidget> createState() => _BackendDebugWidgetState();
}

class _BackendDebugWidgetState extends State<BackendDebugWidget> {
  String _debugOutput = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Backend Debug Panel',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _testEndpoints,
                  child: const Text('Test Endpoints'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _testVerification,
                  child: const Text('Test Verification'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_debugOutput.isNotEmpty)
            Container(
              width: double.infinity,
              height: 200,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _debugOutput,
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _testEndpoints() async {
    setState(() {
      _isLoading = true;
      _debugOutput = '';
    });

    final endpoints = [
      '${widget.baseUrl}/api/crop/${widget.cropId}',
      '${widget.baseUrl}/api/crop/update/${widget.cropId}',
      '${widget.baseUrl}/api/crops/${widget.cropId}',
      '${widget.baseUrl}/api/crops/update/${widget.cropId}',
    ];

    String output = 'TESTING ENDPOINTS:\n\n';

    for (String endpoint in endpoints) {
      output += 'Testing: $endpoint\n';
      
      try {
        // Test GET
        final getResponse = await http.get(Uri.parse(endpoint));
        output += 'GET: ${getResponse.statusCode}\n';
        
        if (getResponse.statusCode == 200) {
          output += '✅ GET Success\n';
          
          // Test PATCH
          final testData = {
            "applicationStatus": "verified",
            "verifiedImages": ["https://sample-url.com/image.jpg"],
            "rejectedReason": "Sample reason"
          };
          
          final patchResponse = await http.patch(
            Uri.parse(endpoint),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(testData),
          );
          
          output += 'PATCH: ${patchResponse.statusCode}\n';
          if (patchResponse.statusCode == 200 || patchResponse.statusCode == 201) {
            output += '✅ PATCH Success\n';
            output += 'Response: ${patchResponse.body.substring(0, 100)}...\n';
          } else {
            output += '❌ PATCH Failed\n';
            output += 'Error: ${patchResponse.body}\n';
          }
        } else {
          output += '❌ GET Failed\n';
        }
      } catch (e) {
        output += '❌ Error: $e\n';
      }
      
      output += '\n';
    }

    setState(() {
      _debugOutput = output;
      _isLoading = false;
    });
  }

  Future<void> _testVerification() async {
    setState(() {
      _isLoading = true;
      _debugOutput = '';
    });

    String output = 'TESTING VERIFICATION FLOW:\n\n';

    try {
      // Test verification data
      final verificationData = {
        "applicationStatus": "verified",
        "verifiedImages": [
          "https://res.cloudinary.com/dijjftmm8/image/upload/v1234567890/test1.jpg",
          "https://res.cloudinary.com/dijjftmm8/image/upload/v1234567890/test2.jpg"
        ],
        "verifiedTime": DateTime.now().toIso8601String(),
        "verifierId": "sample_verifier_123"
      };

      output += 'Sending data:\n${jsonEncode(verificationData)}\n\n';

      final url = '${widget.baseUrl}/api/crop/${widget.cropId}';
      output += 'URL: $url\n\n';

      final response = await http.patch(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(verificationData),
      );

      output += 'Response Status: ${response.statusCode}\n';
      output += 'Response Headers: ${response.headers}\n';
      output += 'Response Body: ${response.body}\n\n';

      if (response.statusCode == 200 || response.statusCode == 201) {
        output += '✅ Verification API call successful\n';
        
        // Parse response to check if data was saved
        try {
          final responseData = jsonDecode(response.body);
          final crop = responseData['crop'] ?? responseData;
          
          output += '\nChecking saved data:\n';
          output += 'applicationStatus: ${crop['applicationStatus']}\n';
          output += 'verifiedImages: ${crop['verifiedImages']}\n';
          output += 'verifiedTime: ${crop['verifiedTime']}\n';
          
          if (crop['verifiedImages'] != null && crop['verifiedImages'].isNotEmpty) {
            output += '✅ verifiedImages saved correctly\n';
          } else {
            output += '❌ verifiedImages NOT saved\n';
          }
        } catch (e) {
          output += '❌ Error parsing response: $e\n';
        }
      } else {
        output += '❌ Verification API call failed\n';
      }

      // Test rejection flow
      output += '\n--- TESTING REJECTION ---\n';
      final rejectionData = {
        "applicationStatus": "rejected",
        "rejectedReason": "Sample rejection - quality issues detected"
      };

      final rejectResponse = await http.patch(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(rejectionData),
      );

      output += 'Rejection Status: ${rejectResponse.statusCode}\n';
      output += 'Rejection Response: ${rejectResponse.body}\n';

      if (rejectResponse.statusCode == 200 || rejectResponse.statusCode == 201) {
        final rejectResponseData = jsonDecode(rejectResponse.body);
        final crop = rejectResponseData['crop'] ?? rejectResponseData;
        
        if (crop['rejectedReason'] != null && crop['rejectedReason'].isNotEmpty) {
          output += '✅ rejectedReason saved correctly\n';
        } else {
          output += '❌ rejectedReason NOT saved\n';
        }
      }

    } catch (e) {
      output += '❌ Test error: $e\n';
    }

    setState(() {
      _debugOutput = output;
      _isLoading = false;
    });
  }
}