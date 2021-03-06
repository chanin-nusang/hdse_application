import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hdse_application/components/signin_button.dart';
import 'package:hdse_application/screen/signin/reset_password_screen.dart';
import 'package:hdse_application/screen/signin/reset_password_screen.dart';
import 'package:hdse_application/screen/signin/signup_screen.dart';
import 'package:hdse_application/services/check_auth.dart';
import 'package:hdse_application/services/signin_service/signin_with_facebook.dart';
import 'package:hdse_application/services/signin_service/signin_with_google.dart';
import 'package:hdse_application/services/signin_service/signin_with_line.dart';
import 'package:hdse_application/services/signin_service/signin_with_password.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  Map? _userData;
  final String facebookIcon = 'assets/icons/facebooklogo.svg';
  final String lineIcon = 'assets/icons/linelogo.svg';
  final String googleIcon = 'assets/icons/googlelogo.svg';
  DocumentSnapshot? snapshot;
  @override
  void initState() {
    lineSDKInit();
    // getData();
    super.initState();
  }

  void getData() async {
    //use a Async-await function to get the data
    final data = await FirebaseFirestore.instance
        .collection("messages")
        .doc('dvoeatqArsUQwH4XBWXP')
        .get(); //get the data
    Map<String, dynamic> map = data.data()!;
    print('snapshot : ' + map['time'].toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text("?????????????????????????????????", style: TextStyle(color: Colors.black87)),
        ),
        body: Container(
            color: Colors.green[50],
            child: Center(
              child: SingleChildScrollView(
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
                        buildTextFieldPassword(),
                        buildSigninButton(context, Icon(Icons.login),
                            isRow: true,
                            height: null,
                            width: null,
                            text: "?????????????????????????????????",
                            textColor: Colors.black,
                            buttonColor: Colors.green[200],
                            handler: () => emailController.text.isEmpty ||
                                    passwordController.text.isEmpty
                                ? {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text(
                                          "??????????????? ???????????? ???????????????????????? ??????????????????????????????",
                                          style: GoogleFonts.sarabun(
                                              textStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18))),
                                      backgroundColor: Colors.red,
                                    ))
                                  }
                                : signInWithPassword(context,
                                    emailController: emailController,
                                    passwordController: passwordController)),
                        buildLine("??????????????????????????????????????????????????????????"),
                        buildSigninButton(context, Icon(Icons.person_add),
                            isRow: true,
                            height: null,
                            width: null,
                            text: "???????????????????????????",
                            textColor: Colors.black,
                            buttonColor: Colors.orange[200], handler: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignupScreen()));
                        }),
                        buildLine("???????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????"),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            buildSigninButton(
                                context,
                                Container(
                                    height: 30,
                                    width: 30,
                                    child: SvgPicture.asset(
                                        "assets/icons/facebooklogo.svg")),
                                isRow: false,
                                height: null,
                                width: 70,
                                text: "?????????????????????",
                                textColor: Colors.blue[600],
                                buttonColor: Colors.white, handler: () {
                              signInWithFacebook(context);
                            }),
                            buildSigninButton(
                                context,
                                Container(
                                    height: 30,
                                    width: 30,
                                    child: Image.asset(
                                      'assets/icons/linelogo.png',
                                      width: 30,
                                      height: 30,
                                      fit: BoxFit.fill,
                                    )),
                                isRow: false,
                                height: null,
                                width: 70,
                                text: "????????????",
                                textColor: Colors.green,
                                buttonColor: Colors.white,
                                handler: () => signInWithLine(context)),
                            buildSigninButton(
                                context,
                                Container(
                                    height: 30,
                                    width: 30,
                                    child: SvgPicture.asset(
                                        "assets/icons/googlelogo.svg")),
                                isRow: false,
                                height: null,
                                width: 70,
                                text: "??????????????????",
                                textColor: Colors.grey[800],
                                buttonColor: Colors.white,
                                handler: () => signInWithGoogle(context)),
                          ],
                        ),
                        buildLine("??????????????????????????????????????????????????????????????????????????????"),
                        buildSigninButton(
                            context,
                            Icon(
                              Icons.password,
                              color: Colors.white,
                            ),
                            isRow: true,
                            height: null,
                            width: null,
                            text: "?????????????????????????????????",
                            textColor: Colors.white,
                            buttonColor: Colors.red[300], handler: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ResetPasswordScreen()));
                        })
                      ],
                    )),
              ),
            )));
  }

  Container buildTextFieldEmail() {
    return Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.yellow[50], borderRadius: BorderRadius.circular(16)),
        child: TextField(
            controller: emailController,
            decoration: InputDecoration.collapsed(hintText: "???????????????"),
            style: TextStyle(fontSize: 18)));
  }

  Container buildTextFieldPassword() {
    return Container(
        padding: EdgeInsets.all(12),
        margin: EdgeInsets.only(top: 12),
        decoration: BoxDecoration(
            color: Colors.yellow[50], borderRadius: BorderRadius.circular(16)),
        child: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration.collapsed(hintText: "????????????????????????"),
            style: TextStyle(fontSize: 18)));
  }

  Widget buildLine(String text) {
    return Container(
        margin: EdgeInsets.only(top: 16),
        child: Row(children: <Widget>[
          Expanded(child: Divider(color: Colors.green[800])),
          MediaQuery.of(context).textScaleFactor == 1
              ? Padding(
                  padding: EdgeInsets.all(6),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ))
              : Expanded(
                  flex: 1 * (text.length ~/ 10),
                  child: Padding(
                      padding: EdgeInsets.all(6),
                      child: Text(
                        text,
                        style: TextStyle(
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      )),
                ),
          Expanded(child: Divider(color: Colors.green[800])),
        ]));
  }
}
