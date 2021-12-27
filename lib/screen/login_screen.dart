import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hdse_application/components/signin_button.dart';
import 'package:hdse_application/screen/reset_password_screen.dart';
import 'package:hdse_application/screen/signup_screen.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart' as LineAuth;
import 'package:hdse_application/services/check_auth.dart';
import 'package:hdse_application/services/signin_service/signin_with_facebook.dart';
import 'package:hdse_application/services/signin_service/signin_with_google.dart';
import 'package:hdse_application/services/signin_service/signin_with_line.dart';

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

  @override
  void initState() {
    lineSDKInit();
    checkAuth(context);
    super.initState();
  }

  void lineSDKInit() async {
    await LineAuth.LineSDK.instance.setup("1656749651").then((_) {
      print("LineSDK is Prepared");
    });
  }

  signIn() async {
    await _auth
        .signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim())
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text("บริการข้อมูลสุขภาพสำหรับผู้สูงอายุ",
              style: TextStyle(color: Colors.black87)),
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
                      buildTextFieldPassword(),
                      buildSigninButton(context,
                          text: "เข้าสู่ระบบ",
                          textColor: Colors.white,
                          buttonColor: Colors.green[200],
                          handler: () => signIn()),
                      buildLine("ยังไม่มีบัญชีใช่ไหม?"),
                      buildSigninButton(context,
                          text: "เข้าใช้งานด้วย Facebook",
                          textColor: Colors.white,
                          buttonColor: Colors.blue[600], handler: () {
                        signInWithFacebook(context);
                      }),
                      buildSigninButton(context,
                          text: "เข้าใช้งานด้วย Line",
                          textColor: Colors.white,
                          buttonColor: Colors.green[400],
                          handler: () => signInWithLine(context)),
                      buildSigninButton(context,
                          text: "เข้าใช้งานด้วย Google",
                          textColor: Colors.grey[700],
                          buttonColor: Colors.white,
                          handler: () => signInWithGoogle(context)),
                      buildSigninButton(context,
                          text: "ลงทะเบียน",
                          textColor: Colors.white,
                          buttonColor: Colors.orange[200], handler: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignupScreen()));
                      }),
                      buildLine("หากไม่สามารถเข้าสู่ระบบได้"),
                      buildSigninButton(context,
                          text: "ลืมรหัสผ่าน",
                          textColor: Colors.white,
                          buttonColor: Colors.red[300], handler: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ResetPasswordScreen()));
                      })
                    ],
                  )),
            )));
  }

  Widget buildButtonSignIn() {
    return InkWell(
      child: Container(
          constraints: BoxConstraints.expand(height: 50),
          child: Text("เข้าสู่ระบบ",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.white)),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.green[200]),
          margin: EdgeInsets.only(top: 16),
          padding: EdgeInsets.all(12)),
      onTap: () {
        signIn();
      },
    );
  }

  Container buildTextFieldEmail() {
    return Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.yellow[50], borderRadius: BorderRadius.circular(16)),
        child: TextField(
            controller: emailController,
            decoration: InputDecoration.collapsed(hintText: "อีเมล"),
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
            decoration: InputDecoration.collapsed(hintText: "รหัสผ่าน"),
            style: TextStyle(fontSize: 18)));
  }

  Widget buildLine(String text) {
    return Container(
        margin: EdgeInsets.only(top: 16),
        child: Row(children: <Widget>[
          Expanded(child: Divider(color: Colors.green[800])),
          Padding(
              padding: EdgeInsets.all(6),
              child: Text(text, style: TextStyle(color: Colors.black87))),
          Expanded(child: Divider(color: Colors.green[800])),
        ]));
  }

  Widget buildButtonRegister() {
    return InkWell(
        child: Container(
            constraints: BoxConstraints.expand(height: 50),
            child: Text("ลงทะเบียน",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.white)),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.orange[200]),
            margin: EdgeInsets.only(top: 12),
            padding: EdgeInsets.all(12)),
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => SignupScreen()));
        });
  }

  buildButtonForgotPassword(BuildContext context) {
    return InkWell(
        child: Container(
            constraints: BoxConstraints.expand(height: 50),
            child: Text("ลืมรหัสผ่าน",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.white)),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.red[300]),
            margin: EdgeInsets.only(top: 12),
            padding: EdgeInsets.all(12)),
        onTap: () => navigateToResetPasswordPage(context));
  }

  navigateToResetPasswordPage(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => ResetPasswordScreen()));
  }

  Widget buildButtonFacebook(BuildContext context) {
    return InkWell(
        child: Container(
            constraints: BoxConstraints.expand(height: 50),
            child: Text("เข้าใช้งานด้วย Facebook",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.white)),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.blue[600]),
            margin: EdgeInsets.only(top: 12),
            padding: EdgeInsets.all(12)),
        onTap: () => signInWithFacebook(context));
  }

  Widget buildButtonGoogle(BuildContext context) {
    return InkWell(
        child: Container(
            constraints: BoxConstraints.expand(height: 50),
            child: Text("เข้าใช้งานด้วย Google",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey[700])),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16), color: Colors.white),
            margin: EdgeInsets.only(top: 12),
            padding: EdgeInsets.all(12)),
        onTap: () => signInWithGoogle(context));
  }

  Widget buildButtonLine(BuildContext context) {
    return InkWell(
        child: Container(
            constraints: BoxConstraints.expand(height: 50),
            child: Text("เข้าใช้งานด้วย Line",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.white)),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.green[400]),
            margin: EdgeInsets.only(top: 12),
            padding: EdgeInsets.all(12)),
        onTap: () => signInWithLine(context));
  }
}
