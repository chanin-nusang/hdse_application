import 'package:hdse_application/models/geometry.dart';
import 'package:hdse_application/models/review.dart';

class PlaceDetail {
  final Geometry? geometry;
  final String? address;
  final String? businessStatus;
  final String? phoneNumber;
  final String? name;
  final bool? openNow;
  final List<String>? weekdayOpen;
  final List<String>? photoReferance;
  final String? placeID;
  final int? rating;
  final List<Review>? reviews;
  final List<String>? types;
  final int? userRatingsTotal;
  final String? website;

  PlaceDetail(
      {this.geometry,
      this.address,
      this.businessStatus,
      this.phoneNumber,
      this.name,
      this.openNow,
      this.weekdayOpen,
      this.photoReferance,
      this.placeID,
      this.rating,
      this.reviews,
      this.types,
      this.userRatingsTotal,
      this.website});

  factory PlaceDetail.fromJson(Map<String, dynamic> json) {
    var photosJson = json['photos'] as List;
    var reviewsJson = json['reviews'] as List;
    var weekdayOpenJson = json['opening_hours']['weekday_text'] as List;
    var typesJson = json['types'] as List;
    return PlaceDetail(
        geometry: Geometry.fromJson(json['geometry']),
        address: json['formatted_address'],
        businessStatus: json['business_status'],
        phoneNumber: json['formatted_phone_number'],
        name: json['name'],
        openNow: json['opening_hours']['open_now'],
        weekdayOpen: weekdayOpenJson.map((e) => e.toString()).toList(),
        photoReferance:
            photosJson.map((e) => e['photo_reference'].toString()).toList(),
        placeID: json['place_id'],
        rating: json['rating'],
        reviews: reviewsJson.map((e) => Review.fromJson(e)).toList(),
        types: typesJson.map((e) => e.toString()).toList(),
        userRatingsTotal: json['user_ratings_total'],
        website: json['website']);
  }
}
