import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title:
              Text("ตั้งรหัสผ่านใหม่", style: TextStyle(color: Colors.black)),
          iconTheme: IconThemeData(
            color: Colors.black, //change your color here
          ),
        ),
        body: Container(
            color: Colors.green[50],
            child: Center(
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                          colors: [Colors.yellow[100]!, Colors.green[100]!])),
                  margin: EdgeInsets.all(32),
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      buildTextFieldEmail(),
                      buildButtonSignUp(context)
                    ],
                  )),
            )));
  }

  Widget buildButtonSignUp(BuildContext context) {
    return InkWell(
        child: Container(
            constraints: BoxConstraints.expand(height: 50),
            child: Text("ตั้งรหัสผ่านใหม่",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.black)),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.green[200]),
            margin: EdgeInsets.only(top: 16),
            padding: EdgeInsets.all(12)),
        onTap: () => resetPassword());
  }

  Container buildTextFieldEmail() {
    return Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.yellow[50], borderRadius: BorderRadius.circular(16)),
        child: TextField(
            controller: emailController,
            decoration: InputDecoration.collapsed(hintText: "อีเมล"),
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(fontSize: 18)));
  }

  resetPassword() {
    String email = emailController.text.trim();
    _auth.sendPasswordResetEmail(email: email);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("We send the detail to $email successfully.",
          style: TextStyle(color: Colors.white)),
      backgroundColor: Colors.green[300],
    ));
  }
}
