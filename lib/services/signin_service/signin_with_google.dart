import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hdse_application/services/check_auth.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final FirebaseAuth _auth = FirebaseAuth.instance;

Future signInWithGoogle(BuildContext context) async {
  try {
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
    await _auth.signInWithCredential(credential);
    checkAuth(context);
  } catch (e) {
    print(e);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(e.toString(),
          style: GoogleFonts.sarabun(
              textStyle: TextStyle(color: Colors.white, fontSize: 18))),
      backgroundColor: Colors.red,
    ));
  }
}
