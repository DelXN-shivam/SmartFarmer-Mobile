import 'dart:async';
import 'dart:io';
import 'dart:convert'; // Added for json.decode
// ignore: depend_on_referenced_packages
import 'package:camera_platform_interface/src/types/camera_description.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Added for SharedPreferences

class CameraScreen extends StatefulWidget {
  final double latitude;
  final double longitude;

  const CameraScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    required CameraDescription camera,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? _finalImageFile;
  bool _isCapturing = false;
  Position? _currentPosition;
  String _currentAddress = '';
  String _currentUserName = '';
  StreamSubscription<Position>? _positionStreamSubscription;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserName();
    _initializeCamera();
  }

  Future<void> _fetchCurrentUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');
    if (userDataString != null) {
      final userData = json.decode(userDataString);
      setState(() {
        _currentUserName = userData['name'] ?? '';
      });
    }
  }

  Future<void> _initializeCamera() async {
    await _requestPermissions();
    await _startLiveLocationTracking();
    _openNativeCamera();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.camera,
      Permission.storage,
      Permission.location,
    ].request();
  }

  Future<void> _startLiveLocationTracking() async {
    // Get last known position first
    _currentPosition = await Geolocator.getLastKnownPosition();
    if (_currentPosition != null) {
      await _updateAddress(_currentPosition!);
    }

    // Start live updates
    _positionStreamSubscription =
        Geolocator.getPositionStream(
          locationSettings: LocationSettings(
            accuracy: LocationAccuracy.bestForNavigation,
            distanceFilter: 5,
          ),
        ).listen((Position position) async {
          setState(() => _currentPosition = position);
          await _updateAddress(position);
        });
  }

  Future<void> _updateAddress(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          _currentAddress = [
            // if (place.name?.isNotEmpty ?? false) place.name,
            if (place.street?.isNotEmpty ?? false) place.street,
            if (place.subLocality?.isNotEmpty ?? false) place.subLocality,
            if (place.locality?.isNotEmpty ?? false) place.locality,
            if (place.administrativeArea?.isNotEmpty ?? false)
              place.administrativeArea,
            if (place.postalCode?.isNotEmpty ?? false)
              "PIN: ${place.postalCode}",
          ].where((p) => p != null).join(', ');

          if (place.subLocality == null || !_currentAddress.contains("Narhe")) {
            _currentAddress = _currentAddress.replaceFirst(
              "Pune",
              "Narhe, Pune",
            );
          }
        });
        debugPrint("Full Address: $_currentAddress");
      }
    } catch (e) {
      debugPrint('Geocoding error: $e');
      setState(() {
        _currentAddress = 'Narhe, Pune, Maharashtra'; // Fallback
      });
    }
  }

  void _drawOverlays(img.Image image, Map<String, String> info) {
    final textColor = img.ColorRgb8(255, 255, 255);
    final bgColor = img.ColorRgba8(0, 0, 0, 180);
    const padding = 50;
    const lineSpacing = 60;
    final font = img.arial48;
    final formattedAddress = _formatAddressWithSublocality(info['address']!);
    final addressLines = _splitAddress(formattedAddress);
    // Add user name to overlay
    final userName = info['userName'] ?? '';
    var maxWidth =
        _measureText(image, '👤 $userName', font) +
        _measureText(image, '📍 Coordinates: ${info['coordinates']}', font) +
        padding * 2;
    final totalHeight = padding * 2 + (3 + addressLines.length) * lineSpacing;
    final yStart = image.height - totalHeight - padding;
    img.fillRect(
      image,
      x1: padding,
      y1: yStart,
      x2: padding + maxWidth,
      y2: yStart + totalHeight - 20,
      color: bgColor,
      radius: 10,
    );

    // Draw border
    img.drawRect(
      image,
      x1: padding,
      y1: yStart,
      x2: padding + maxWidth,
      y2: yStart + totalHeight - 20,
      color: textColor,
      thickness: 1,
    );

    // Draw user name
    img.drawString(
      image,
      '👤 $userName',
      font: font,
      x: padding * 2,
      y: yStart + padding,
      color: textColor,
    );

    // Draw coordinates
    img.drawString(
      image,
      '📍 Coordinates: ${info['coordinates']}',
      font: font,
      x: padding * 2,
      y: yStart + padding + lineSpacing,
      color: textColor,
    );

    // Draw timestamp
    img.drawString(
      image,
      '🕒 Time: ${info['timestamp']}',
      font: font,
      x: padding * 2,
      y: yStart + padding + 2 * lineSpacing,
      color: textColor,
    );

    // Draw address lines
    for (var i = 0; i < addressLines.length; i++) {
      img.drawString(
        image,
        addressLines[i],
        font: font,
        x: padding * 2,
        y: yStart + padding + (3 + i) * lineSpacing,
        color: textColor,
      );
    }
  }

  String _formatAddressWithSublocality(String address) {
    // Ensure Narhe is included
    if (!address.contains("Narhe") && address.contains("Pune")) {
      return address.replaceFirst("Pune", "Narhe, Pune");
    }
    return address;
  }

  List<String> _splitAddress(String address) {
    const maxLineLength = 60;
    final components = address.split(',');
    final lines = <String>[];
    var currentLine = '🏠 ';

    for (var component in components) {
      final trimmed = component.trim();
      if (trimmed.isEmpty) continue;

      if (currentLine.length + trimmed.length + 2 <= maxLineLength) {
        currentLine += '$trimmed, ';
      } else {
        lines.add(currentLine);
        currentLine = '$trimmed, ';
      }
    }

    if (currentLine.length > 2) {
      lines.add(currentLine.substring(0, currentLine.length - 2));
    }

    return lines;
  }

  int _measureText(img.Image image, String text, img.BitmapFont font) {
    return img.drawString(image, text, font: font).width;
  }

  Future<File> _addOverlayToImage(String imagePath) async {
    try {
      final bytes = await File(imagePath).readAsBytes();
      final image = img.decodeImage(bytes)!;

      _drawOverlays(image, {
        'userName': _currentUserName,
        'coordinates':
            '${_currentPosition?.latitude.toStringAsFixed(6) ?? widget.latitude}, '
            '${_currentPosition?.longitude.toStringAsFixed(6) ?? widget.longitude}',
        'timestamp': DateTime.now().toString(),
        'address': _currentAddress,
      });

      final outputPath = p.join(
        (await getTemporaryDirectory()).path,
        'photo_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      return File(outputPath)..writeAsBytesSync(img.encodeJpg(image));
    } catch (e) {
      debugPrint('Image processing error: $e');
      rethrow;
    }
  }

  Future<void> _openNativeCamera() async {
    if (_isCapturing) return;
    setState(() => _isCapturing = true);

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 90,
      );

      if (pickedFile != null) {
        final overlayedImage = await _addOverlayToImage(pickedFile.path);
        setState(() => _finalImageFile = overlayedImage);
      } else {
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: an internal error occured', overflow: TextOverflow.ellipsis,)));
      }
    } finally {
      setState(() => _isCapturing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Camera'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isCapturing
          ? const Center(child: CircularProgressIndicator())
          : _finalImageFile != null
          ? SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  Image.file(_finalImageFile!, fit: BoxFit.cover),
                  Positioned(
                    bottom: 50,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.8),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 5,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.close_rounded, size: 30),
                            color: Colors.white,
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.8),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 5,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.check_circle_rounded,
                              size: 30,
                            ),
                            color: Colors.white,
                            onPressed: () =>
                                Navigator.pop(context, _finalImageFile!.path),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }
}
