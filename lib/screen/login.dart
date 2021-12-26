import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart' as LineAuth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hdse_application/screen/ResetPassword.dart';
import 'package:hdse_application/screen/home.dart';
import 'package:hdse_application/screen/signup.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'dart:io' show Platform;
import 'dart:convert';
import 'package:flutter/services.dart';

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
  var logger = Logger();

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
  // keytool -list -v -alias upload -keystore C:\Users\Chanin\hdse-keystore.jks
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
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString(), style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ));
    });
  }

  void startLineLogin() async {
    try {
      final result = await LineAuth.LineSDK.instance
          .login(scopes: ["profile", "email", "openid"]);
      print(result.toString());
      var accesstoken = await getAccessToken();
      var displayname = result.userProfile!.displayName;
      var statusmessage = result.userProfile!.statusMessage;
      var imgUrl = result.userProfile!.pictureUrl;
      var userId = result.userProfile!.userId;

      print("AccessToken> " + accesstoken);
      print("DisplayName> " + displayname);
      print("StatusMessage> " + statusmessage!);
      print("ProfileURL> " + imgUrl!);
      print("userId> " + userId);
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString(), style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future getAccessToken() async {
    try {
      final result = await LineAuth.LineSDK.instance.currentAccessToken;
      return result!.value;
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString(), style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future signInWithGoogle() async {
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
        content: Text(e.toString(), style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ));
    }
  }

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

  dynamic tryParseJwt(String token) {
    if (token == null) return null;
    final parts = token.split('.');
    if (parts.length != 3) {
      return null;
    }
    final payload = parts[1];
    var normalized = base64Url.normalize(payload);
    var resp = utf8.decode(base64Url.decode(normalized));
    final payloadMap = json.decode(resp);
    if (payloadMap is! Map<String, dynamic>) {
      return null;
    }
    return payloadMap;
  }

  Future signInWithLine() async {
    final lineLoginResult = await LineAuth.LineSDK.instance
        .login(scopes: ["profile", "email", "openid"]);
    logger.i(lineLoginResult.accessToken.data["id_token"]);
    var jwtDecode;
    if (!Platform.isAndroid || Platform.isIOS) {
      throw PlatformException(
          code: "PLATFORM_NOT_SUPPORT",
          details: "We are currently supported IOS and Android only");
    }
    if (Platform.isIOS) {
      jwtDecode = tryParseJwt(lineLoginResult.accessToken.data["id_token"]);
    }
    if (Platform.isAndroid) {
      jwtDecode = tryParseJwt(lineLoginResult.accessToken.data["id_token"]);
    }
    if (jwtDecode["email"] == null) {
      throw new PlatformException(
          code: "NO_EMAIL_PROVIDED",
          details: "The user doesn't grant the permission to get the email");
    }
    String accessToken = lineLoginResult.accessToken.data["access_token"];
    String displayName = jwtDecode["name"];
    String userId = jwtDecode["sub"];
    String profileImage = jwtDecode["picture"] ??
        "https://firebasestorage.googleapis.com/v0/b/flutter-firebase-d754b.appspot.com/o/avatar-human-male-profile-user-icon-518358.png?alt=media&token=44f84be1-ae20-4b47-aed3-0e67cda10897";
    String email = jwtDecode["email"];
    String channelId = "1656749651";
    Map<String, dynamic> reqBody = {
      "accessToken": accessToken,
      "displayName": displayName,
      "userId": userId,
      "profileImage": profileImage,
      "channelId": channelId,
      "email": email
    };
    print(reqBody);
    var firebaseToken = (await http.post(
            Uri.parse(
                "https://asia-east2-hdse-application.cloudfunctions.net/FirebaseAuth_generateToken"),
            body: reqBody))
        .body;
    await _auth.signInWithCustomToken(firebaseToken);
    checkAuth(context);
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
                      buildButtonSignIn(),
                      buildLine("ยังไม่มีบัญชีใช่ไหม?"),
                      buildButtonFacebook(context),
                      buildButtonLine(),
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
        onTap: () => signInWithGoogle());
  }

  Widget buildButtonLine() {
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
        onTap: () => signInWithLine());
  }
}
