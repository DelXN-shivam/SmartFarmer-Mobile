import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_farmer/models/farmer.dart';
import 'farmer_event.dart';
import 'farmer_state.dart';
import '../../services/database_service.dart';
import '../../services/shared_prefs_service.dart';

class FarmerBloc extends Bloc<FarmerEvent, FarmerState> {
  FarmerBloc() : super(FarmerInitial()) {
    on<LoadFarmerById>((event, emit) async {
      emit(FarmerLoading());
      try {
        final farmer = await DatabaseService.getFarmerById(event.farmerId);
        if (farmer != null) {
          emit(SingleFarmerLoaded(farmer));
        } else {
          emit(FarmerError('Farmer not found'));
        }
      } catch (e) {
        emit(FarmerError(e.toString()));
      }
    });

    on<RefreshFarmerProfile>((event, emit) async {
      emit(FarmerLoading());
      try {
        final farmer =
            await DatabaseService.fetchFarmerByIdFromApi(event.farmerId);
        if (farmer != null) {
          await SharedPrefsService.saveFarmerData(farmer.toMap());
          emit(SingleFarmerLoaded(farmer));
        } else {
          emit(FarmerError('Farmer not found'));
        }
      } catch (e) {
        emit(FarmerError(e.toString()));
      }
    });

    on<UpdateFarmerProfile>((event, emit) async {
      emit(FarmerLoading());
      try {
        final success = await DatabaseService.updateFarmerInApi(event.farmer);
        if (success) {
          await SharedPrefsService.saveFarmerData(event.farmer.toMap());
          emit(SingleFarmerLoaded(event.farmer));
        } else {
          emit(FarmerError('Failed to update farmer profile'));
        }
      } catch (e) {
        emit(FarmerError(e.toString()));
      }
    });

    on<UpdateAllDataSources>((event, emit) async {
      emit(FarmerLoading());
      try {
        // 1. Update API
        final apiSuccess =
            await DatabaseService.updateFarmerInApi(event.farmer);

        if (apiSuccess) {
          // 2. Update SharedPreferences
          await SharedPrefsService.saveFarmerData(event.farmer.toMap());

          // 3. Update local DB
          await DatabaseService.updateFarmer(event.farmer);

          // 4. Emit success state
          emit(SingleFarmerLoaded(event.farmer));
        } else {
          emit(FarmerError('API update failed'));
        }
      } catch (e) {
        emit(FarmerError('An error occurred: $e'));
      }
    });

    on<LoadFarmerProfile>((event, emit) async {
      emit(FarmerLoading());
      try {
        // Try to load from SharedPreferences first
        final userData = SharedPrefsService.getUserData();
        if (userData != null) {
          // Convert userData to Farmer model if possible
          final farmer = Farmer(
            id: userData['_id'] ?? userData['id'] ?? '',
            name: userData['name'] ?? '',
            contactNumber:
                userData['contact'] ?? userData['contact_number'] ?? '',
            aadhaarNumber:
                userData['aadhaarNumber'] ?? userData['aadhaar_number'] ?? '',
            village: userData['village'] ?? '',
            landmark: userData['landMark'] ?? userData['landmark'] ?? '',
            taluka: userData['taluka'] ?? '',
            district: userData['district'] ?? '',
            pincode: userData['pincode'] ?? '',
            createdAt:
                DateTime.tryParse(userData['createdAt'] ?? '') ??
                DateTime.now(),
            updatedAt:
                DateTime.tryParse(userData['updatedAt'] ?? '') ??
                DateTime.now(),
          );
          emit(SingleFarmerLoaded(farmer));
          return;
        }

        // Fallback to database
        final farmer = await DatabaseService.getFarmerById(event.farmerId);
        if (farmer != null) {
          emit(SingleFarmerLoaded(farmer));
        } else {
          // Try API as last resort
          final apiFarmer = await DatabaseService.fetchFarmerByIdFromApi(
            event.farmerId,
          );
          if (apiFarmer != null) {
            await SharedPrefsService.saveFarmerData(apiFarmer.toMap());
            emit(SingleFarmerLoaded(apiFarmer));
          } else {
            emit(FarmerError('Farmer profile not found'));
          }
        }
      } catch (e) {
        emit(FarmerError('Failed to load profile: $e'));
      }
    });
  }
}
