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

  factory PlaceDetail.fromJson(
      Map<String, dynamic> json, List<String> typeThList) {
    var photosJson = json['photos'] != null ? json['photos'] as List : null;
    var reviewsJson = json['reviews'] != null ? json['reviews'] as List : null;
    var weekdayOpenJson;
    var openNowJson;
    if (json['opening_hours'] != null) {
      weekdayOpenJson = json['opening_hours']['weekday_text'] != null
          ? json['opening_hours']['weekday_text'].cast<String>()
          : null;
      openNowJson = json['opening_hours']['open_now'] != null
          ? json['opening_hours']['open_now']
          : null;
    }

    var typesJson = json['types'] != null ? json['types'] as List : null;
    return PlaceDetail(
        geometry: Geometry.fromJson(json['geometry']),
        address: json['formatted_address'] != null
            ? json['formatted_address']
            : null,
        businessStatus:
            json['business_status'] != null ? json['business_status'] : null,
        phoneNumber: json['formatted_phone_number'] != null
            ? json['formatted_phone_number']
            : null,
        name: json['name'] != null ? json['name'] : null,
        openNow: openNowJson != null ? openNowJson : null,
        weekdayOpen: weekdayOpenJson != null ? weekdayOpenJson : null,
        photoReferance: photosJson != null
            ? photosJson.map((e) => e['photo_reference'].toString()).toList()
            : null,
        placeID: json['place_id'],
        rating: json['rating'],
        reviews: reviewsJson != null
            ? reviewsJson.map((e) => Review.fromJson(e)).toList()
            : null,
        types: typeThList,
        userRatingsTotal: json['user_ratings_total'] != null
            ? json['user_ratings_total']
            : null,
        website: json['website'] != null ? json['website'] : null);
  }
}
