import '../../models/verification.dart';

abstract class VerificationState {
  const VerificationState();
}

class VerificationInitial extends VerificationState {}

class VerificationLoading extends VerificationState {}

class VerificationLoaded extends VerificationState {
  final List<Verification> verifications;
  const VerificationLoaded(this.verifications);
}

class SingleVerificationLoaded extends VerificationState {
  final Verification verification;
  const SingleVerificationLoaded(this.verification);
}

class VerificationError extends VerificationState {
  final String message;
  const VerificationError(this.message);
}
