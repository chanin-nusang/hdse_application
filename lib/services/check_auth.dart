import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hdse_application/screen/home_screen.dart';
import 'package:hdse_application/screen/signin/login_screen.dart';

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
    try {
      DocumentSnapshot snapShot = await FirebaseFirestore.instance
          .collection("users")
          .doc(_auth.currentUser!.uid)
          .get();
      if (snapShot.exists)
        FirebaseFirestore.instance
            .collection("users")
            .doc(_auth.currentUser!.uid)
            .update({
          "name": _auth.currentUser!.displayName ?? "",
          "email": _auth.currentUser!.email ?? "",
          "photoURL": _auth.currentUser!.photoURL ?? "",
          "phoneNumber": _auth.currentUser!.phoneNumber ?? ""
        });
      else
        FirebaseFirestore.instance
            .collection("users")
            .doc(_auth.currentUser!.uid)
            .set({
          "name": _auth.currentUser!.displayName ?? "",
          "email": _auth.currentUser!.email ?? "",
          "photoURL": _auth.currentUser!.photoURL ?? "",
          "phoneNumber": _auth.currentUser!.phoneNumber ?? ""
        });
    } catch (e) {
      print("FirebaseFirestore.instance error : " + e.toString());
    }
  } else {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }
}
