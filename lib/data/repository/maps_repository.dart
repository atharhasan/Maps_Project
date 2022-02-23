
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps/data/models/place_details.dart';
import 'package:maps/data/models/place_directions.dart';
import 'package:maps/data/models/place_suggestion.dart';
import 'package:maps/data/web_services/place_web_services.dart';

class MapsRepository {
 final PlaceWebServices placeWebServices;

  MapsRepository(this.placeWebServices);

  Future <List<dynamic>> fetchSuggestions(String place, String sessiontoken) async{
    final suggestions = await placeWebServices.fetchSuggestions(place, sessiontoken);

    return suggestions.map((suggestion) => PlaceSuggestion.fromJson(suggestion)).toList();
  }

 Future <PlaceDetails> getPlaceLocation(String placeId, String sessiontoken) async{
   final placeLocation = await placeWebServices.getPlaceLocation(placeId, sessiontoken);

   return PlaceDetails.fromJson(placeLocation);
 }

 Future <PlaceDirections> getPlaceDirections(LatLng origin, LatLng destination) async{
   final directions = await placeWebServices.getPlaceDirections(origin, destination);

   return PlaceDirections.fromJson(directions);
 }
}