import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hdse_application/screen/home_screen.dart';
import 'package:hdse_application/screen/login_screen.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

Future checkAuth(BuildContext context) async {
  User? user = await _auth.currentUser;
  if (user != null) {
    print("Already singed-in with");
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => HomeScreen(
                  title: "ยินดีต้อนรับ",
                )),
        (Route<dynamic> route) => false);
  } else {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }
}
