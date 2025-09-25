class Verification {
  final String id;
  final String cropId;
  final String farmerId;
  final String status;
  final String comments;
  final List<String> verificationImages;
  final double verificationLatitude;
  final double verificationLongitude;
  final DateTime verificationDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Verification({
    required this.id,
    required this.cropId,
    required this.farmerId,
    required this.status,
    required this.comments,
    required this.verificationImages,
    required this.verificationLatitude,
    required this.verificationLongitude,
    required this.verificationDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Verification.fromMap(Map<String, dynamic> map) {
    return Verification(
      id: map['id'] ?? '',
      cropId: map['crop_id'] ?? '',
      farmerId: map['farmer_id'] ?? '',
      status: map['status'] ?? 'pending',
      comments: map['comments'] ?? '',
      verificationImages: List<String>.from(map['verification_images'] ?? []),
      verificationLatitude: (map['verification_latitude'] ?? 0.0).toDouble(),
      verificationLongitude: (map['verification_longitude'] ?? 0.0).toDouble(),
      verificationDate: DateTime.parse(
        map['verification_date'] ?? DateTime.now().toIso8601String(),
      ),
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
      'crop_id': cropId,
      'farmer_id': farmerId,
      'status': status,
      'comments': comments,
      'verification_images': verificationImages,
      'verification_latitude': verificationLatitude,
      'verification_longitude': verificationLongitude,
      'verification_date': verificationDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Verification copyWith({
    String? id,
    String? cropId,
    String? farmerId,
    String? status,
    String? comments,
    List<String>? verificationImages,
    double? verificationLatitude,
    double? verificationLongitude,
    DateTime? verificationDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Verification(
      id: id ?? this.id,
      cropId: cropId ?? this.cropId,
      farmerId: farmerId ?? this.farmerId,
      status: status ?? this.status,
      comments: comments ?? this.comments,
      verificationImages: verificationImages ?? this.verificationImages,
      verificationLatitude: verificationLatitude ?? this.verificationLatitude,
      verificationLongitude:
          verificationLongitude ?? this.verificationLongitude,
      verificationDate: verificationDate ?? this.verificationDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isVerified => status == 'verified';
  bool get isRejected => status == 'rejected';
  bool get isPending => status == 'pending';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Verification &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
