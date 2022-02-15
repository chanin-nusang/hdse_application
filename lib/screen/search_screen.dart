import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hdse_application/blocs/application_bloc.dart';
import 'package:hdse_application/models/place.dart';
import 'package:hdse_application/screen/places_screen.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  Completer<GoogleMapController> _mapController = Completer();
  StreamSubscription? locationSubscription;
  StreamSubscription? boundsSubscription;
  final _locationController = TextEditingController();
  var applicationBloc;
  String? typeSelected;
  @override
  void initState() {
    applicationBloc = Provider.of<ApplicationBloc>(context, listen: false);

    //Listen for selected Location

    locationSubscription =
        applicationBloc.selectedLocation.stream.listen((place) {
      _locationController.text = place.name!;

      _locationController.text = "";
    });

    boundsSubscription = applicationBloc.bounds.stream.listen((bounds) async {
      final GoogleMapController controller = await _mapController.future;
      controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    });
    super.initState();
  }

  @override
  void dispose() {
    // final applicationBloc =
    //     Provider.of<ApplicationBloc>(context, listen: false);
    applicationBloc.dispose();
    _locationController.dispose();
    locationSubscription!.cancel();
    boundsSubscription!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final applicationBloc = Provider.of<ApplicationBloc>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text("ค้นหาสถานที่ให้บริการด้านสุขภาพ"),
        ),
        body: (applicationBloc.currentLocation == null)
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Container(
                child: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 18.0, right: 18, top: 18, bottom: 5),
                      child: Container(
                        height: 50,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            )),
                        child: TextField(
                          controller: _locationController,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            hintText: 'ค้นหาโดยเมือง',
                            suffixIcon: Icon(Icons.search),
                          ),
                          onChanged: (value) =>
                              applicationBloc.searchPlaces(value),
                          onTap: () => applicationBloc.clearSelectedLocation(),
                        ),
                      ),
                    ),
                    Stack(
                      children: [
                        Container(
                          height: 300.0,
                          child: GoogleMap(
                            mapType: MapType.normal,
                            myLocationEnabled: true,
                            initialCameraPosition: CameraPosition(
                              target: LatLng(
                                  applicationBloc.currentLocation!.latitude,
                                  applicationBloc.currentLocation!.longitude),
                              zoom: 14,
                            ),
                            onMapCreated: (GoogleMapController controller) {
                              _mapController.complete(controller);
                            },
                            markers: Set<Marker>.of(applicationBloc.markers),
                          ),
                        ),
                        if (applicationBloc.searchResults != null &&
                            applicationBloc.searchResults!.length != 0)
                          Container(
                              height: 300.0,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(.6),
                                  backgroundBlendMode: BlendMode.darken)),
                        if (applicationBloc.searchResults != null)
                          Container(
                            height: 300.0,
                            child: ListView.builder(
                                itemCount:
                                    applicationBloc.searchResults!.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(
                                      applicationBloc
                                          .searchResults![index].description!,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    onTap: () {
                                      applicationBloc.setSelectedLocation(
                                          applicationBloc
                                              .searchResults![index].placeId!);
                                    },
                                  );
                                }),
                          ),
                      ],
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 18.0, right: 18, top: 18, bottom: 18),
                      child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              )),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('ค้นหาบริเวณใกล้เคียง',
                                        style: TextStyle(
                                            fontSize: 22.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green[600])),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Wrap(
                                  spacing: 8.0,
                                  children: [
                                    FilterChip(
                                      label: Text('ร้านขายยา'),
                                      onSelected: (val) {
                                        typeSelected = 'ร้านขายยา';
                                        applicationBloc.togglePlaceType(
                                            'drugstore', val);
                                      },
                                      selected: applicationBloc.placeType ==
                                          'drugstore',
                                      selectedColor: Colors.green[300],
                                    ),
                                    FilterChip(
                                        label: Text('โรงพยาบาล'),
                                        onSelected: (val) {
                                          typeSelected = 'โรงพยาบาล';
                                          applicationBloc.togglePlaceType(
                                              'hospital', val);
                                        },
                                        selected: applicationBloc.placeType ==
                                            'hospital',
                                        selectedColor: Colors.green[300]),
                                    FilterChip(
                                        label: Text('เภสัชกรรม'),
                                        onSelected: (val) {
                                          typeSelected = 'เภสัชกรรม';
                                          applicationBloc.togglePlaceType(
                                              'pharmacy', val);
                                        },
                                        selected: applicationBloc.placeType ==
                                            'pharmacy',
                                        selectedColor: Colors.green[300]),
                                    FilterChip(
                                        label: Text('ตัวแทนประกันภัย'),
                                        onSelected: (val) {
                                          typeSelected = 'ตัวแทนประกันภัย';
                                          applicationBloc.togglePlaceType(
                                              'insurance_agency', val);
                                        },
                                        selected: applicationBloc.placeType ==
                                            'insurance_agency',
                                        selectedColor: Colors.green[300]),
                                    FilterChip(
                                        label: Text('กายภาพบำบัด'),
                                        onSelected: (val) {
                                          typeSelected = 'กายภาพบำบัด';
                                          applicationBloc.togglePlaceType(
                                              'physiotherapist', val);
                                        },
                                        selected: applicationBloc.placeType ==
                                            'physiotherapist',
                                        selectedColor: Colors.green[300]),
                                    FilterChip(
                                        label: Text('สวนสาธารณะ'),
                                        onSelected: (val) {
                                          typeSelected = 'สวนสาธารณะ';
                                          applicationBloc.togglePlaceType(
                                              'park', val);
                                        },
                                        selected:
                                            applicationBloc.placeType == 'park',
                                        selectedColor: Colors.green[300]),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 5.0,
                              ),
                              if (applicationBloc.placeResults.length > 0)
                                Container(
                                  height: 30,
                                  width: 120,
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                        padding: MaterialStateProperty.resolveWith<EdgeInsetsGeometry>(
                                            (Set<MaterialState> states) =>
                                                EdgeInsets.all(0)),
                                        foregroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.white),
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.white),
                                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20.0),
                                                side: BorderSide(color: Colors.green)))),
                                    onPressed: () => Navigator.push(
                                        context,
                                        new MaterialPageRoute(
                                            builder: (context) =>
                                                new PlacesScreen(
                                                  title: typeSelected,
                                                ))),
                                    child: Text(
                                      'แสดงทั้งหมด',
                                      style: GoogleFonts.sarabun(
                                          textStyle: TextStyle(
                                              color: Colors.green,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    // TextButton(
                                    //   style: TextButton.styleFrom(
                                    //       padding: EdgeInsets.zero,
                                    //       minimumSize: Size(50, 30),
                                    //       alignment: Alignment.centerLeft),
                                    //   onPressed: () => Navigator.push(
                                    //       context,
                                    //       new MaterialPageRoute(
                                    //           builder: (context) => new PlacesScreen(
                                    //                 title: typeSelected,
                                    //               ))),
                                    //   child: Text(
                                    //     'แสดงทั้งหมด',
                                    //     style: GoogleFonts.sarabun(
                                    //         textStyle: TextStyle(
                                    //             color: Colors.blue, fontSize: 15)),
                                    //   ),
                                    // ),
                                  ),
                                ),
                            ],
                          )),
                    ),
                  ],
                ),
              ));
  }

  Future<void> _goToPlace(Place place) async {
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(
                place.geometry!.location!.lat!, place.geometry!.location!.lng!),
            zoom: 14.0),
      ),
    );
  }
}
