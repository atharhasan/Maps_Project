import 'package:bloc/bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps/data/models/place_details.dart';
import 'package:maps/data/models/place_directions.dart';
import 'package:maps/data/repository/maps_repository.dart';
import 'package:meta/meta.dart';

part 'maps_state.dart';

class MapsCubit extends Cubit<MapsState> {
  MapsCubit(this.mapsRepository) : super(MapsInitial());
  final MapsRepository mapsRepository;

  void emitPlaceSuggestions (String place, String sessiontoken) {
    mapsRepository.fetchSuggestions(place, sessiontoken).then((suggestions) {
      emit(PlacesLoaded(suggestions));
    });
  }

  void emitPlaceLocation (String placeId, String sessiontoken) {
    mapsRepository.getPlaceLocation(placeId, sessiontoken).then((placeDetails) {
      emit(PlaceLocationLoaded(placeDetails));
    });
  }

  void emitPlaceDirections (LatLng origin, LatLng destination) {
    mapsRepository.getPlaceDirections(origin, destination).then((placeDirections) {
      emit(PlaceDirectionLoaded(placeDirections));
    });
  }
}
