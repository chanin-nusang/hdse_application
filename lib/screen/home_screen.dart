import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hdse_application/screen/chatbot_screen.dart';
import 'package:hdse_application/screen/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required this.title, this.user})
      : super(key: key);
  final String title;
  final User? user;
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FacebookAuth facebookAuth = FacebookAuth.instance;
  int _counter = 0;

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
          MaterialPageRoute(builder: (context) => LoginScreen()),
          ModalRoute.withName('/'));
      print("Sign-out with provider = ${userInfo[0].providerId}");
    }).catchError((error) {
      print(error);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
              icon: Icon(Icons.exit_to_app),
              color: Colors.black,
              onPressed: () {
                signOut(context);
              })
        ],
      ),
      body: Container(
          child: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: widget.user?.photoURL == null
                    ? Image.asset('assets/images/avatar.png').image
                    : CachedNetworkImageProvider(widget.user!.photoURL!),
              ),
              SizedBox(
                width: 20,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("สวัสดีตอนเช้า", style: TextStyle(fontSize: 22)),
                  Text("คุณ ${widget.user?.displayName ?? ""}",
                      style: TextStyle(fontSize: 16)),
                  Text(widget.user?.email ?? "",
                      style: TextStyle(fontSize: 16)),
                ],
              )
            ],
          ),
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

  Widget buildImageCardChatbot() => Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ChatbotScreen()));
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
          onTap: () {},
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
