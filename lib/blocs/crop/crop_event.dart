import '../../models/crop.dart';

abstract class CropEvent {
  const CropEvent();
}

class LoadCrops extends CropEvent {}

class LoadCropsByFarmer extends CropEvent {
  final String farmerId;
  const LoadCropsByFarmer(this.farmerId);
}

class AddCrop extends CropEvent {
  final Crop crop;
  const AddCrop(this.crop);
}

class UpdateCrop extends CropEvent {
  final Crop crop;
  const UpdateCrop(this.crop);
}

class DeleteCrop extends CropEvent {
  final String cropId;
  const DeleteCrop(this.cropId);
}

class LoadCropsByStatus extends CropEvent {
  final String status;
  const LoadCropsByStatus(this.status);
}

class GetCropById extends CropEvent {
  final String cropId;
  const GetCropById(this.cropId);
}
