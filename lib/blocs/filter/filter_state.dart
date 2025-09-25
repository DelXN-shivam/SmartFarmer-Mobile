abstract class FilterState {
  const FilterState();
}

class FilterInitial extends FilterState {}

class FilterLoading extends FilterState {}

class FilterLoaded extends FilterState {
  final List<String> villages;
  final List<String> talukas;
  final List<String> districts;
  final String? selectedVillage;
  final String? selectedTaluka;
  final String? selectedDistrict;

  const FilterLoaded({
    required this.villages,
    required this.talukas,
    required this.districts,
    this.selectedVillage,
    this.selectedTaluka,
    this.selectedDistrict,
  });
}

class FilterError extends FilterState {
  final String message;
  const FilterError(this.message);
}
