import '../../models/crop.dart';

abstract class CropState {
  const CropState();
}

class CropInitial extends CropState {}

class CropLoading extends CropState {}

class CropLoaded extends CropState {
  final List<Crop> crops;
  const CropLoaded(this.crops);
}

class SingleCropLoaded extends CropState {
  final Crop crop;
  const SingleCropLoaded(this.crop);
}

class CropError extends CropState {
  final String message;
  const CropError(this.message);
}
