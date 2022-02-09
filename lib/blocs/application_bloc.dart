import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hdse_application/models/geometry.dart';
import 'package:hdse_application/models/location.dart';
import 'package:hdse_application/models/place.dart';
import 'package:hdse_application/models/place_detail.dart';
import 'package:hdse_application/models/place_search.dart';
import 'package:hdse_application/services/maps_service/geolocator_service.dart';
import 'package:hdse_application/services/maps_service/marker_service.dart';
import 'package:hdse_application/services/maps_service/places_service.dart';

class ApplicationBloc with ChangeNotifier {
  final geoLocatorService = GeolocatorService();
  final placesService = PlacesService();
  final markerService = MarkerService();

  //Variables
  Position? currentLocation;
  List<PlaceSearch>? searchResults;
  StreamController<Place> selectedLocation =
      StreamController<Place>.broadcast();
  StreamController<LatLngBounds> bounds =
      StreamController<LatLngBounds>.broadcast();
  Place? selectedLocationStatic;
  String? placeType;
  List<Place> placeResults = [];
  List<Marker> markers = List<Marker>.empty();
  PlaceDetail? placeDetail;

  ApplicationBloc() {
    setCurrentLocation();
    print(
        "selectedLocation.isClosed = " + selectedLocation.isClosed.toString());
  }

  setCurrentLocation() async {
    currentLocation = await geoLocatorService.getCurrentLocation();
    selectedLocationStatic = Place(
      name: null,
      geometry: Geometry(
        location: Location(
            lat: currentLocation!.latitude, lng: currentLocation!.longitude),
      ),
    );
    notifyListeners();
  }

  searchPlaces(String searchTerm) async {
    searchResults = await placesService.getAutocomplete(searchTerm);
    notifyListeners();
  }

  setSelectedLocation(String placeId) async {
    var sLocation = await placesService.getPlace(placeId);
    selectedLocation.add(sLocation);
    selectedLocationStatic = sLocation;
    searchResults = List<PlaceSearch>.empty();
    notifyListeners();
  }

  clearSelectedLocation() {
    selectedLocation.add(Place());
    selectedLocationStatic = Place();
    searchResults = List<PlaceSearch>.empty();
    placeType = "";
    notifyListeners();
  }

  togglePlaceType(String value, bool selected) async {
    if (selected) {
      placeType = value;
    } else {
      placeType = "";
    }

    if (placeType!.isNotEmpty) {
      placeResults = await placesService.getPlaces(
          selectedLocationStatic!.geometry!.location!.lat!,
          selectedLocationStatic!.geometry!.location!.lng!,
          placeType!);
      markers = [];
      if (placeResults.length > 0) {
        print("places.length > 0");
        placeResults.forEach((e) {
          print("places.map");
          var newMarker = markerService.createMarkerFromPlace(e, false);
          markers.add(newMarker);
          print("place add to markers");
        });
      }

      var locationMarker =
          markerService.createMarkerFromPlace(selectedLocationStatic!, true);

      markers.add(locationMarker);

      var _bounds = markerService.bounds(Set<Marker>.of(markers));
      bounds.add(_bounds);

      notifyListeners();
    }
  }

  getPlaceDetailToBloc(String placeID) async {
    placeDetail = await placesService.getPlaceDetail(placeID);
    notifyListeners();
  }

  clearPlaceDetail() {
    placeDetail = null;
  }

  @override
  void dispose() {
    print("applicationBloc.dispose");
    selectedLocation.close();
    print(
        "selectedLocation.isClosed = " + selectedLocation.isClosed.toString());
    bounds.close();
    super.dispose();
  }
}
