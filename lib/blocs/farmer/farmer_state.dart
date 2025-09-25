import '../../models/farmer.dart';

abstract class FarmerState {
  const FarmerState();
}

class FarmerInitial extends FarmerState {}

class FarmerLoading extends FarmerState {}

class FarmerLoaded extends FarmerState {
  final List<Farmer> farmers;
  const FarmerLoaded(this.farmers);
}

class FarmerError extends FarmerState {
  final String message;
  const FarmerError(this.message);
}

class SingleFarmerLoaded extends FarmerState {
  final Farmer farmer;
  SingleFarmerLoaded(this.farmer);
}
