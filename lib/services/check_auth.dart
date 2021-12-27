import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hdse_application/screen/home_screen.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

Future checkAuth(BuildContext context) async {
  User? user = await _auth.currentUser;
  if (user != null) {
    print("Already singed-in with");
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HomeScreen(
                  user: user,
                  title: "ยินดีต้อนรับ",
                )));
  }
}
