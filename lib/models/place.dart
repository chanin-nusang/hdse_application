import 'package:hdse_application/models/geometry.dart';

class Place {
  final Geometry? geometry;
  final String? name;
  final String? vicinity;
  final String? placeID;
  final String? address;

  Place({this.geometry, this.name, this.vicinity, this.placeID, this.address});

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
        geometry: Geometry.fromJson(json['geometry']),
        name: json['name'],
        vicinity: json['vicinity'],
        placeID: json['place_id'],
        address: json['formatted_address']);
  }
}
