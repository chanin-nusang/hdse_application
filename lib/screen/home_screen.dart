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
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            Text("สวัสดี", style: TextStyle(fontSize: 26)),
            Text(widget.user?.email ?? "", style: TextStyle(fontSize: 16)),
            InkWell(
              child: Container(
                width: 100,
                height: 50,
                color: Colors.green[200],
                child: Center(child: Text("ระบบแชทบอท")),
              ),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ChatbotScreen()));
              },
              // This trailing comma makes auto-formatting nicer for build methods.
            ),
          ]),
        ),
      ),
    );
  }
}
