import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hdse_application/screen/login.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmController = TextEditingController();
  signUp() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmController.text.trim();
    if (password == confirmPassword && password.length >= 6) {
      _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((user) {
        print("Sign up user successful.");
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Login()),
            ModalRoute.withName('/'));
      }).catchError((error) {
        print(error.message);
      });
    } else {
      print("Password and Confirm-password is not match.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("ลงทะเบียนเข้าใช้งาน",
              style: TextStyle(color: Colors.white)),
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
                      buildTextFieldPasswordConfirm(),
                      buildButtonSignUp(context)
                    ],
                  )),
            )));
  }

  Widget buildButtonSignUp(BuildContext context) {
    return InkWell(
      child: Container(
          constraints: BoxConstraints.expand(height: 50),
          child: Text("ลงทะเบียน",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.white)),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.green[200]),
          margin: EdgeInsets.only(top: 16),
          padding: EdgeInsets.all(12)),
      onTap: () => signUp(),
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
            keyboardType: TextInputType.emailAddress,
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

  Container buildTextFieldPasswordConfirm() {
    return Container(
        padding: EdgeInsets.all(12),
        margin: EdgeInsets.only(top: 12),
        decoration: BoxDecoration(
            color: Colors.yellow[50], borderRadius: BorderRadius.circular(16)),
        child: TextField(
            controller: confirmController,
            obscureText: true,
            decoration: InputDecoration.collapsed(hintText: "ยืนยันรหัสผ่าน"),
            style: TextStyle(fontSize: 18)));
  }
}
