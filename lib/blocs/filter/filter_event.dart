abstract class FilterEvent {
  const FilterEvent();
}

class LoadLocations extends FilterEvent {}

class FilterByLocation extends FilterEvent {
  final String? village;
  final String? taluka;
  final String? district;
  const FilterByLocation({this.village, this.taluka, this.district});
}

class ClearFilter extends FilterEvent {}
