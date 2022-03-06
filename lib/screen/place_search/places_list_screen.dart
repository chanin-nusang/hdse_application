import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hdse_application/blocs/application_bloc.dart';
import 'package:hdse_application/screen/place_detail/place_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:page_transition/page_transition.dart';

class PlacesListScreen extends StatefulWidget {
  const PlacesListScreen({Key? key, this.title}) : super(key: key);
  final String? title;
  @override
  _PlacesListScreenState createState() => _PlacesListScreenState();
}

class _PlacesListScreenState extends State<PlacesListScreen> {
  get itemBuilder => null;
  var applicationBloc;
  @override
  void initState() {
    applicationBloc = Provider.of<ApplicationBloc>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("${widget.title} ใกล้คุณ"),
        ),
        body: Consumer<ApplicationBloc>(
          builder: (context, provider, Widget? child) {
            return Container(
              padding: EdgeInsets.all(10.0),
              child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  itemCount: provider.placeResults.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ElevatedButton(
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          )),
                          backgroundColor:
                              MaterialStateProperty.all(Colors.green[50]),
                        ),
                        onPressed: () {
                          print('inkwell ontap');
                          // applicationBloc.getPlaceDetailToBloc(
                          //     provider.placeResults[index].placeID);
                          Navigator.push(
                            context,
                            PageTransition(
                                duration: const Duration(milliseconds: 250),
                                reverseDuration:
                                    const Duration(milliseconds: 250),
                                type: PageTransitionType.rightToLeft,
                                child: new PlaceDetailScreen(
                                    placeID:
                                        provider.placeResults[index].placeID,
                                    isSeved: false)),
                            // new MaterialPageRoute(
                            //     builder: (context) => new PlaceDetailScreen(
                            //           placeID: provider
                            //               .placeResults[index].placeID,
                            //         ))
                          );
                        },
                        child: PlaceListTile(
                          name: provider.placeResults[index].name,
                          address: provider.placeResults[index].address,
                        ),
                      ),
                    );
                  }),
            );
          },
        ));
  }
}

class PlaceListTile extends StatelessWidget {
  const PlaceListTile({@required this.name, @required this.address});
  final String? name;
  final String? address;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name!,
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  address!,
                  style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                )
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: Colors.grey[600],
          )
        ],
      ),
    );
  }
}
