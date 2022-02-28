import 'package:flutter/services.dart';
import 'dart:convert' as convert;

class PlaceTypeTranslate {
  Future<List<String>> getPlaceTypeTranslate(List<String> typeEn) async {
    final String response =
        await rootBundle.loadString('assets/json/place_type.json');
    final json = await convert.jsonDecode(response);
    var typeEnToTh =
        typeEn.map((e) => json[e] != null ? json[e].toString() : e).toList();

    return typeEnToTh;
  }
}
