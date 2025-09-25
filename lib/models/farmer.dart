import 'package:equatable/equatable.dart';

class Farmer extends Equatable {
  final String id;
  final String name;
  final String contactNumber;
  final String aadhaarNumber;
  final String village;
  final String landmark;
  final String taluka;
  final String district;
  final String pincode;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Farmer({
    required this.id,
    required this.name,
    required this.contactNumber,
    required this.aadhaarNumber,
    required this.village,
    required this.landmark,
    required this.taluka,
    required this.district,
    required this.pincode,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Farmer.fromMap(Map<String, dynamic> map) {
    return Farmer(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      contactNumber: map['contact_number'] ?? '',
      aadhaarNumber: map['aadhaar_number'] ?? '',
      village: map['village'] ?? '',
      landmark: map['landmark'] ?? '',
      taluka: map['taluka'] ?? '',
      district: map['district'] ?? '',
      pincode: map['pincode'] ?? '',
      createdAt: DateTime.parse(
        map['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        map['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'contact_number': contactNumber,
      'aadhaar_number': aadhaarNumber,
      'village': village,
      'landmark': landmark,
      'taluka': taluka,
      'district': district,
      'pincode': pincode,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Farmer copyWith({
    String? id,
    String? name,
    String? contactNumber,
    String? aadhaarNumber,
    String? village,
    String? landmark,
    String? taluka,
    String? district,
    String? pincode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Farmer(
      id: id ?? this.id,
      name: name ?? this.name,
      contactNumber: contactNumber ?? this.contactNumber,
      aadhaarNumber: aadhaarNumber ?? this.aadhaarNumber,
      village: village ?? this.village,
      landmark: landmark ?? this.landmark,
      taluka: taluka ?? this.taluka,
      district: district ?? this.district,
      pincode: pincode ?? this.pincode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    contactNumber,
    aadhaarNumber,
    village,
    landmark,
    taluka,
    district,
    pincode,
    createdAt,
    updatedAt,
  ];

  String get fullAddress =>
      '$village, $landmark, $taluka, $district - $pincode';
}
