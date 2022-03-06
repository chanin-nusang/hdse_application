import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hdse_application/blocs/application_bloc.dart';
import 'package:hdse_application/screen/place_detail/place_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:page_transition/page_transition.dart';

class ArchivedPlacesListScreen extends StatefulWidget {
  const ArchivedPlacesListScreen({Key? key}) : super(key: key);
  @override
  _ArchivedPlacesListScreenState createState() =>
      _ArchivedPlacesListScreenState();
}

class _ArchivedPlacesListScreenState extends State<ArchivedPlacesListScreen> {
  get itemBuilder => null;
  var applicationBloc;
  @override
  void initState() {
    applicationBloc = Provider.of<ApplicationBloc>(context, listen: false);
    applicationBloc.getArchivedPlaceList();
    super.initState();
  }

  @override
  void dispose() {
    applicationBloc.clearArchivedPlaceList();
    super.dispose();
  }

//     final String responseFromType =
//         await rootBundle.loadString('assets/json/place_type.json');
//     final jsonFromType = await convert.jsonDecode(responseFromType);
//  var placeMap = result['places'] as List;
//       archivedPlaceList = placeMap.map((placeDetail) {
//         var typeEnList = placeDetail['types'] as List;
//         var typeEnToTh = typeEnList
//             .map((typeEn) => jsonFromType[typeEn] != null
//                 ? jsonFromType[typeEn].toString()
//                 : typeEn.toString())
//             .toList();

//         return PlaceDetail.fromJson(placeDetail, typeEnToTh);
//       }).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("รายการสถานที่ที่บันทึกไว้"),
        ),
        body: (applicationBloc.archivedPlaceIDList == null &&
                applicationBloc.archivedPlaceSavedTimeList == null &&
                applicationBloc.archivedPlaceNameList == null &&
                applicationBloc.archivedPlaceListIsEmpty == false)
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Consumer<ApplicationBloc>(
                builder: (context, provider, Widget? child) {
                  return provider.archivedPlaceListIsEmpty == true
                      ? Center(
                          child: Text(
                            'ไม่พบรายการสถานที่ที่บันทึกไว้',
                            style: TextStyle(fontSize: 18),
                          ),
                        )
                      : Container(
                          padding: EdgeInsets.all(10.0),
                          child: ListView.builder(
                              physics: BouncingScrollPhysics(),
                              itemCount: provider.archivedPlaceIDList.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(18.0),
                                      )),
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Colors.green[50]),
                                    ),
                                    onPressed: () {
                                      // print('inkwell ontap');
                                      applicationBloc
                                          .setArchivedPlaceListIndexSelected(
                                              index);
                                      applicationBloc
                                          .getArchivedPlaceDetailToBloc(provider
                                              .archivedPlaceIDList[index]);
                                      Navigator.push(
                                        context,
                                        PageTransition(
                                            duration: const Duration(
                                                milliseconds: 250),
                                            reverseDuration: const Duration(
                                                milliseconds: 250),
                                            type:
                                                PageTransitionType.rightToLeft,
                                            child: new PlaceDetailScreen(
                                              placeID: provider
                                                  .archivedPlaceIDList[index],
                                              isSeved: true,
                                            )),
                                      );
                                    },
                                    child: ArchivedPlaceListTile(
                                      name:
                                          provider.archivedPlaceNameList[index],
                                      savedTime: provider
                                          .archivedPlaceSavedTimeList[index],
                                    ),
                                  ),
                                );
                              }),
                        );
                },
              ));
  }
}

class ArchivedPlaceListTile extends StatelessWidget {
  const ArchivedPlaceListTile({@required this.name, @required this.savedTime});
  final String? name;
  final DateTime? savedTime;

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
                  'บันทึกเมื่อ วันที่ ${savedTime!.day}/${savedTime!.month}/${savedTime!.year + 543}  เวลา ${savedTime!.hour.toString().padLeft(2, '0')}.${savedTime!.minute.toString().padLeft(2, '0')} น.',
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
