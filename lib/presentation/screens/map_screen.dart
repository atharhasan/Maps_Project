import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps/business_logic/cubit/maps_cubit/maps_cubit.dart';
import 'package:maps/constants/app_colors.dart';
import 'package:maps/data/models/place_details.dart';
import 'package:maps/data/models/place_directions.dart';
import 'package:maps/data/models/place_suggestion.dart';
import 'package:maps/helpers/location_helper.dart';
import 'package:maps/presentation/widgets/app_drawer.dart';
import 'package:maps/presentation/widgets/distance_time.dart';
import 'package:maps/presentation/widgets/place_item.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:uuid/uuid.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static Position? position;
  List<dynamic> places = [];
  FloatingSearchBarController controller = FloatingSearchBarController();
  final Completer<GoogleMapController> _mapController = Completer();
  static final CameraPosition _currentCameraPosition = CameraPosition(
    bearing: 0.0,
    target: LatLng(position!.latitude,position!.longitude),
    tilt: 0.0,
    zoom: 17,
      );

  // these variables for get place location
  // ignore: prefer_collection_literals
  Set<Marker> markers = Set();
  late PlaceSuggestion placeSuggestion;
  late PlaceDetails selectedPlace;
  late Marker searchedPlaceMarker;
  late Marker myCurrentLocationMarker;
  late CameraPosition goToSearchedForPlace;

  //to build new position of camera that we searched it.
  void buildCameraNewPosition() {
    goToSearchedForPlace = CameraPosition(
      bearing: 0.0,
      tilt: 0.0,
      target: LatLng(selectedPlace.result.geometry.location.lat,
      selectedPlace.result.geometry.location.lng),
      zoom: 13,
    );
  }

  // these variables for get place directions
  PlaceDirections? placeDirections;
  var progressIndicator = false;
  late List<LatLng> polylinePoints;
  var isSearchedPlaceMarkerClicked = false;
  var isTimeAndDistanceVisible = false;
  late String time;
  late String distance;


// to determine my current location on the map by geolocator library.
  Future <void> getCurrentLocation () async {
   position = await LocationHelper.getCurrentLocation().whenComplete(() {
      setState(() {});
    });
  }
//that method to go to my current location.
  Future<void> _goToMyCurrentLocation () async {
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_currentCameraPosition));
  }

  // that widget to build suggestion bloc that call the suggestion places.
  Widget buildSuggestionBloc() {
    return BlocBuilder<MapsCubit,MapsState>(
        builder: (context, state) {
          if (state is PlacesLoaded){
            places = (state).places;

            if (places.isNotEmpty){
              return buildPlacesList();
            }else{
              return Container();
            }
          }else {
            return Container();
          }
        }
    );
  }
//that widget to build the list that show suggestion places that we searched for it.
  Widget buildPlacesList() {
    return ListView.builder(
      itemBuilder: (cxt, index) {
        return InkWell(
          onTap: () async {
            placeSuggestion = places[index];
            controller.close();
            getSelectedPlaceLocation();
            polylinePoints.clear();
            removeAllMarkersAndUpdateUI();
          },
          child: PlaceItem(suggestion: places[index],),
        );
      },
      itemCount: places.length,
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
    );
  }
  
  void removeAllMarkersAndUpdateUI () {
    setState(() {
      markers.clear();
    });
  }

  //that function to get place location for the place we selected by calling bloc.
  void getSelectedPlaceLocation() {
    final sessionToken = const Uuid().v4();
    BlocProvider.of<MapsCubit>(context).emitPlaceLocation(placeSuggestion.placeId, sessionToken);
  }
//that function to get places suggestion that we searched by calling bloc.
  void getPlacesSuggestions(String query) {
    final sessionToken = const Uuid().v4();
    BlocProvider.of<MapsCubit>(context).emitPlaceSuggestions(query, sessionToken);
  }
// this widget to build and call selected place location by bloc .
  Widget buildSelectedPlaceLocationBloc() {
    return BlocListener<MapsCubit,MapsState>(
      listener: (context, state) {
        if (state is PlaceLocationLoaded) {
          selectedPlace = state.placeDetails;

          goToMySearchedLocation();
          getDirections();
        }
      },
      child: Container(),
    );
  }

  Widget buildDirectionsBloc() {
    return BlocListener<MapsCubit,MapsState>(
      listener: (context, state) {
        if (state is PlaceDirectionLoaded) {
          placeDirections = state.placeDirections;

          getPolylinePoints();
        }
      },
      child: Container(),
    );
  }

  void getPolylinePoints() {
    polylinePoints = placeDirections!.polylinePoints.map((e) =>
        LatLng(e.latitude, e.longitude)).toList();
  }

  //this function to go to the place location that i searched it.
  Future<void> goToMySearchedLocation() async {
    buildCameraNewPosition();
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(goToSearchedForPlace));
    buildSearchedPlaceMarker();
  }

  void getDirections(){
    BlocProvider.of<MapsCubit>(context).emitPlaceDirections(LatLng(position!.latitude, position!.longitude),
        LatLng(selectedPlace.result.geometry.location.lat, selectedPlace.result.geometry.location.lng));
  }
// this function to build marker on the place location i searched it.
  void buildSearchedPlaceMarker() {
    searchedPlaceMarker = Marker(
      markerId: const MarkerId('1'),
      position: goToSearchedForPlace.target,
      onTap: (){
        buildCurrentLocationMarker();

        // show time and distance.
        setState(() {
          isSearchedPlaceMarkerClicked = true;
          isTimeAndDistanceVisible = true;
        });
      },
      infoWindow: InfoWindow(
        title: placeSuggestion.description,
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
    addMarkerToMarkersAndUpdateUI(searchedPlaceMarker);
  }
// this function to build marker on my current location.
  void buildCurrentLocationMarker() {
    myCurrentLocationMarker = Marker(
      markerId: const MarkerId('2'),
      position: LatLng(position!.latitude,position!.longitude),
      infoWindow: const InfoWindow(title: 'Your Current Location'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );
    addMarkerToMarkersAndUpdateUI(myCurrentLocationMarker);
  }
//this function to add markers and refresh the UI.
  void addMarkerToMarkersAndUpdateUI(Marker marker) {
    setState(() {
      markers.add(marker);
    });
  }
//this widget to build floating search bar.
  Widget buildFloatingSearchBar() {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return FloatingSearchBar(
      controller: controller,
      elevation: 6,
      hintStyle: const TextStyle(fontSize: 18),
      queryStyle: const TextStyle(fontSize: 18),
      hint: 'find a place',
      border: const BorderSide(style: BorderStyle.none),
      margins: const EdgeInsets.fromLTRB(20, 70, 20, 0),
      padding: const EdgeInsets.only(left: 2,right: 2),
      height: 52,
      iconColor: AppColors.blue,
      scrollPadding: const EdgeInsets.only(top: 16,bottom: 56),
      transitionDuration: const Duration(milliseconds: 600),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: isPortrait ? 0.0 : -1.0,
      openAxisAlignment: 0.0,
      width: isPortrait ? 600 : 500,
      debounceDelay: const Duration(milliseconds: 500),
      progress: progressIndicator,
      onQueryChanged: (query) {
        getPlacesSuggestions(query);
      },
      onFocusChanged: (_) {
        // hide distance and time row.
        setState(() {
          isTimeAndDistanceVisible = false;
        });
      },
      transition: CircularFloatingSearchBarTransition(),
      actions: [
        FloatingSearchBarAction(
          showIfOpened: false,
          child: CircularButton(icon: Icon(Icons.place , color: Colors.black.withOpacity(0.6)),onPressed: (){},),),

      ],
      builder: (context, transition) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            buildSuggestionBloc(),
            buildSelectedPlaceLocationBloc(),
            buildDirectionsBloc(),
          ],
        ),
        );
      },
    );
  }

  Widget buildMap (){
    return GoogleMap(
      mapType: MapType.normal,
        markers: markers,
        myLocationButtonEnabled: false,
        myLocationEnabled: true,
        zoomControlsEnabled: false,
        initialCameraPosition: _currentCameraPosition,
        onMapCreated: (GoogleMapController controller){
          _mapController.complete(controller);
    },
      polylines: placeDirections != null ? {
        Polyline(
            polylineId: const PolylineId('my_polyline'),
          color: Colors.black,
          width: 2,
          points: polylinePoints,
        ),
      } : {},
    );
  }
// call getCurrentLocation method.
  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      body: Stack(
        fit: StackFit.expand,
        children: [
          position != null ? buildMap() : const Center(
            child: CircularProgressIndicator(color: AppColors.blue,),),
          buildFloatingSearchBar(),
          isSearchedPlaceMarkerClicked ? DistanceTime(isTimeAndDistanceVisible: isTimeAndDistanceVisible,
            placeDirections: placeDirections,) : Container(),
        ],
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 8, 30),
        child: FloatingActionButton(
          backgroundColor: AppColors.blue,
          onPressed: _goToMyCurrentLocation,
          child: const Icon(Icons.place,color: Colors.white,),
        ),),
    );
  }
}
