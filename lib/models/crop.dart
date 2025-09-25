import 'dart:convert';

class Crop {
  final String id;
  final String farmerId;
  final String cropName;
  final double area;
  final String areaUnit;
  final DateTime sowingDate;
  final DateTime expectedHarvestDate;
  final DateTime expectedFirstHarvestDate;
  final DateTime expectedLastHarvestDate;
  final double expectedYield;
  final String expectedYieldUnit;
  final String previousCrop;
  final double latitude;
  final double longitude;
  final List<String> imagePaths;
  final List<String> imagePublicIds;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Crop({
    required this.id,
    required this.farmerId,
    required this.cropName,
    required this.area,
    this.areaUnit = 'acre',
    required this.sowingDate,
    required this.expectedHarvestDate,
    required this.expectedFirstHarvestDate,
    required this.expectedLastHarvestDate,
    required this.expectedYield,
    this.expectedYieldUnit = 'kg',
    required this.previousCrop,
    required this.latitude,
    required this.longitude,
    required this.imagePaths,
    required this.imagePublicIds,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Crop.fromMap(Map<String, dynamic> map) {
    return Crop(
      id: map['id'] ?? '',
      farmerId: map['farmer_id'] ?? '',
      cropName: map['crop_name'] ?? '',
      area: (map['area'] ?? 0.0).toDouble(),
      areaUnit: map['area_unit'] ?? 'acre',
      sowingDate: DateTime.parse(
        map['sowing_date'] ?? DateTime.now().toIso8601String(),
      ),
      expectedHarvestDate: DateTime.parse(
        map['expected_harvest_date'] ?? DateTime.now().toIso8601String(),
      ),
      expectedFirstHarvestDate: map['expected_first_harvest_date'] != null
          ? DateTime.parse(map['expected_first_harvest_date'])
          : DateTime.parse(
              map['expected_harvest_date'] ?? DateTime.now().toIso8601String(),
            ),
      expectedLastHarvestDate: map['expected_last_harvest_date'] != null
          ? DateTime.parse(map['expected_last_harvest_date'])
          : DateTime.parse(
              map['expected_harvest_date'] ?? DateTime.now().toIso8601String(),
            ),
      expectedYield: (map['expected_yield'] ?? 0.0).toDouble(),
      expectedYieldUnit: map['expected_yield_unit'] ?? 'kg',
      previousCrop: map['previous_crop'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      imagePaths: map['image_paths'] is String
          ? List<String>.from(jsonDecode(map['image_paths'] ?? '[]'))
          : List<String>.from(map['image_paths'] ?? []),
      imagePublicIds: map['image_public_ids'] is String
          ? List<String>.from(jsonDecode(map['image_public_ids'] ?? '[]'))
          : List<String>.from(map['image_public_ids'] ?? []),
      status: map['status'] ?? 'pending',
      createdAt: DateTime.parse(
        map['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        map['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  factory Crop.fromApiJson(Map<String, dynamic> json) {
    return Crop(
      id: json['_id'] ?? '',
      farmerId: json['farmerId'] ?? '',
      cropName: json['name'] ?? '',
      area: (json['area'] != null && json['area']['value'] != null)
          ? (json['area']['value'] as num).toDouble()
          : 0.0,
      areaUnit: (json['area'] != null && json['area']['unit'] != null)
          ? json['area']['unit']
          : 'acre',
      sowingDate: _parseDate(json['sowingDate']) ?? DateTime.now(),
      expectedHarvestDate:
          _parseDate(json['expectedHarvestDate']) ?? DateTime.now(),
      expectedFirstHarvestDate:
          _parseDate(json['expectedFirstHarvestDate']) ??
          _parseDate(json['expectedHarvestDate']) ??
          DateTime.now(),
      expectedLastHarvestDate:
          _parseDate(json['expectedLastHarvestDate']) ??
          _parseDate(json['expectedHarvestDate']) ??
          DateTime.now(),
      expectedYield: (json['expectedYield'] != null && json['expectedYield'] is Map && json['expectedYield']['value'] != null)
          ? (json['expectedYield']['value'] as num).toDouble()
          : (json['expectedYield'] is num ? (json['expectedYield'] as num).toDouble() : 0.0),
      expectedYieldUnit: (json['expectedYield'] != null && json['expectedYield'] is Map && json['expectedYield']['unit'] != null)
          ? json['expectedYield']['unit']
          : 'kg',
      previousCrop: json['previousCrop'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      imagePaths: List<String>.from(json['images'] ?? []),
      imagePublicIds: [], // Not provided by API
      status: '', // Not provided by API
      createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDate(json['updatedAt']) ?? DateTime.now(),
    );
  }

  static DateTime? _parseDate(dynamic date) {
    if (date == null) return null;
    if (date is DateTime) return date;
    if (date is String) {
      try {
        // Try ISO8601 first
        return DateTime.parse(date);
      } catch (_) {
        // Try dd-MM-yyyy
        try {
          final parts = date.split('-');
          if (parts.length == 3) {
            return DateTime(
              int.parse(parts[2]),
              int.parse(parts[1]),
              int.parse(parts[0]),
            );
          }
        } catch (_) {}
      }
    }
    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'farmer_id': farmerId,
      'crop_name': cropName,
      'area': area,
      'area_unit': areaUnit,
      'sowing_date': sowingDate.toIso8601String(),
      'expected_harvest_date': expectedHarvestDate.toIso8601String(),
      'expected_first_harvest_date': expectedFirstHarvestDate.toIso8601String(),
      'expected_last_harvest_date': expectedLastHarvestDate.toIso8601String(),
      'expected_yield': expectedYield,
      'expected_yield_unit': expectedYieldUnit,
      'previous_crop': previousCrop,
      'latitude': latitude,
      'longitude': longitude,
      'image_paths': jsonEncode(imagePaths),
      'image_public_ids': jsonEncode(imagePublicIds),
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Crop copyWith({
    String? id,
    String? farmerId,
    String? cropName,
    double? area,
    DateTime? sowingDate,
    DateTime? expectedHarvestDate,
    DateTime? expectedFirstHarvestDate,
    DateTime? expectedLastHarvestDate,
    double? expectedYield,
    String? previousCrop,
    double? latitude,
    double? longitude,
    List<String>? imagePaths,
    List<String>? imagePublicIds,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Crop(
      id: id ?? this.id,
      farmerId: farmerId ?? this.farmerId,
      cropName: cropName ?? this.cropName,
      area: area ?? this.area,
      sowingDate: sowingDate ?? this.sowingDate,
      expectedHarvestDate: expectedHarvestDate ?? this.expectedHarvestDate,
      expectedFirstHarvestDate:
          expectedFirstHarvestDate ?? this.expectedFirstHarvestDate,
      expectedLastHarvestDate:
          expectedLastHarvestDate ?? this.expectedLastHarvestDate,
      expectedYield: expectedYield ?? this.expectedYield,
      previousCrop: previousCrop ?? this.previousCrop,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imagePaths: imagePaths ?? this.imagePaths,
      imagePublicIds: imagePublicIds ?? this.imagePublicIds,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Calculate crop age in days
  int get cropAgeInDays {
    final now = DateTime.now();
    return now.difference(sowingDate).inDays;
  }

  // Calculate days to harvest
  int get daysToHarvest {
    final now = DateTime.now();
    return expectedHarvestDate.difference(now).inDays;
  }

  // Get growth stage based on crop age
  String get growthStage {
    final age = cropAgeInDays;
    final lifespan = 120; // Default value, since cropType is removed

    if (age <= lifespan * 0.1) return 'Germination';
    if (age <= lifespan * 0.3) return 'Vegetative';
    if (age <= lifespan * 0.6) return 'Flowering';
    if (age <= lifespan * 0.8) return 'Fruiting';
    if (age <= lifespan) return 'Harvesting';
    return 'Mature';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Crop && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
