import '../../models/verification.dart';

abstract class VerificationEvent {
  const VerificationEvent();
}

class LoadVerifications extends VerificationEvent {}

class LoadVerificationsByStatus extends VerificationEvent {
  final String status;
  const LoadVerificationsByStatus(this.status);
}

class AddVerification extends VerificationEvent {
  final Verification verification;
  const AddVerification(this.verification);
}

class UpdateVerification extends VerificationEvent {
  final Verification verification;
  const UpdateVerification(this.verification);
}

class GetVerificationByCropId extends VerificationEvent {
  final String cropId;
  const GetVerificationByCropId(this.cropId);
}

class VerifyCrop extends VerificationEvent {
  final String cropId;
  final String verifierId;
  final String status;
  final String comments;
  final List<String> images;
  final double latitude;
  final double longitude;

  const VerifyCrop({
    required this.cropId,
    required this.verifierId,
    required this.status,
    required this.comments,
    required this.images,
    required this.latitude,
    required this.longitude,
  });
}
