import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hdse_application/blocs/application_bloc.dart';
import 'package:hdse_application/models/place.dart';
import 'package:hdse_application/screen/place_search/places_list_screen.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // Completer<GoogleMapController> _mapController = Completer();
  StreamSubscription? locationSubscription;
  StreamSubscription? boundsSubscription;
  final _locationController = TextEditingController();
  var applicationBloc;
  String? typeSelected;
  String? selectedLocation = 'ตำแหน่งปัจจุบันของคุณ';

  @override
  void initState() {
    print("bounds.hasListener before init: " +
        Provider.of<ApplicationBloc>(context, listen: false)
            .bounds
            .hasListener
            .toString());
    applicationBloc = Provider.of<ApplicationBloc>(context, listen: false);

    //Listen for selected Location

    locationSubscription =
        applicationBloc.selectedLocation.stream.listen((place) {
      _locationController.text = place.name!;

      _locationController.text = "";
    });

    boundsSubscription = applicationBloc.bounds.stream.listen((bounds) async {
      final GoogleMapController controller =
          await applicationBloc.mapController.future;
      controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    });
    print("bounds.hasListener after init: " +
        Provider.of<ApplicationBloc>(context, listen: false)
            .bounds
            .hasListener
            .toString());
    super.initState();
  }

  @override
  void dispose() {
    // final applicationBloc =
    //     Provider.of<ApplicationBloc>(context, listen: false);
    applicationBloc.clearPlaceBoundsAndPlaceTypeWithoutNotityListeners();

    _locationController.dispose(); //TextEditingController
    locationSubscription!.cancel();
    boundsSubscription!.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final applicationBloc = Provider.of<ApplicationBloc>(context);
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
          appBar: AppBar(
            title: Text("ค้นหาสถานที่ให้บริการด้านสุขภาพ"),
          ),
          body: (applicationBloc.currentLocation == null)
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Consumer<ApplicationBloc>(
                  builder: (context, provider, Widget? child) {
                  return Container(
                    child: ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 18.0, right: 18, top: 18, bottom: 5),
                          child: Container(
                            // height: 100,
                            padding: EdgeInsets.only(
                                left: 10, right: 10, bottom: 10, top: 0),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10.0),
                                )),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  height: 35,
                                  child: TextField(
                                    controller: _locationController,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    decoration: InputDecoration(
                                      hintText: 'ค้นหาโดยเมือง',
                                      suffixIcon: Icon(Icons.search),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 10),
                                    ),
                                    onChanged: (value) =>
                                        applicationBloc.searchPlaces(value),
                                    onTap: () =>
                                        applicationBloc.clearSelectedLocation(),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                RichText(
                                    text: TextSpan(
                                        text: "เมืองที่เลือก : ",
                                        style: GoogleFonts.sarabun(
                                            textStyle: TextStyle(
                                                color: Colors.grey[700],
                                                fontSize: 16 *
                                                    MediaQuery.of(context)
                                                        .textScaleFactor)),
                                        children: <TextSpan>[
                                      TextSpan(
                                          text: selectedLocation!,
                                          style: GoogleFonts.sarabun(
                                              textStyle: TextStyle(
                                                  color: Colors.green[600],
                                                  fontSize: 16))),
                                    ])),
                              ],
                            ),
                          ),
                        ),
                        Stack(
                          children: [
                            Container(
                              height: 330.0,
                              child: GoogleMap(
                                mapType: MapType.normal,
                                myLocationEnabled: true,
                                myLocationButtonEnabled: false,
                                initialCameraPosition: CameraPosition(
                                  target: LatLng(
                                      applicationBloc.currentLocation!.latitude,
                                      applicationBloc
                                          .currentLocation!.longitude),
                                  zoom: 14,
                                ),
                                onMapCreated: (GoogleMapController controller) {
                                  if (!applicationBloc
                                      .mapController.isCompleted)
                                    applicationBloc.mapController
                                        .complete(controller);
                                },
                                markers:
                                    Set<Marker>.of(applicationBloc.markers),
                              ),
                            ),
                            Align(
                              alignment: Alignment.topRight,
                              child: Container(
                                  margin:
                                      EdgeInsets.fromLTRB(0.0, 10.0, 10.0, 0.0),
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        height: 30 *
                                            MediaQuery.of(context)
                                                .textScaleFactor,
                                        width: 140 *
                                            MediaQuery.of(context)
                                                .textScaleFactor,
                                        child: ElevatedButton(
                                          style: ButtonStyle(
                                            padding: MaterialStateProperty
                                                .resolveWith<
                                                        EdgeInsetsGeometry>(
                                                    (Set<MaterialState>
                                                            states) =>
                                                        EdgeInsets.all(0)),
                                            foregroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(Colors.white),
                                            backgroundColor:
                                                MaterialStateProperty
                                                    .all<Color>(Colors.white
                                                        .withOpacity(0.82)),
                                          ),
                                          onPressed: () {
                                            selectedLocation =
                                                'ตำแหน่งปัจจุบันของคุณ';
                                            applicationBloc
                                                .clearPlaceBoundsAndPlaceType();
                                            applicationBloc.goToMyLocation();
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.my_location,
                                                color: Colors.grey[700],
                                              ),
                                              Text(
                                                ' ตำแหน่งปัจจุบัน',
                                                style: GoogleFonts.sarabun(
                                                    textStyle: TextStyle(
                                                        color: Colors.grey[700],
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  )),
                            ),
                            if (applicationBloc.searchResults != null &&
                                applicationBloc.searchResults!.length != 0)
                              Container(
                                  height: 330.0,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(.6),
                                      backgroundBlendMode: BlendMode.darken)),
                            if (applicationBloc.searchResults != null)
                              Container(
                                height: 330.0,
                                child: ListView.separated(
                                    separatorBuilder:
                                        (BuildContext context, int index) =>
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 15, right: 15),
                                              child: Divider(
                                                color: Colors.white,
                                              ),
                                            ),
                                    itemCount:
                                        applicationBloc.searchResults!.length,
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        title: Text(
                                          applicationBloc.searchResults![index]
                                              .description!,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        onTap: () {
                                          _locationController.clear();
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();
                                          selectedLocation = applicationBloc
                                              .searchResults![index]
                                              .description!;
                                          applicationBloc.setSelectedLocation(
                                              applicationBloc
                                                  .searchResults![index]
                                                  .placeId!);
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
                              left: 18.0, right: 18, top: 5, bottom: 18),
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
                                        provider.isTogglePlaceType!
                                            ? Container(
                                                height: 20,
                                                width: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 3.0,
                                                ))
                                            : SizedBox()
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Wrap(
                                      runSpacing: -8.0,
                                      spacing: 8.0,
                                      children: [
                                        FilterChip(
                                          label: Text('ร้านขายยา'),
                                          onSelected: (val) {
                                            print('val : ' + val.toString());

                                            if (val) {
                                              applicationBloc
                                                  .clearPlaceBoundsAndPlaceType();
                                              typeSelected = 'ร้านขายยา';
                                              applicationBloc.togglePlaceType(
                                                  'drugstore', val);
                                              applicationBloc
                                                  .setIsTogglePlaceTypeToTrue();
                                            } else
                                              applicationBloc
                                                  .clearPlaceBoundsAndPlaceType();
                                          },
                                          selected: applicationBloc.placeType ==
                                              'drugstore',
                                          selectedColor: Colors.green[300],
                                        ),
                                        FilterChip(
                                            label: Text('โรงพยาบาล'),
                                            onSelected: (val) {
                                              if (val) {
                                                applicationBloc
                                                    .clearPlaceBoundsAndPlaceType();
                                                typeSelected = 'โรงพยาบาล';
                                                applicationBloc.togglePlaceType(
                                                    'hospital', val);
                                                applicationBloc
                                                    .setIsTogglePlaceTypeToTrue();
                                              } else
                                                applicationBloc
                                                    .clearPlaceBoundsAndPlaceType();
                                            },
                                            selected:
                                                applicationBloc.placeType ==
                                                    'hospital',
                                            selectedColor: Colors.green[300]),
                                        FilterChip(
                                            label: Text('เภสัชกรรม'),
                                            onSelected: (val) {
                                              if (val) {
                                                applicationBloc
                                                    .clearPlaceBoundsAndPlaceType();
                                                typeSelected = 'เภสัชกรรม';
                                                applicationBloc.togglePlaceType(
                                                    'pharmacy', val);
                                                applicationBloc
                                                    .setIsTogglePlaceTypeToTrue();
                                              } else
                                                applicationBloc
                                                    .clearPlaceBoundsAndPlaceType();
                                            },
                                            selected:
                                                applicationBloc.placeType ==
                                                    'pharmacy',
                                            selectedColor: Colors.green[300]),
                                        FilterChip(
                                            label: Text('ตัวแทนประกันภัย'),
                                            onSelected: (val) {
                                              if (val) {
                                                applicationBloc
                                                    .clearPlaceBoundsAndPlaceType();
                                                typeSelected =
                                                    'ตัวแทนประกันภัย';
                                                applicationBloc.togglePlaceType(
                                                    'insurance_agency', val);
                                                applicationBloc
                                                    .setIsTogglePlaceTypeToTrue();
                                              } else
                                                applicationBloc
                                                    .clearPlaceBoundsAndPlaceType();
                                            },
                                            selected:
                                                applicationBloc.placeType ==
                                                    'insurance_agency',
                                            selectedColor: Colors.green[300]),
                                        FilterChip(
                                            label: Text('กายภาพบำบัด'),
                                            onSelected: (val) {
                                              if (val) {
                                                applicationBloc
                                                    .clearPlaceBoundsAndPlaceType();
                                                typeSelected = 'กายภาพบำบัด';
                                                applicationBloc.togglePlaceType(
                                                    'physiotherapist', val);
                                                applicationBloc
                                                    .setIsTogglePlaceTypeToTrue();
                                              } else
                                                applicationBloc
                                                    .clearPlaceBoundsAndPlaceType();
                                            },
                                            selected:
                                                applicationBloc.placeType ==
                                                    'physiotherapist',
                                            selectedColor: Colors.green[300]),
                                        FilterChip(
                                            label: Text('สวนสาธารณะ'),
                                            onSelected: (val) {
                                              if (val) {
                                                applicationBloc
                                                    .clearPlaceBoundsAndPlaceType();
                                                typeSelected = 'สวนสาธารณะ';
                                                applicationBloc.togglePlaceType(
                                                    'park', val);
                                                applicationBloc
                                                    .setIsTogglePlaceTypeToTrue();
                                              } else
                                                applicationBloc
                                                    .clearPlaceBoundsAndPlaceType();
                                            },
                                            selected:
                                                applicationBloc.placeType ==
                                                    'park',
                                            selectedColor: Colors.green[300]),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 0.0,
                                  ),
                                  if (applicationBloc.placeResults.length > 0 &&
                                      provider.placeType != null)
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
                                                    new PlacesListScreen(
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
                  );
                })),
    );
  }

  Future<void> _goToPlace(Place place) async {
    final GoogleMapController controller =
        await applicationBloc.mapController.future;
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
