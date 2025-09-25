import 'package:flutter_bloc/flutter_bloc.dart';
import 'verification_event.dart';
import 'verification_state.dart';
import '../../models/verification.dart';
import '../../services/database_service.dart';
import 'dart:math';

class VerificationBloc extends Bloc<VerificationEvent, VerificationState> {
  VerificationBloc() : super(VerificationInitial()) {
    on<LoadVerifications>((event, emit) async {
      emit(VerificationLoading());
      try {
        final verifications = await DatabaseService.getAllVerifications();
        emit(VerificationLoaded(verifications));
      } catch (e) {
        emit(VerificationError(e.toString()));
      }
    });

    on<LoadVerificationsByStatus>((event, emit) async {
      emit(VerificationLoading());
      try {
        final verifications = await DatabaseService.getVerificationsByStatus(
          event.status,
        );
        emit(VerificationLoaded(verifications));
      } catch (e) {
        emit(VerificationError(e.toString()));
      }
    });

    on<AddVerification>((event, emit) async {
      try {
        await DatabaseService.insertVerification(event.verification);
        add(LoadVerifications());
      } catch (e) {
        emit(VerificationError(e.toString()));
      }
    });

    on<UpdateVerification>((event, emit) async {
      try {
        await DatabaseService.updateVerification(event.verification);
        add(LoadVerifications());
      } catch (e) {
        emit(VerificationError(e.toString()));
      }
    });

    on<GetVerificationByCropId>((event, emit) async {
      emit(VerificationLoading());
      try {
        final verification = await DatabaseService.getVerificationByCropId(
          event.cropId,
        );
        if (verification != null) {
          emit(SingleVerificationLoaded(verification));
        } else {
          emit(VerificationError('Verification not found'));
        }
      } catch (e) {
        emit(VerificationError(e.toString()));
      }
    });

    on<VerifyCrop>((event, emit) async {
      try {
        final verification = Verification(
          id: _generateId(),
          cropId: event.cropId,
          farmerId: '', // Will be set from crop data
          status: event.status,
          comments: event.comments,
          verificationImages: event.images,
          verificationLatitude: event.latitude,
          verificationLongitude: event.longitude,
          verificationDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await DatabaseService.insertVerification(verification);
        add(LoadVerifications());
      } catch (e) {
        emit(VerificationError(e.toString()));
      }
    });
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        Random().nextInt(1000).toString();
  }
}
