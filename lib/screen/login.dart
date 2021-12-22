import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
  final GoogleSignIn googleSignIn = GoogleSignIn();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  Map? _userData;
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

  // gen release jks file (pass: 834677)
  //   keytool -genkey -v -keystore c:\Users\Chanin\hdse-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
  // gen Release Key
  // keytool -exportcert -alias hdse -keystore "C:\Users\Chanin\hdse-keystore.jks" | C:\OpenSSL\bin\openssl sha1 -binary | C:\OpenSSL\bin\openssl base64
  // gen Debug Key
  // keytool -exportcert -alias androiddebugkey -keystore "C:\Users\Chanin\.android\debug.keystore" | C:\OpenSSL\bin\openssl sha1 -binary | C:\OpenSSL\bin\openssl base64
  // keytool -exportcert -list -v \ -alias upload -keystore C:\Users\Chanin\hdse-keystore.jks
  // gen certificate fingerprint
  // keytool -list -v -alias <your-key-name> -keystore <path-to-production-keystore>
  // keytool -list -v -alias androiddebugkey -keystore C:\Users\Chanin\.android\debug.keystore
  signIn() async {
    await _auth
        .signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim())
        .then((user) {
      print("signed in ${_auth.currentUser?.email ?? ""}");
      checkAuth(context);
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString(), style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ));
    });
  }

  Future signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
    await _auth
        .signInWithCredential(credential)
        .then((value) => checkAuth(context))
        .catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString(), style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ));
    });
  }

  Future signInWithFacebook(BuildContext context) async {
    // try {
    final LoginResult result = await FacebookAuth.instance.login();
    if (result.status == LoginStatus.success) {
      print("result.status == LoginStatus.success");
      // Create a credential from the access token
      final OAuthCredential credential =
          FacebookAuthProvider.credential(result.accessToken!.token);
      // Once signed in, return the UserCredential
      await _auth.signInWithCredential(credential);
      checkAuth(context);
    }
    // return null;

    // final result =
    //     await FacebookAuth.i.login(permissions: ["public_profile", "email"]);

    // // if (result.status == LoginStatus.success) {
    // final userData = await FacebookAuth.i.getUserData(
    //     // fields: "email,name",
    //     );
    // await _auth.signInWithCredential(
    //     FacebookAuthProvider.credential(result.accessToken!.token));
    // // _userData = null;
    // print("signed in ${_auth.currentUser?.email ?? ""}");
    // checkAuth(context);
    // setState(() {
    //   _userData = userData;
    // });
    // }

    // // Trigger the sign-in flow
    // final LoginResult loginResult = await FacebookAuth.instance.login();

    // // Create a credential from the access token
    // final OAuthCredential facebookAuthCredential =
    //     FacebookAuthProvider.credential(loginResult.accessToken!.token);
    // await _auth.signInWithCredential(
    //     FacebookAuthProvider.credential(result.accessToken!.token));

    // } catch (e) {
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //     content: Text(e.toString(), style: TextStyle(color: Colors.white)),
    //     backgroundColor: Colors.red,
    //   ));
    // }
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
                      buildButtonSignIn(),
                      buildLine("ยังไม่มีบัญชีใช่ไหม?"),
                      buildButtonFacebook(context),
                      buildButtonGoogle(context),
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
        onTap: () => signInWithFacebook(context));
  }

  Widget buildButtonGoogle(BuildContext context) {
    return InkWell(
        child: Container(
            constraints: BoxConstraints.expand(height: 50),
            child: Text("เข้าใช้งานด้วย Google",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey)),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16), color: Colors.white),
            margin: EdgeInsets.only(top: 12),
            padding: EdgeInsets.all(12)),
        onTap: () => signInWithGoogle());
  }
}
