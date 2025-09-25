import 'package:flutter_bloc/flutter_bloc.dart';
import 'crop_event.dart';
import 'crop_state.dart';
import '../../services/database_service.dart';

class CropBloc extends Bloc<CropEvent, CropState> {
  CropBloc() : super(CropInitial()) {
    on<LoadCrops>((event, emit) async {
      emit(CropLoading());
      try {
        final crops = await DatabaseService.getAllCrops();
        emit(CropLoaded(crops));
      } catch (e) {
        emit(CropError(e.toString()));
      }
    });

    on<LoadCropsByFarmer>((event, emit) async {
      emit(CropLoading());
      try {
        final crops = await DatabaseService.getCropsByFarmerId(event.farmerId);
        emit(CropLoaded(crops));
      } catch (e) {
        emit(CropError(e.toString()));
      }
    });

    on<AddCrop>((event, emit) async {
      try {
        await DatabaseService.insertCrop(event.crop);
        add(LoadCropsByFarmer(event.crop.farmerId));
      } catch (e) {
        emit(CropError(e.toString()));
      }
    });

    on<UpdateCrop>((event, emit) async {
      try {
        await DatabaseService.updateCrop(event.crop);
        add(LoadCropsByFarmer(event.crop.farmerId));
      } catch (e) {
        emit(CropError(e.toString()));
      }
    });

    on<DeleteCrop>((event, emit) async {
      try {
        await DatabaseService.deleteCrop(event.cropId);
        add(LoadCrops());
      } catch (e) {
        emit(CropError(e.toString()));
      }
    });

    on<LoadCropsByStatus>((event, emit) async {
      emit(CropLoading());
      try {
        final crops = await DatabaseService.getCropsByStatus(event.status);
        emit(CropLoaded(crops));
      } catch (e) {
        emit(CropError(e.toString()));
      }
    });

    on<GetCropById>((event, emit) async {
      emit(CropLoading());
      try {
        final crop = await DatabaseService.getCropById(event.cropId);
        if (crop != null) {
          emit(SingleCropLoaded(crop));
        } else {
          emit(CropError('Crop not found'));
        }
      } catch (e) {
        emit(CropError(e.toString()));
      }
    });
  }
}
