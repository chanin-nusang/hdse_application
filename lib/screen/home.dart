import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:hdse_application/screen/chat.dart';
import 'package:hdse_application/screen/login.dart';

class Home extends StatefulWidget {
  const Home({Key? key, required this.title, this.user}) : super(key: key);
  final String title;
  final User? user;
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  void signOut(BuildContext context) async {
    // final AccessToken? accessToken = await FacebookAuth.instance.accessToken;
    // if (accessToken != null) {
    //   await FacebookAuth.instance.logOut();
    //   setState(() {
    //               _userData = null;
    //             });
    // }
    _auth
        .signOut()
        .then((value) => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Login()),
            ModalRoute.withName('/')))
        .catchError((error) {
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
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Chat()));
              },
              // This trailing comma makes auto-formatting nicer for build methods.
            ),
          ]),
        ),
      ),
    );
  }
}
