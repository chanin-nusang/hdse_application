import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hdse_application/blocs/application_bloc.dart';
import 'package:hdse_application/models/place_detail.dart';
import 'package:hdse_application/screen/place_detail/detail_tab.dart';
import 'package:hdse_application/screen/place_detail/navigate_tab.dart';
import 'package:hdse_application/screen/place_detail/reviews_tab.dart';
import 'package:hdse_application/services/webview.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
  int _selectedTabbar = 0;
  // late final _kTabPages = <Widget>[detailTab(), navigateTab(), reviewsTab()];
  final _kTabs = <Tab>[
    Tab(
      height: 35,
      child: Text('รายละเอียด',
          style: GoogleFonts.sarabun(
              textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ))),
    ),
    Tab(
        height: 35,
        child: Text('นำทาง',
            style: GoogleFonts.sarabun(
                textStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            )))),
    Tab(
        height: 35,
        child: Text('คำวิจารณ์',
            style: GoogleFonts.sarabun(
                textStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            )))),
  ];
  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
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
          return Center(child: CircularProgressIndicator());
        else {
          var typeString = provider.placeDetail!.types!.join(", ");
          return NestedScrollView(
              headerSliverBuilder: (context, value) {
                return [
                  SliverToBoxAdapter(
                    child: Container(
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
                                provider.placeDetail!.openNow != null
                                    ? (provider.placeDetail!.openNow == true
                                        ? Text(
                                            'เปิดอยู่ในขณะนี้',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.green[800],
                                            ),
                                            textAlign: TextAlign.center,
                                          )
                                        : Text(
                                            'ปิดอยู่ในขณะนี้',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.red,
                                            ),
                                            textAlign: TextAlign.center,
                                          ))
                                    : Container(),
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
                                            borderRadius:
                                                BorderRadius.circular(22.0)),
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10.0),
                                          ),
                                          onTap: () {
                                            if (provider
                                                    .placeDetail!.phoneNumber !=
                                                null)
                                              launch(
                                                  "tel://${provider.placeDetail!.phoneNumber}");
                                          },
                                          child: Container(
                                            width: 70,
                                            child: Column(
                                              children: [
                                                Icon(
                                                  Icons.phone,
                                                  color: provider.placeDetail!
                                                              .phoneNumber !=
                                                          null
                                                      ? Colors.green[800]
                                                      : Colors.grey,
                                                  size: 30,
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  "โทรออก",
                                                  style: TextStyle(
                                                    fontSize: 17,
                                                    color: provider.placeDetail!
                                                                .phoneNumber !=
                                                            null
                                                        ? Colors.green[800]
                                                        : Colors.grey,
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
                                          onTap: () {
                                            if (provider.placeDetail!.website !=
                                                null) {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          WebViewService(
                                                            title:
                                                                'ดูข้อมูลเพิ่มเติม',
                                                            link: provider
                                                                .placeDetail!
                                                                .website
                                                                .toString(),
                                                          )));
                                            }
                                          },
                                          child: Container(
                                            width: 70,
                                            child: Column(
                                              children: [
                                                Icon(
                                                  Icons.public,
                                                  color: provider.placeDetail!
                                                              .website !=
                                                          null
                                                      ? Colors.green[800]
                                                      : Colors.grey,
                                                  size: 30,
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  "เว็บไซต์",
                                                  style: TextStyle(
                                                    fontSize: 17,
                                                    color: provider.placeDetail!
                                                                .website !=
                                                            null
                                                        ? Colors.green[800]
                                                        : Colors.grey,
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
                            // height: 200,
                            padding: EdgeInsets.only(left: 10, right: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10.0),
                                topRight: Radius.circular(10.0),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                TabBar(
                                  onTap: (index) {
                                    print(index);
                                    setState(() {
                                      _selectedTabbar = index;
                                    });
                                  },
                                  labelColor: Colors.green[800],
                                  unselectedLabelColor: Colors.black54,
                                  controller: _tabController,
                                  tabs: _kTabs,
                                ),
                                // Builder(builder: (_) {
                                //   if (_selectedTabbar == 0) {
                                //     return detailTab();
                                //   } else if (_selectedTabbar == 1) {
                                //     return navigateTab();
                                //   } else {
                                //     return reviewsTab();
                                //   }
                                // }),
                              ],
                            ),
                          ),
                        )
                      ]),
                    ),
                  )
                ];
              },
              body: Padding(
                padding:
                    const EdgeInsets.only(left: 18.0, right: 18, bottom: 18),
                child: Container(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10.0),
                      bottomRight: Radius.circular(10.0),
                    ),
                  ),
                  // fit: FlexFit.loose,
                  // constraints: BoxConstraints(
                  //     minHeight: 200, maxHeight: double.infinity),
                  // height: 100,
                  child: TabBarView(
                      physics: NeverScrollableScrollPhysics(),
                      controller: _tabController,
                      children: <Widget>[
                        detailTab(),
                        navigateTab(),
                        reviewsTab()
                      ]),
                ),
              ));
        }
      }),
    );
  }
}
