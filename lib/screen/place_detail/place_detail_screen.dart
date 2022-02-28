import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hdse_application/blocs/application_bloc.dart';
import 'package:hdse_application/models/place_detail.dart';
import 'package:hdse_application/screen/place_detail/detail_tab.dart';
import 'package:hdse_application/screen/place_detail/navigate_tab.dart';
import 'package:hdse_application/screen/place_detail/reviews_tab.dart';
import 'package:hdse_application/services/webview.dart';
import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';

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
  int? imageSlideshowIndex;

  // late final _kTabPages = <Widget>[detailTab(), navigateTab(), reviewsTab()];
  List<Tab> _kTabs = [];
  @override
  void initState() {
    imageSlideshowIndex = 0;
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

  checkStoragePermission() async {
    // var manageExternalStorageStatus =
    //     await Permission.manageExternalStorage.status;
    var storageStatus = await Permission.storage.status;
    // if (manageExternalStorageStatus.isDenied) {
    //   await Permission.manageExternalStorage.request();
    //   manageExternalStorageStatus =
    //       await Permission.manageExternalStorage.status;
    //   if (manageExternalStorageStatus.isDenied)
    //     saveImageToGallery(false);
    //   else
    //     saveImageToGallery(true);
    // }
    if (storageStatus.isDenied) {
      await Permission.storage.request();
      storageStatus = await Permission.storage.status;
      if (storageStatus.isDenied)
        saveImageToGallery(false);
      else
        saveImageToGallery(true);
    } else
      // if (!manageExternalStorageStatus.isDenied) {
      //     &&
      //     (!storageStatus.isDenied) {
      saveImageToGallery(true);
    // }
  }

  saveImageToGallery(bool isPermission) async {
    if (isPermission)
      GallerySaver.saveImage(applicationBloc.photosPath[imageSlideshowIndex],
              albumName: "HDSE")
          .then((success) {
        success == true
            ? ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('บันทึกรูปภาพลงในโทรศัพท์แล้ว',
                    style: GoogleFonts.sarabun(
                        textStyle:
                            TextStyle(color: Colors.white, fontSize: 18))),
                backgroundColor: Colors.green,
              ))
            : ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('เกิดข้อผิดพลาดในการบันทึกรูปภาพ',
                    style: GoogleFonts.sarabun(
                        textStyle:
                            TextStyle(color: Colors.white, fontSize: 18))),
                backgroundColor: Colors.red,
              ));
      });
    else
      _showStorageDeniedDialog();
    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //   content: Text('ไม่ได้รับสิทธิ์ในการอนุญาตให้บันทึกรูปภาพ',
    //       style: GoogleFonts.sarabun(
    //           textStyle: TextStyle(color: Colors.white, fontSize: 18))),
    //   backgroundColor: Colors.red,
    // ));
  }

  _showStorageDeniedDialog() {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            contentPadding: EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 15.0),
            scrollable: true,
            content: Column(
              children: [
                Icon(
                  Icons.file_download_off_outlined,
                  size: 40,
                  color: Colors.red[200],
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'ไม่ได้รับสิทธิ์ในการอนุญาตให้บันทึกรูปภาพ กดปุ่ม เปิดการตั้งค่า ที่เมนู "สิทธิ์" มองหา "ไฟล์และสื่อ" แล้วเลือก "อนุญาตเข้าถึงสื่อเท่านั้น"',
                  style: TextStyle(fontSize: 15),
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        onPressed: () async {
                          await AppSettings.openAppSettings();
                        },
                        child: Text(
                          "เปิดการตั้งค่า",
                          style: TextStyle(fontSize: 17),
                        )),
                  ],
                ),
              ],
            ),
          );
        });
  }

  _showImage(BuildContext context) {
    Navigator.push(
        context,
        PageTransition(
            duration: const Duration(milliseconds: 100),
            reverseDuration: const Duration(milliseconds: 250),
            type: PageTransitionType.bottomToTop,
            child: Scaffold(
              backgroundColor: Colors.black.withOpacity(0.8),
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 6,
                      child: ImageSlideshow(
                        // width: 400,
                        height: 500,
                        initialPage: imageSlideshowIndex!,
                        indicatorColor: Colors.green[400],
                        indicatorBackgroundColor: Colors.grey[600],
                        children: applicationBloc.photos
                            .map<Widget>((element) => Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 500,
                                  // decoration: BoxDecoration(
                                  //     image: DecorationImage(
                                  //         image: element,
                                  //         fit: BoxFit.fitWidth))
                                  child: PhotoView(
                                    imageProvider: element,
                                  ),
                                ))
                            .toList(),
                        onPageChanged: (value) {
                          print("photo : " + value.toString());
                          imageSlideshowIndex = value;
                        },
                        autoPlayInterval: 0,
                        isLoop: true,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Flexible(
                      flex: 2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.white),
                              onPressed: () {
                                print('imageSlideshowIndex :' +
                                    imageSlideshowIndex.toString());

                                Navigator.of(context).pop();
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.close,
                                    color: Colors.red,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    "ปิด",
                                    style: TextStyle(
                                        fontSize: 17,
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              )),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.white),
                              onPressed: () {
                                checkStoragePermission();
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.save,
                                    color: Colors.green[400],
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    "บันทึกรูปภาพ",
                                    style: TextStyle(
                                        fontSize: 17,
                                        color: Colors.green[400],
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )));
  }

  @override
  Widget build(BuildContext context) {
    _kTabs = <Tab>[
      Tab(
        height: 40 * MediaQuery.of(context).textScaleFactor,
        child: Text('รายละเอียด',
            style: GoogleFonts.sarabun(
                textStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ))),
      ),
      Tab(
          height: 40 * MediaQuery.of(context).textScaleFactor,
          child: Text('นำทาง',
              style: GoogleFonts.sarabun(
                  textStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              )))),
      Tab(
          height: 40 * MediaQuery.of(context).textScaleFactor,
          child: Text('คำวิจารณ์',
              style: GoogleFonts.sarabun(
                  textStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              )))),
    ];
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
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
                          if (provider.photos.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _showImage(context);
                              },
                              child: ImageSlideshow(
                                // width: 400,
                                height: 200,
                                initialPage: imageSlideshowIndex!,
                                indicatorColor: Colors.green[400],
                                indicatorBackgroundColor: Colors.grey[600],
                                children: provider.photos
                                    .map((element) => Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: 200,
                                          decoration: BoxDecoration(
                                              image: DecorationImage(
                                                  image: element,
                                                  fit: BoxFit.fitWidth)),
                                        ))
                                    .toList(),
                                onPageChanged: (value) {
                                  print("photo : " + value.toString());
                                  imageSlideshowIndex = value;
                                },
                                autoPlayInterval: 0,
                                isLoop: true,
                              ),
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
                                                fontSize: 17,
                                                color: Colors.green[800],
                                              ),
                                              textAlign: TextAlign.center,
                                            )
                                          : Text(
                                              'ปิดอยู่ในขณะนี้',
                                              style: TextStyle(
                                                fontSize: 17,
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
                                      fontSize: 16,
                                      color: Colors.black38,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  Divider(
                                    color: Colors.grey,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                              if (provider.placeDetail!
                                                      .phoneNumber !=
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
                                                      color: provider
                                                                  .placeDetail!
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
                                              if (provider
                                                      .placeDetail!.website !=
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
                                                      color: provider
                                                                  .placeDetail!
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
                                      print('TabBar : $index');
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
                          ReviewsTab()
                        ]),
                  ),
                ));
          }
        }),
      ),
    );
  }
}
