import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hdse_application/models/geometry.dart';
import 'package:hdse_application/models/location.dart';
import 'package:hdse_application/models/place.dart';
import 'package:hdse_application/models/place_detail.dart';
import 'package:hdse_application/models/place_search.dart';
import 'package:hdse_application/models/review.dart';
import 'package:hdse_application/services/maps_service/geolocator_service.dart';
import 'package:hdse_application/services/maps_service/marker_service.dart';
import 'package:hdse_application/services/maps_service/places_service.dart';
import 'dart:convert' as convert;

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
  PlaceDetail? archivedPlaceDetail;
  bool? isTogglePlaceType = false;
  List<ImageProvider> photos = [];
  List<String> photosPath = [];
  List<ImageProvider> photosArchived = [];
  List<String> photosPathArchived = [];
  bool isPlaceArchived = false;
  List<String> archivedPlaceIDList = [];
  List<DateTime> archivedPlaceSavedTimeList = [];
  List<String> archivedPlaceNameList = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool archivedPlaceListIsEmpty = false;
  int? archivedPlaceListIndexSelected;

  ApplicationBloc() {
    setCurrentLocation();
    print(
        "selectedLocation.isClosed = " + selectedLocation.isClosed.toString());
  }

  setArchivedPlaceListIndexSelected(int index) {
    archivedPlaceListIndexSelected = index;
    notifyListeners();
  }

  void deleteArchivedPlaceList() {
    archivedPlaceIDList = [];
    archivedPlaceSavedTimeList = [];
    archivedPlaceNameList = [];
    getArchivedPlaceList();
    notifyListeners();
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
    checkPlaceIDContainArchivedPlaceList(placeID);
    notifyListeners();
  }

  checkPlaceIDContainArchivedPlaceList(String placeID) async {
    if (_auth.currentUser != null) {
      final placeList = await FirebaseFirestore.instance
          .collection("users")
          .doc(_auth.currentUser!.uid)
          .get();
      var result = placeList.data()!;
      var pl = result['places'] as List;

      if (result['places'] != null && pl.length > 0) {
        var pll = pl.map((e) {
          return e['placeID'].toString();
        }).toList();
        if (pll.contains(placeID)) {
          isPlaceArchived = true;
          notifyListeners();
        }
      }
    }
  }

  getArchivedPlaceDetailToBloc(String placeID) async {
    final data = await FirebaseFirestore.instance
        .collection("places")
        .doc(placeID)
        .get();
    var placeMap = data.data();
    var typesMap = placeMap!['types'] as List;
    var typeThList = typesMap.map((e) => e.toString()).toList();
    archivedPlaceDetail = PlaceDetail(
      geometry: Geometry(
          location: Location(
              lat: placeMap['geometry']['location']['lat'],
              lng: placeMap['geometry']['location']['lng'])),
      address: placeMap['address'],
      businessStatus: placeMap['businessStatus'],
      phoneNumber: placeMap['phoneNumber'],
      name: placeMap['name'],
      openNow: null,
      weekdayOpen:
          (placeMap['weekdayOpen'] as List).map((e) => e.toString()).toList(),
      photoReferance: (placeMap['photoReferance'] as List)
          .map((e) => e.toString())
          .toList(),
      placeID: placeMap['placeID'],
      rating: placeMap['rating'],
      reviews: (placeMap['reviews'] as List)
          .map((e) => Review(
                authorName: e['authorName'],
                language: e['language'],
                profilePhotoURL: e['profilePhotoURL'],
                rating: e['rating'],
                relativeTimeDescription: e['relativeTimeDescription'],
                text: e['text'],
                time: e['time'],
              ))
          .toList(),
      types: typeThList,
      userRatingsTotal: placeMap['userRatingsTotal'],
      website: placeMap['website'],
    );
    if (archivedPlaceDetail!.photoReferance != null)
      archivedPlaceDetail!.photoReferance!.forEach((element) async {
        var url = await placesService.getPlacePhotos(element);
        photosArchived.add(CachedNetworkImageProvider(url));
        var file = await DefaultCacheManager().getSingleFile(url);
        photosPathArchived.add(file.path);
      });
    isPlaceArchived = true;
    notifyListeners();
  }

  clearPlaceDetail() {
    placeDetail = null;
    photos = [];
    photosPath = [];
    isPlaceArchived = false;
    print("clearPlaceDetail");
  }

  clearArchivedPlaceDetail() {
    archivedPlaceDetail = null;
    photosArchived = [];
    photosPathArchived = [];
    isPlaceArchived = false;
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

  void getArchivedPlaceList() async {
    final data = await FirebaseFirestore.instance
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .get(); //get the data
    var result = data.data()!;
    var mes = result['places'] as List;

    if (result['places'] != null && mes.length > 0) {
      mes.forEach((e) {
        archivedPlaceIDList.add(e['placeID'].toString());
        archivedPlaceSavedTimeList.add(e['savedTime'].toDate());
        archivedPlaceNameList.add(e['name'].toString());
      });
    } else
      archivedPlaceListIsEmpty = true;
    notifyListeners();
  }

  void clearArchivedPlaceList() {
    archivedPlaceListIsEmpty = false;
    archivedPlaceIDList = [];
    archivedPlaceSavedTimeList = [];
    archivedPlaceNameList = [];
  }

  void savePlaceToFireStore(BuildContext context) async {
    if (_auth.currentUser != null) {
      var userID = _auth.currentUser!.uid;
      try {
        await FirebaseFirestore.instance
            .collection("places")
            .doc(placeDetail!.placeID)
            .set({
          'geometry': {
            'location': {
              'lat': placeDetail!.geometry!.location!.lat,
              'lng': placeDetail!.geometry!.location!.lng
            }
          },
          'address': placeDetail!.address,
          'businessStatus': placeDetail!.businessStatus,
          'phoneNumber': placeDetail!.phoneNumber,
          'name': placeDetail!.name,
          'openNow': placeDetail!.openNow,
          'weekdayOpen':
              FieldValue.arrayUnion(placeDetail!.weekdayOpen as List),
          'photoReferance':
              FieldValue.arrayUnion(placeDetail!.photoReferance as List),
          'placeID': placeDetail!.placeID,
          'rating': placeDetail!.rating,
          'reviews': FieldValue.arrayUnion(placeDetail!.reviews!
              .map((review) => {
                    'authorName': review.authorName,
                    'language': review.language,
                    'profilePhotoURL': review.profilePhotoURL,
                    'rating': review.rating,
                    'relativeTimeDescription': review.relativeTimeDescription,
                    'text': review.text,
                    'time': review.time
                  })
              .toList()),
          'types': FieldValue.arrayUnion(placeDetail!.types as List),
          'userRatingsTotal': placeDetail!.userRatingsTotal,
          'website': placeDetail!.website
        });

        await FirebaseFirestore.instance
            .collection("users")
            .doc(userID)
            .update({
          'places': FieldValue.arrayUnion([
            {
              'placeID': placeDetail!.placeID,
              'savedTime': DateTime.now(),
              'name': placeDetail!.name
            }
          ])
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("บันทึกสถานที่สำเร็จ",
              style: GoogleFonts.sarabun(
                  textStyle: TextStyle(color: Colors.white, fontSize: 18))),
          backgroundColor: Colors.green,
        ));
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("ไม่สามารถบันทึกสถานที่ได้ โปรดลองอีกครั้ง",
              style: GoogleFonts.sarabun(
                  textStyle: TextStyle(color: Colors.white, fontSize: 18))),
          backgroundColor: Colors.red,
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("กรุณาลงชื่อเข้าใช้งาน",
            style: GoogleFonts.sarabun(
                textStyle: TextStyle(color: Colors.white, fontSize: 18))),
        backgroundColor: Colors.red,
      ));
    }
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
