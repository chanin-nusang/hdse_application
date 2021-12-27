import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:hdse_application/services/check_auth.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

Future signInWithFacebook(BuildContext context) async {
  try {
    final LoginResult result = await FacebookAuth.instance.login();
    if (result.status == LoginStatus.success) {
      print("result.status == LoginStatus.success");
      final OAuthCredential credential =
          FacebookAuthProvider.credential(result.accessToken!.token);
      await _auth.signInWithCredential(credential);
      checkAuth(context);
    }
  } catch (e) {
    print(e);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(e.toString(), style: TextStyle(color: Colors.white)),
      backgroundColor: Colors.red,
    ));
  }
}
