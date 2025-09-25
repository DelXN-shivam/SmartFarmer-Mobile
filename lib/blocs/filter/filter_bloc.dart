import 'package:flutter_bloc/flutter_bloc.dart';
import 'filter_event.dart';
import 'filter_state.dart';
import '../../services/database_service.dart';

class FilterBloc extends Bloc<FilterEvent, FilterState> {
  FilterBloc() : super(FilterInitial()) {
    on<LoadLocations>((event, emit) async {
      emit(FilterLoading());
      try {
        // Remove: final farmers = await DatabaseService.getAllFarmers();
        // Remove: logic for villages, talukas, districts from farmers

        emit(FilterLoaded(villages: [], talukas: [], districts: []));
      } catch (e) {
        emit(FilterError(e.toString()));
      }
    });
  }
}
