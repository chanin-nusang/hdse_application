import 'package:flutter/material.dart';
import 'package:hdse_application/blocs/application_bloc.dart';
import 'package:hdse_application/models/place_detail.dart';
import 'package:provider/provider.dart';

class PlaceDetailScreen extends StatefulWidget {
  const PlaceDetailScreen({Key? key, this.placeID}) : super(key: key);
  final String? placeID;
  @override
  _PlaceDetailScreenState createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen>
    with SingleTickerProviderStateMixin {
  PlaceDetail? placeDetail;
  var applicationBloc;
  late TabController _tabController;
  final _kTabPages = <Widget>[
    const Center(child: Icon(Icons.cloud, size: 64.0, color: Colors.teal)),
    const Center(child: Icon(Icons.alarm, size: 64.0, color: Colors.cyan)),
    const Center(child: Icon(Icons.forum, size: 64.0, color: Colors.blue)),
  ];
  final _kTabs = <Tab>[
    const Tab(
        icon: Icon(Icons.format_list_bulleted_outlined), text: 'รายละเอียด'),
    const Tab(icon: Icon(Icons.map_outlined), text: 'แผนที่นำทาง'),
    const Tab(icon: Icon(Icons.reviews_outlined), text: 'คำวิจารณ์'),
  ];
  @override
  void initState() {
    _tabController = TabController(length: _kTabPages.length, vsync: this);
    applicationBloc = Provider.of<ApplicationBloc>(context, listen: false);
    Provider.of<ApplicationBloc>(context, listen: false)
        .getPlaceDetailToBloc(widget.placeID!);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    applicationBloc.clearPlaceDetail();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('รายละเอียดสถานที่'),
      ),
      body: Consumer<ApplicationBloc>(
          builder: (context, provider, Widget? child) {
        if (provider.placeDetail == null)
          return CircularProgressIndicator();
        else {
          var typeString = provider.placeDetail!.types!.join(", ");
          return Container(
            padding: EdgeInsets.all(0),
            child: Column(children: [
              Container(
                color: Colors.white,
                height: 200,
              ),
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      )),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        provider.placeDetail!.name ?? '',
                        style: TextStyle(fontSize: 22),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        typeString,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black38,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Divider(),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Material(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(22.0)),
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10.0),
                                ),
                                onTap: () {},
                                child: Container(
                                  width: 70,
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.phone,
                                        color: Colors.green[800],
                                        size: 30,
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        "โทรออก",
                                        style: TextStyle(
                                            fontSize: 17,
                                            color: Colors.green[800]),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 30,
                            ),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10.0),
                                ),
                                onTap: () {},
                                child: Container(
                                  width: 70,
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.public,
                                        color: Colors.green[800],
                                        size: 30,
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        "เว็บไซต์",
                                        style: TextStyle(
                                          fontSize: 17,
                                          color: Colors.green[800],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 30,
                            ),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10.0),
                                ),
                                onTap: () {},
                                child: Container(
                                  width: 70,
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.bookmark_add_outlined,
                                        color: Colors.green[800],
                                        size: 30,
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        "บันทึก",
                                        style: TextStyle(
                                          fontSize: 17,
                                          color: Colors.green[800],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 18, right: 18),
                child: Container(
                  height: 200,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      )),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TabBar(
                        controller: _tabController,
                        tabs: _kTabs,
                      ),
                      Expanded(
                        child: TabBarView(
                            controller: _tabController, children: _kTabPages),
                      )
                    ],
                  ),
                ),
              )
            ]),
          );
        }
      }),
    );
  }
}
