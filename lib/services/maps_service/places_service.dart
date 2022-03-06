import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:hdse_application/models/place.dart';
import 'package:hdse_application/models/place_detail.dart';
import 'package:hdse_application/models/place_search.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class PlacesService {
  final key = 'AIzaSyB9Qes2do2r3mLjrlhe1C0gxSLKBy2LuhQ';

  Future<List<PlaceSearch>> getAutocomplete(String search) async {
    var url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$search&types=(cities)&key=$key';
    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var jsonResults = json['predictions'] as List;
    return jsonResults.map((place) => PlaceSearch.fromJson(place)).toList();
  }

  Future<Place> getPlace(String placeId) async {
    var url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$key';
    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var jsonResult = json['result'] as Map<String, dynamic>;
    return Place.fromJson(jsonResult);
  }

  Future<List<Place>> getPlaces(
      double lat, double lng, String placeType) async {
    var url =
        'https://maps.googleapis.com/maps/api/place/textsearch/json?language=th&location=$lat,$lng&type=$placeType&rankby=distance&key=$key';
    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var jsonResults = json['results'] as List;
    return jsonResults.map((place) => Place.fromJson(place)).toList();
  }

  Future<PlaceDetail> getPlaceDetail(String placeID) async {
    var url =
        'https://maps.googleapis.com/maps/api/place/details/json?language=th&fields=address_component,adr_address,business_status,formatted_address,geometry,icon,icon_mask_base_uri,icon_background_color,name,photo,place_id,plus_code,type,url,utc_offset,vicinity,formatted_phone_number,opening_hours,website,rating,review,user_ratings_total&place_id=$placeID&key=$key';
    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    // final String response =
    //     await rootBundle.loadString('assets/json/place_detail_th.json');
    // final json = await convert.jsonDecode(response);
    //-----***-----
    final String responseFromType =
        await rootBundle.loadString('assets/json/place_type.json');
    final jsonFromType = await convert.jsonDecode(responseFromType);
    var typeEnList = json['result']['types'] as List;
    var typeEnToTh = typeEnList
        .map((typeEn) => jsonFromType[typeEn] != null
            ? jsonFromType[typeEn].toString()
            : typeEn.toString())
        .toList();
    var jsonResults = json['result'];
    return PlaceDetail.fromJson(jsonResults, typeEnToTh);
  }

  Future<String> getPlacePhotos(String photoReferance) async {
    var url =
        'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=$photoReferance&key=$key';
    return url;
  }
}
