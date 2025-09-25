import '../../models/farmer.dart';

abstract class FarmerEvent {
  const FarmerEvent();
}

class LoadFarmerById extends FarmerEvent {
  final String farmerId;
  LoadFarmerById(this.farmerId);
}

class RefreshFarmerProfile extends FarmerEvent {
  final String farmerId;
  RefreshFarmerProfile(this.farmerId);
}

class UpdateFarmerProfile extends FarmerEvent {
  final Farmer farmer;
  UpdateFarmerProfile(this.farmer);
}

class UpdateAllDataSources extends FarmerEvent {
  final Farmer farmer;
  UpdateAllDataSources(this.farmer);
}

class LoadFarmerProfile extends FarmerEvent {
  final String farmerId;
  LoadFarmerProfile(this.farmerId);
}
