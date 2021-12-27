import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hdse_application/services/check_auth.dart';

FirebaseAuth _auth = FirebaseAuth.instance;

signInWithPassword(BuildContext context,
    {@required TextEditingController? emailController,
    @required TextEditingController? passwordController}) async {
  await _auth
      .signInWithEmailAndPassword(
          email: emailController!.text.trim(),
          password: passwordController!.text.trim())
      .then((user) {
    print("signed in ${_auth.currentUser?.email ?? ""}");
    checkAuth(context);
  }).catchError((e) {
    print(e);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(e.toString(), style: TextStyle(color: Colors.white)),
      backgroundColor: Colors.red,
    ));
  });
}
