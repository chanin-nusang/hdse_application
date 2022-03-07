import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hdse_application/models/place.dart';
import 'package:hdse_application/screen/place_detail/place_detail_screen.dart';
import 'package:page_transition/page_transition.dart';

class MarkerService {
  LatLngBounds bounds(Set<Marker> markers) {
    return createBounds(markers.map((m) => m.position).toList());
  } //0809642696

  LatLngBounds createBounds(List<LatLng> positions) {
    final southwestLat = positions.map((p) => p.latitude).reduce(
        (value, element) => value < element ? value : element); // smallest
    final southwestLon = positions
        .map((p) => p.longitude)
        .reduce((value, element) => value < element ? value : element);
    final northeastLat = positions.map((p) => p.latitude).reduce(
        (value, element) => value > element ? value : element); // biggest
    final northeastLon = positions
        .map((p) => p.longitude)
        .reduce((value, element) => value > element ? value : element);
    return LatLngBounds(
        southwest: LatLng(southwestLat, southwestLon),
        northeast: LatLng(northeastLat, northeastLon));
  }

  Marker createMarkerFromPlace(BuildContext context, Place place, bool center) {
    var markerId = place.name;
    if (center) markerId = 'center';

    return Marker(
        markerId: MarkerId(markerId!),
        draggable: false,
        visible: (center) ? false : true,
        infoWindow: InfoWindow(
          title: place.name,
          snippet: place.vicinity,
          onTap: () {
            Navigator.push(
              context,
              PageTransition(
                  duration: const Duration(milliseconds: 250),
                  reverseDuration: const Duration(milliseconds: 250),
                  type: PageTransitionType.rightToLeft,
                  child: new PlaceDetailScreen(
                      placeID: place.placeID, isSeved: false)),
              // new MaterialPageRoute(
              //     builder: (context) => new PlaceDetailScreen(
              //           placeID: provider
              //               .placeResults[index].placeID,
              //         ))
            );
          },
        ),
        position: LatLng(
            place.geometry!.location!.lat!, place.geometry!.location!.lng!));
  }
}
