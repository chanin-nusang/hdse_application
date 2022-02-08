import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hdse_application/screen/chatbot_screen.dart';
import 'package:hdse_application/screen/login_screen.dart';
import 'package:hdse_application/screen/maps_screen.dart';
import 'package:hdse_application/screen/places_screen.dart';
import 'package:hdse_application/screen/search_screen.dart';
import 'package:hdse_application/services/speech_to_text.dart';
import 'package:hdse_application/services/webview.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'dart:io';
import 'package:webview_flutter/webview_flutter.dart';

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

  @override
  void initState() {
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

  void signOut(BuildContext context) async {
    List<UserInfo> userInfo = _auth.currentUser!.providerData;
    // if (userInfo[0].providerId == "google.com") {
    //   googleSignIn.signOut();
    // }
    // if (userInfo[0].providerId == "facebook.com") {
    //   facebookAuth.logOut();
    // }
    _auth.signOut().then((value) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => HomeScreen(title: "ยินดีต้อนรับ")),
          ModalRoute.withName('/'));
      print("Sign-out with provider = ${userInfo[0].providerId}");
    }).catchError((error) {
      print(error);
    });
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
                        style: TextStyle(color: Colors.black),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          user != null
              ? IconButton(
                  icon: Icon(Icons.exit_to_app),
                  color: Colors.black,
                  onPressed: () {
                    signOut(context);
                  })
              : SizedBox()
        ],
      ),
      body: Container(
          child: ListView(
        padding: EdgeInsets.all(16),
        children: [
          user != null ? userCard(user) : notLoggedInCard(),
          SizedBox(
            height: 20,
          ),
          buildImageCardChatbot(),
          buildImageCardHealthService()
        ],
      )
          // Center(
          //   child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          //     Text("สวัสดี", style: TextStyle(fontSize: 26)),
          //     Text(widget.user?.email ?? "", style: TextStyle(fontSize: 16)),
          //     InkWell(
          //       child: Container(
          //         width: 100,
          //         height: 50,
          //         color: Colors.green[200],
          //         child: Center(child: Text("ระบบแชทบอท")),
          //       ),
          //       onTap: () {
          //         Navigator.push(context,
          //             MaterialPageRoute(builder: (context) => ChatbotScreen()));
          //       },
          //       // This trailing comma makes auto-formatting nicer for build methods.
          //     ),
          //   ]),
          // ),
          ),
    );
  }

  Widget notLoggedInCard() => Row(
        children: [
          Expanded(
            flex: 2,
            child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LoginScreen()));
                },
                child: Text(
                  "เข้าสู่ระบบ",
                  style: TextStyle(fontSize: 17),
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
                      style: TextStyle(color: Colors.black),
                      children: <TextSpan>[
                    TextSpan(
                        recognizer: _loginBenefitsRecognizer,
                        text: 'เพิ่มเติม',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.green))
                  ])))
        ],
      );

  Widget userCard(User? userData) => Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: userData?.photoURL == null
                ? Image.asset('assets/images/avatar.png').image
                : CachedNetworkImageProvider(userData!.photoURL!),
          ),
          SizedBox(
            width: 20,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("สวัสดีตอนเช้า", style: TextStyle(fontSize: 22)),
              Text("คุณ ${userData?.displayName ?? ""}",
                  style: TextStyle(fontSize: 16)),
              Text(userData?.email ?? "", style: TextStyle(fontSize: 16)),
            ],
          )
        ],
      );

  Widget buildImageCardChatbot() => Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                new MaterialPageRoute(
                    builder: (context) => new ChatbotScreen()));
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Ink.image(
                    image: CachedNetworkImageProvider(
                        'https://firebasestorage.googleapis.com/v0/b/hdse-application.appspot.com/o/cdc-UrcuFgKfSS4-unsplash.jpg?alt=media&token=c106982f-fc65-47c3-b5cf-6d1746f6a413'),
                    // NetworkImage(
                    //   'https://firebasestorage.googleapis.com/v0/b/hdse-application.appspot.com/o/cdc-UrcuFgKfSS4-unsplash.jpg?alt=media&token=c106982f-fc65-47c3-b5cf-6d1746f6a413',
                    // ),
                    colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.4), BlendMode.srcOver),
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                  Text(
                    'ปรึกษาปัญหาสุขภาพ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Colors.yellow[100]!, Colors.green[100]!])),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        "ปรึกษาปัญหาสุขภาพ ด้วยระบบแชทบอท",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  Widget buildImageCardHealthService() => Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                new MaterialPageRoute(
                    builder: (context) => new SearchScreen()));
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Ink.image(
                    image: CachedNetworkImageProvider(
                        "https://firebasestorage.googleapis.com/v0/b/hdse-application.appspot.com/o/vlad-sargu-ItphH2lGzuI-unsplash.jpg?alt=media&token=66023587-af61-4d74-889e-72b409672c33"),
                    // NetworkImage(
                    //   'https://firebasestorage.googleapis.com/v0/b/hdse-application.appspot.com/o/vlad-sargu-ItphH2lGzuI-unsplash.jpg?alt=media&token=66023587-af61-4d74-889e-72b409672c33',
                    // ),
                    colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.4), BlendMode.srcOver),
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                  Text(
                    'สถานที่ให้บริการด้านสุขภาพ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Colors.yellow[100]!, Colors.green[100]!])),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        "ค้นหา สถานที่ให้บริการด้านสุขภาพ",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}
