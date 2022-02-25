import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
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
  Completer<GoogleMapController> mapController = Completer();
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
  bool? isTogglePlaceType = false;
  List<ImageProvider> photos = [];
  List<String> photosPath = [];

  ApplicationBloc() {
    setCurrentLocation();
    print(
        "selectedLocation.isClosed = " + selectedLocation.isClosed.toString());
  }
  setIsTogglePlaceTypeToTrue() {
    isTogglePlaceType = true;
    notifyListeners();
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

  goToMyLocation() async {
    setCurrentLocation();
    final GoogleMapController controller = await mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(currentLocation!.latitude, currentLocation!.longitude),
        zoom: 14,
      ),
    ));
    notifyListeners();
  }

  searchPlaces(String searchTerm) async {
    searchResults = await placesService.getAutocomplete(searchTerm);
    notifyListeners();
  }

  setSelectedLocation(String placeId) async {
    searchResults = null;
    notifyListeners();
    var sLocation = await placesService.getPlace(placeId);
    // selectedLocation.add(sLocation);
    selectedLocationStatic = sLocation;

    // var newMarker =
    //     markerService.createMarkerFromPlace(selectedLocationStatic!, false);
    // var _bounds = markerService.bounds(Set<Marker>.of([newMarker]));
    // bounds.add(_bounds);

    final GoogleMapController controller = await mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(selectedLocationStatic!.geometry!.location!.lat!,
            selectedLocationStatic!.geometry!.location!.lng!),
        zoom: 14,
      ),
    ));
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
    // isTogglePlaceType = true;
    print('isTogglePlaceType = true;');
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
      isTogglePlaceType = false;
      print('isTogglePlaceType = false;');
      notifyListeners();
    }
  }

  getPlaceDetailToBloc(String placeID) async {
    placeDetail = await placesService.getPlaceDetail(placeID);
    if (placeDetail!.photoReferance != null)
      placeDetail!.photoReferance!.forEach((element) async {
        var url = await placesService.getPlacePhotos(element);
        photos.add(CachedNetworkImageProvider(url));
        var file = await DefaultCacheManager().getSingleFile(url);
        photosPath.add(file.path);
      });
    notifyListeners();
  }

  clearPlaceDetail() {
    placeDetail = null;
    photos = [];
    photosPath = [];
    print("clearPlaceDetail");
  }

  clearPlaceBoundsAndPlaceType() {
    placeType = null;
    markers = [];
    notifyListeners();
    // bounds = StreamController<LatLngBounds>.broadcast();
  }

  clearPlaceBoundsAndPlaceTypeWithoutNotityListeners() {
    placeType = null;
    markers = [];
  }

  @override
  void dispose() {
    print("applicationBloc.dispose");
    // selectedLocation.close();
    placeType = null;

    print(
        "selectedLocation.isClosed = " + selectedLocation.isClosed.toString());
    // bounds.close();
    super.dispose();
  }
}
