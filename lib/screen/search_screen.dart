import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
            : ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _locationController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: 'Search by City',
                        suffixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) => applicationBloc.searchPlaces(value),
                      onTap: () => applicationBloc.clearSelectedLocation(),
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
                              itemCount: applicationBloc.searchResults!.length,
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
                    height: 20.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text('Find Nearest',
                            style: TextStyle(
                                fontSize: 25.0, fontWeight: FontWeight.bold)),
                        if (applicationBloc.placeResults.length > 0)
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.all(16.0),
                              primary: Colors.blue,
                              textStyle: const TextStyle(fontSize: 20),
                            ),
                            onPressed: () => Navigator.push(
                                context,
                                new MaterialPageRoute(
                                    builder: (context) => new PlacesScreen(
                                          title: typeSelected,
                                        ))),
                            child: const Text('แสดงทั้งหมด'),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Wrap(
                      spacing: 8.0,
                      children: [
                        FilterChip(
                          label: Text('Drugstore'),
                          onSelected: (val) {
                            typeSelected = 'Drugstore';
                            applicationBloc.togglePlaceType('drugstore', val);
                          },
                          selected: applicationBloc.placeType == 'drugstore',
                          selectedColor: Colors.blue,
                        ),
                        FilterChip(
                            label: Text('Hospital'),
                            onSelected: (val) {
                              typeSelected = 'Hospital';
                              applicationBloc.togglePlaceType('hospital', val);
                            },
                            selected: applicationBloc.placeType == 'hospital',
                            selectedColor: Colors.blue),
                        FilterChip(
                            label: Text('Pharmacy'),
                            onSelected: (val) {
                              typeSelected = 'Pharmacy';
                              applicationBloc.togglePlaceType('pharmacy', val);
                            },
                            selected: applicationBloc.placeType == 'pharmacy',
                            selectedColor: Colors.blue),
                        FilterChip(
                            label: Text('Insurance Agency'),
                            onSelected: (val) {
                              typeSelected = 'Insurance Agency';
                              applicationBloc.togglePlaceType(
                                  'insurance_agency', val);
                            },
                            selected:
                                applicationBloc.placeType == 'insurance_agency',
                            selectedColor: Colors.blue),
                        FilterChip(
                            label: Text('Physiotherapist'),
                            onSelected: (val) {
                              typeSelected = 'Physiotherapist';
                              applicationBloc.togglePlaceType(
                                  'physiotherapist', val);
                            },
                            selected:
                                applicationBloc.placeType == 'physiotherapist',
                            selectedColor: Colors.blue),
                        FilterChip(
                            label: Text('Park'),
                            onSelected: (val) {
                              typeSelected = 'Park';
                              applicationBloc.togglePlaceType('park', val);
                            },
                            selected: applicationBloc.placeType == 'park',
                            selectedColor: Colors.blue),
                      ],
                    ),
                  )
                ],
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
