import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hdse_application/services/check_auth.dart';

FirebaseAuth _auth = FirebaseAuth.instance;

signInWithPassword(BuildContext context,
    {@required TextEditingController? emailController,
    @required TextEditingController? passwordController}) async {
  try {
    await _auth
        .signInWithEmailAndPassword(
            email: emailController!.text.trim(),
            password: passwordController!.text.trim())
        .then((user) {
      print("signed in ${_auth.currentUser?.email ?? ""}");
      checkAuth(context);
    });
  } catch (e) {
    print("signInWithPassword error : " + e.toString());
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(e.toString(),
          style: GoogleFonts.sarabun(
              textStyle: TextStyle(color: Colors.white, fontSize: 18))),
      backgroundColor: Colors.red,
    ));
  }
}
