
import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps/constants/strings.dart';

class PlaceWebServices {
late Dio dio;

PlaceWebServices(){
  BaseOptions options = BaseOptions(
    connectTimeout: 20 * 1000,
    receiveTimeout: 20 * 1000,
    receiveDataWhenStatusError: true,
  );
  dio = Dio(options);
}

Future <List<dynamic>> fetchSuggestions(String place , String sessiontoken) async {
  try {
    Response response = await dio.get(suggestionBaseURL,queryParameters: {
      'input' : place, 'type' : 'address', 'components' : 'country:eg',
      'key' : googleAPIKey, 'sessiontoken' : sessiontoken
    });
    return response.data['predictions'];
  }catch (error) {
    print (error.toString());
    return [];
  }
}
Future <dynamic> getPlaceLocation(String placeId , String sessiontoken) async {
  try {
    Response response = await dio.get(placeLocationBaseURL, queryParameters: {
      'place_id': placeId, 'fields': 'geometry',
      'key': googleAPIKey, 'sessiontoken': sessiontoken
    });
    return response.data;
  } catch (error) {
    return Future.error(
        "Place location error : ", StackTrace.fromString('this is its trace'));
  }
}

Future <dynamic> getPlaceDirections(LatLng origin, LatLng destination) async {
  try {
    Response response = await dio.get(placeDirectionBaseURL, queryParameters: {
      'origin': '${origin.latitude}, ${origin.longitude}',
      'destination': '${destination.latitude}, ${destination.longitude}',
      'key': googleAPIKey
    });
    return response.data;
  } catch (error) {
    return Future.error(
        "Place location error : ", StackTrace.fromString('this is its trace'));
  }
}
}