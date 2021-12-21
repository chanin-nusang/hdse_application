import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:hdse_application/screen/ResetPassword.dart';
import 'package:hdse_application/screen/home.dart';
import 'package:hdse_application/screen/signup.dart';

class Login extends StatefulWidget {
  Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    checkAuth(context);
    super.initState();
  }

  Future checkAuth(BuildContext context) async {
    User? user = await _auth.currentUser;
    if (user != null) {
      print("Already singed-in with");
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => Home(
                    user: user,
                    title: "ยินดีต้อนรับ",
                  )));
    }
  }

  signIn() async {
    try {
      await _auth.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim());
      print("signed in ${_auth.currentUser?.email ?? ""}");
      checkAuth(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString(), style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future signInWithFacebook() async {
    try {
      // Trigger the sign-in flow
      final LoginResult loginResult = await FacebookAuth.instance.login();

      // Create a credential from the access token
      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(loginResult.accessToken!.token);
      await _auth.signInWithCredential(facebookAuthCredential);
      checkAuth(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString(), style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ));
    }
  }

  // signIn() {
  //   // _auth
  //   //     .signInWithEmailAndPassword(
  //   //         email: emailController.text.trim(),
  //   //         password: passwordController.text.trim())
  //   signInAuth().then((user) {

  //   }).catchError((error) {
  //     print(error);
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //       content: Text(error.message, style: TextStyle(color: Colors.white)),
  //       backgroundColor: Colors.red,
  //     ));
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      buildButtonSignIn(),
                      buildLine("ยังไม่มีบัญชีใช่ไหม?"),
                      buildButtonFacebook(context),
                      buildButtonRegister(),
                      buildLine("หากไม่สามารถเข้าสู่ระบบได้"),
                      buildButtonForgotPassword(context)
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
              context, MaterialPageRoute(builder: (context) => Signup()));
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
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ResetPassword()));
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
                color: Colors.blue[400]),
            margin: EdgeInsets.only(top: 12),
            padding: EdgeInsets.all(12)),
        onTap: () => signInWithFacebook());
  }
}
