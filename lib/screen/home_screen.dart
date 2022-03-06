import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hdse_application/blocs/application_bloc.dart';
import 'package:hdse_application/components/image_card.dart';
import 'package:hdse_application/models/place_detail.dart';
import 'package:hdse_application/screen/backdrop_menu/menu.dart';
import 'package:hdse_application/screen/chatbot/chatbot_screen.dart';
import 'package:hdse_application/screen/signin/login_screen.dart';
import 'package:hdse_application/screen/maps_screen.dart';
import 'package:hdse_application/screen/place_detail/place_detail_screen.dart';
import 'package:hdse_application/screen/place_search/places_list_screen.dart';
import 'package:hdse_application/screen/place_search/search_screen.dart';
import 'package:hdse_application/blocs/speech_to_text.dart';
import 'package:hdse_application/services/webview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'dart:io';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:intl/intl.dart';
import 'package:backdrop/backdrop.dart';
import 'package:app_settings/app_settings.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? user;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FacebookAuth facebookAuth = FacebookAuth.instance;
  final SpeechToText speech = SpeechToText();
  TapGestureRecognizer? _loginBenefitsRecognizer;
  TapGestureRecognizer? _privacyPolicyRecognizer;
  TapGestureRecognizer? _termsAndConditionsRecognizer;
  String timeFormatter = DateFormat.H().format(DateTime.now());
  int? timeInt = 0;
  String? textTime = "สวัสดี";
  bool isBackLayerConcealed = true;
  @override
  void initState() {
    // print("bounds.hasListener : " +
    //     Provider.of<ApplicationBloc>(context, listen: false)
    //         .bounds
    //         .hasListener
    //         .toString());
    setTextTime();
    SpeechToTextService().initSpeechState();
    user = _auth.currentUser;

    if (Platform.isAndroid) WebView.platform = AndroidWebView();
    _loginBenefitsRecognizer = TapGestureRecognizer()
      ..onTap = () {
        _showLoginBenefitsDialog();
      };
    _privacyPolicyRecognizer = TapGestureRecognizer()
      ..onTap = () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => WebViewService(
                    title: 'ข้อกำหนดของบริการ',
                    link:
                        'https://www.freeprivacypolicy.com/live/40994482-a2c3-4c7b-a3a0-bafaf4b0d8f9')));
      };
    _termsAndConditionsRecognizer = TapGestureRecognizer()
      ..onTap = () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => WebViewService(
                      title: 'นโยบายความเป็นส่วนตัว',
                      link:
                          'https://www.termsandconditionsgenerator.com/live.php?token=sC5eDsc8lvxVb18OwwiEib4K80dlIoNe',
                    )));
      };
    super.initState();
  }

  checkLocationPermission() async {
    // var manageExternalStorageStatus =
    //     await Permission.manageExternalStorage.status;
    var locationStatus = await Permission.location.status;
    // if (manageExternalStorageStatus.isDenied) {
    //   await Permission.manageExternalStorage.request();
    //   manageExternalStorageStatus =
    //       await Permission.manageExternalStorage.status;
    //   if (manageExternalStorageStatus.isDenied)
    //     saveImageToGallery(false);
    //   else
    //     saveImageToGallery(true);
    // }
    if (locationStatus.isDenied) {
      await Permission.location.request();
      locationStatus = await Permission.location.status;
      if (locationStatus.isDenied)
        _showLocationPermissionDeniedDialog();
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //   content: Text('ไม่ได้รับสิทธิ์ให้เข้าถึงตำแหน่งปัจจุบันของคุณ',
      //       style: GoogleFonts.sarabun(
      //           textStyle: TextStyle(color: Colors.white, fontSize: 18))),
      //   backgroundColor: Colors.red,
      // ));
      else
        Navigator.push(
            context,
            new MaterialPageRoute(
              builder: (context) => new SearchScreen(
                  //   new PlaceDetailScreen(
                  // placeID: "ChIJ93MaP0goTTARvAysWt37MEg",
                  // isSeved: false,
                  ),
            ));
    } else
      // if (!manageExternalStorageStatus.isDenied) {
      //     &&
      //     (!storageStatus.isDenied) {
      Navigator.push(
          context,
          new MaterialPageRoute(builder: (context) => new SearchScreen()
              // new PlaceDetailScreen(
              //     placeID: "ChIJ93MaP0goTTARvAysWt37MEg", isSeved: false),
              ));
    // }
  }

  setTextTime() {
    print("Time now : " + timeFormatter);
    timeInt = int.parse(timeFormatter);
    if (timeInt! > 5 && timeInt! <= 9) {
      textTime = "สวัสดีตอนเช้า";
    } else if (timeInt! > 9 && timeInt! <= 11) {
      textTime = "สวัสดีตอนสาย";
    } else if (timeInt! > 11 && timeInt! <= 13) {
      textTime = "สวัสดีตอนเที่ยง";
    } else if (timeInt! > 13 && timeInt! <= 15) {
      textTime = "สวัสดีตอนบ่าย";
    } else if (timeInt! > 15 && timeInt! <= 18) {
      textTime = "สวัสดีตอนเย็น";
    } else if (timeInt! > 18 && timeInt! <= 22) {
      textTime = "สวัสดีตอนค่ำ";
    } else
      textTime = "สวัสดี";
  }

  _showLoginBenefitsDialog() {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            contentPadding: EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 15.0),
            scrollable: true,
            content: Column(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 40,
                  color: Colors.green[200],
                ),
                SizedBox(
                  height: 10,
                ),
                RichText(
                    text: TextSpan(
                        text:
                            "เพื่อเก็บข้อมูลการสนทนากับแชทบอท และข้อมูลประวัติการค้นหาสถานที่ให้บริการด้านสุขภาพ เอาไว้ให้สามารถเรียกดูภายหลังได้ เราจะนำข้อมูลของท่าน เช่น ชื่อ อีเมล ไปใช้อ้างอิงในการเก็บข้อมูลการใช้งานแอปพลิเคชันของท่าน  ",
                        style: GoogleFonts.sarabun(
                            textStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 15 *
                                    MediaQuery.of(context).textScaleFactor)),
                        children: <TextSpan>[
                      TextSpan(
                          text: "ดู", style: TextStyle(color: Colors.black)),
                      TextSpan(
                          recognizer: _privacyPolicyRecognizer,
                          text: 'ข้อกำหนดของบริการ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green)),
                      TextSpan(
                          text: "และ", style: TextStyle(color: Colors.black)),
                      TextSpan(
                          recognizer: _termsAndConditionsRecognizer,
                          text: 'นโยบายความเป็นส่วนตัว',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.green))
                    ])),
                SizedBox(
                  height: 15,
                ),
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginScreen()));
                    },
                    child: Text(
                      "เข้าสู่ระบบ / ลงทะเบียน",
                      style: TextStyle(fontSize: 17),
                    )),
              ],
            ),
          );
        });
  }

  _showLocationPermissionDeniedDialog() {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            contentPadding: EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 15.0),
            scrollable: true,
            content: Column(
              children: [
                Icon(
                  Icons.wrong_location_outlined,
                  size: 40,
                  color: Colors.red[200],
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'ไม่ได้รับสิทธิ์ให้เข้าถึงตำแหน่งปัจจุบันของคุณ กดปุ่ม เปิดการตั้งค่า ที่เมนู "สิทธิ์" มองหา "ตำแหน่ง" แล้วเลือก "อนุญาตขณะมีการใช้แอปเท่านั้น"',
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
    Navigator.of(context).push(PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) {
          return Scaffold(
            backgroundColor: Colors.black.withOpacity(0.8),
            body: Center(
              child: Hero(
                  tag: 'profile-image-tag',
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                          flex: 4,
                          child: ListView(
                            children: [
                              Image(
                                  image: CachedNetworkImageProvider(
                                      user!.photoURL!)),
                            ],
                          )),
                      Flexible(
                        flex: 3,
                        child: ElevatedButton(
                            style:
                                ElevatedButton.styleFrom(primary: Colors.white),
                            onPressed: () {
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
                      ),
                    ],
                  )),
            ),
          );
        }));
  }

  @override
  Widget build(BuildContext context) {
    return BackdropScaffold(
      stickyFrontLayer: true,
      appBar: BackdropAppBar(
        automaticallyImplyLeading: false,
        title: Text("ยินดีต้อนรับ",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            )),
        actions: <Widget>[
          BackdropToggleButton(
            color: Colors.black,
          )
        ],
      ),
      backLayer: menu(context),
      frontLayer: Container(
        color: Colors.green[200]!,
        child: SafeArea(
          child: Container(
              color: Colors.green[200]!,
              child: Padding(
                padding: const EdgeInsets.only(top: 0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(
                          left: 15, right: 15, top: 0, bottom: 20),
                      child: user != null ? userCard(user) : notLoggedInCard(),
                    ),
                    Expanded(
                      child: PhysicalShape(
                          clipper: const ShapeBorderClipper(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(25.0),
                                topRight: Radius.circular(25.0),
                              ),
                            ),
                          ),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 10,
                                ),
                                buildImageCard(context,
                                    handler: () => Navigator.push(
                                        context,
                                        new MaterialPageRoute(
                                            builder: (context) =>
                                                new ChatbotScreen())),
                                    imageURL:
                                        'https://firebasestorage.googleapis.com/v0/b/hdse-application.appspot.com/o/cdc-UrcuFgKfSS4-unsplash.jpg?alt=media&token=c106982f-fc65-47c3-b5cf-6d1746f6a413',
                                    title: 'ปรึกษาปัญหาสุขภาพ',
                                    subTitle:
                                        "ปรึกษาปัญหาสุขภาพ ด้วยระบบแชทบอท"),
                                SizedBox(
                                  height: 10,
                                ),
                                buildImageCard(context,
                                    handler: () => checkLocationPermission(),
                                    imageURL:
                                        "https://firebasestorage.googleapis.com/v0/b/hdse-application.appspot.com/o/vlad-sargu-ItphH2lGzuI-unsplash.jpg?alt=media&token=66023587-af61-4d74-889e-72b409672c33",
                                    title: 'สถานที่ให้บริการด้านสุขภาพ',
                                    subTitle:
                                        'ค้นหา สถานที่ให้บริการด้านสุขภาพ'),
                              ],
                            ),
                          )),
                    )
                  ],
                ),
              )),
        ),
      ),
    );
  }

  Widget notLoggedInCard() => Row(
        children: [
          Expanded(
            flex: 2,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.white),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LoginScreen()));
                },
                child: Text(
                  "เข้าสู่ระบบ",
                  style: TextStyle(
                      fontSize: 17,
                      color: Colors.green[400],
                      fontWeight: FontWeight.bold),
                )),
          ),
          SizedBox(
            width: 20,
          ),
          Expanded(
              flex: 4,
              child: RichText(
                  text: TextSpan(
                      text:
                          "เข้าสู่ระบบเพื่อประสบการณ์การใช้งานแอปพลิเคชันที่ดีสุด   ",
                      style: GoogleFonts.sarabun(
                          textStyle: TextStyle(
                              color: Colors.black,
                              fontSize:
                                  15 * MediaQuery.of(context).textScaleFactor)),
                      children: <TextSpan>[
                    TextSpan(
                        recognizer: _loginBenefitsRecognizer,
                        text: 'เพิ่มเติม',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white))
                  ])))
        ],
      );

  Widget userCard(User? userData) => Row(
        children: [
          GestureDetector(
            onTap: () {
              if (userData?.photoURL != null) _showImage(context);
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.green[100]!,
                  width: 4.0,
                ),
              ),
              child: Hero(
                tag: 'profile-image-tag',
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: userData?.photoURL == null
                      ? Image.asset('assets/images/avatar.png').image
                      : CachedNetworkImageProvider(userData!.photoURL!),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 15,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  )),
              child: Padding(
                padding: const EdgeInsets.only(left: 15, bottom: 10, top: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(textTime!, style: TextStyle(fontSize: 22)),
                    Text("คุณ ${userData?.displayName ?? ""}",
                        style: TextStyle(fontSize: 16)),
                    Text(userData?.email ?? "", style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
          )
        ],
      );
}
