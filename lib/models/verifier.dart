import 'package:equatable/equatable.dart';

class Verifier extends Equatable {
  final String id;
  final String name;
  final String email;
  final String contact;
  final String aadhaarNumber;
  final int age;
  final String village;
  final String landMark;
  final String taluka;
  final List<String> allocatedTaluka;
  final String district;
  final String state;
  final String pincode;
  final String role;
  final List<String> farmerId;
  final List<String> cropId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Verifier({
    required this.id,
    required this.name,
    required this.email,
    required this.contact,
    required this.aadhaarNumber,
    required this.age,
    required this.village,
    required this.landMark,
    required this.taluka,
    required this.allocatedTaluka,
    required this.district,
    required this.state,
    required this.pincode,
    required this.role,
    required this.farmerId,
    required this.cropId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Verifier.fromJson(Map<String, dynamic> json) {
    return Verifier(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      contact: json['contact'] ?? '',
      aadhaarNumber: json['aadhaarNumber'] ?? '',
      age: json['age'] ?? 0,
      village: json['village'] ?? '',
      landMark: json['landMark'] ?? '',
      taluka: json['taluka'] ?? '',
      allocatedTaluka: List<String>.from(json['allocatedTaluka'] ?? []),
      district: json['district'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode'] ?? '',
      role: json['role'] ?? '',
      farmerId: List<String>.from(json['farmerId'] ?? []),
      cropId: List<String>.from(json['cropId'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  @override
  List<Object?> get props => [
    id, name, email, contact, aadhaarNumber, age, village, landMark,
    taluka, allocatedTaluka, district, state, pincode, role,
    farmerId, cropId, createdAt, updatedAt,
  ];
}