import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hdse_application/components/signin_button.dart';
import 'package:hdse_application/screen/reset_password_screen.dart';
import 'package:hdse_application/screen/signup_screen.dart';
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

  @override
  void initState() {
    lineSDKInit();
    super.initState();
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
                          iconWidget: Icon(Icons.login),
                          text: "เข้าสู่ระบบ",
                          textColor: Colors.black,
                          buttonColor: Colors.green[200],
                          handler: () => emailController.text.isEmpty ||
                                  passwordController.text.isEmpty
                              ? {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Text(
                                        "อีเมล หรือ รหัสผ่าน ไม่ถูกต้อง",
                                        style: TextStyle(color: Colors.white)),
                                    backgroundColor: Colors.red,
                                  ))
                                }
                              : signInWithPassword(context,
                                  emailController: emailController,
                                  passwordController: passwordController)),
                      buildLine("ยังไม่มีบัญชีใช่ไหม?"),
                      buildSigninButton(context,
                          iconWidget: Container(
                              height: 30,
                              width: 30,
                              child: SvgPicture.asset(
                                  "assets/icons/facebooklogo.svg")),
                          text: "เข้าใช้งานด้วย Facebook",
                          textColor: Colors.white,
                          buttonColor: Colors.blue[600], handler: () {
                        signInWithFacebook(context);
                      }),
                      buildSigninButton(context,
                          iconWidget: Container(
                              height: 30,
                              width: 30,
                              child: SvgPicture.asset(
                                  "assets/icons/linelogo.svg")),
                          text: "เข้าใช้งานด้วย Line",
                          textColor: Colors.white,
                          buttonColor: Colors.green[400],
                          handler: () => signInWithLine(context)),
                      buildSigninButton(context,
                          iconWidget: Container(
                              height: 30,
                              width: 30,
                              child: SvgPicture.asset(
                                  "assets/icons/googlelogo.svg")),
                          text: "เข้าใช้งานด้วย Google",
                          textColor: Colors.grey[800],
                          buttonColor: Colors.white,
                          handler: () => signInWithGoogle(context)),
                      buildSigninButton(context,
                          iconWidget: Icon(Icons.person_add),
                          text: "ลงทะเบียน",
                          textColor: Colors.black,
                          buttonColor: Colors.orange[200], handler: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignupScreen()));
                      }),
                      buildLine("หากไม่สามารถเข้าสู่ระบบได้"),
                      buildSigninButton(context,
                          iconWidget: Icon(
                            Icons.password,
                            color: Colors.white,
                          ),
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
}
