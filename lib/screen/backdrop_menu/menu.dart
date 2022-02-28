import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hdse_application/screen/backdrop_menu/about_dialog.dart';
import 'package:hdse_application/screen/chatbot/archived_chat_list_screen.dart';
import 'package:hdse_application/screen/home_screen.dart';
import 'package:hdse_application/screen/place_search/archived_places_list_screen.dart';
import 'package:hdse_application/screen/signin/login_screen.dart';
import 'package:hdse_application/services/webview.dart';
import 'package:page_transition/page_transition.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
User? user;

void signOut(BuildContext context) async {
  List<UserInfo> userInfo = _auth.currentUser!.providerData;
  // if (userInfo[0].providerId == "google.com") {
  //   googleSignIn.signOut();
  // }
  // if (userInfo[0].providerId == "facebook.com") {
  //   facebookAuth.logOut();
  // }
  _auth.signOut().then((value) {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => HomeScreen(title: "ยินดีต้อนรับ")),
        ModalRoute.withName('/'));
    print("Sign-out with provider = ${userInfo[0].providerId}");
  }).catchError((error) {
    print(error);
  });
}

Widget menu(BuildContext context) {
  user = _auth.currentUser;
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Container(
                padding: EdgeInsets.all(0),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(24.0),
                    )),
                child: menuTile('แก้ไขข้อมูลของคุณ',
                    icon: Icons.account_circle_rounded,
                    color: Colors.red,
                    label: 'บัญชีผู้ใช้งาน',
                    borderRadius: BorderRadius.all(
                      Radius.circular(24.0),
                    ),
                    onTap: () {})),
            SizedBox(
              height: 15,
            ),
            Container(
                padding: EdgeInsets.all(0),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(24.0),
                    )),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    menuTile('ดูการสนทนาที่บันทึกไว้',
                        icon: Icons.chat_rounded,
                        color: Colors.orange,
                        label: 'ประวัติการสนทนากับแชทบอท',
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24.0),
                          topRight: Radius.circular(24.0),
                        ), onTap: () {
                      if (user != null)
                        Navigator.push(
                          context,
                          PageTransition(
                              duration: const Duration(milliseconds: 250),
                              reverseDuration:
                                  const Duration(milliseconds: 250),
                              type: PageTransitionType.rightToLeft,
                              child: new ArchivedChatListScreen()),
                        );
                      else
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("กรุณาลงชื่อเข้าใช้",
                              style: GoogleFonts.sarabun(
                                  textStyle: TextStyle(
                                      color: Colors.white, fontSize: 18))),
                          backgroundColor: Colors.red,
                        ));
                    }),
                    Divider(
                      height: 1,
                    ),
                    menuTile('ดูรายการสถานที่ที่บันทึกไว้',
                        icon: Icons.bookmarks_rounded,
                        color: Colors.green,
                        label: 'สถานที่ที่บันทึกไว้',
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(25.0),
                          bottomRight: Radius.circular(25.0),
                        ), onTap: () {
                      if (user != null)
                        Navigator.push(
                          context,
                          PageTransition(
                              duration: const Duration(milliseconds: 250),
                              reverseDuration:
                                  const Duration(milliseconds: 250),
                              type: PageTransitionType.rightToLeft,
                              child: new ArchivedPlacesListScreen()),
                        );
                      else
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("กรุณาลงชื่อเข้าใช้",
                              style: GoogleFonts.sarabun(
                                  textStyle: TextStyle(
                                      color: Colors.white, fontSize: 18))),
                          backgroundColor: Colors.red,
                        ));
                    }),
                  ],
                )),
            SizedBox(
              height: 15,
            ),
            Container(
                padding: EdgeInsets.all(0),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(24.0),
                    )),
                child: menuTile('',
                    icon: Icons.settings_rounded,
                    color: Colors.pink,
                    label: 'ตั้งค่า',
                    borderRadius: BorderRadius.all(
                      Radius.circular(24.0),
                    ),
                    onTap: () {})),
            SizedBox(
              height: 15,
            ),
            Container(
                padding: EdgeInsets.all(0),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(24.0),
                    )),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    menuTile('',
                        icon: Icons.gpp_maybe_rounded,
                        color: Colors.purple,
                        label: 'ข้อกำหนดของบริการ',
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24.0),
                          topRight: Radius.circular(24.0),
                        ), onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => WebViewService(
                                  title: 'ข้อกำหนดของบริการ',
                                  link:
                                      'https://www.freeprivacypolicy.com/live/40994482-a2c3-4c7b-a3a0-bafaf4b0d8f9')));
                    }),
                    Divider(
                      height: 1,
                    ),
                    menuTile('',
                        icon: Icons.assignment_late_rounded,
                        color: Colors.blue,
                        label: 'นโยบายความเป็นส่วนตัว',
                        borderRadius: BorderRadius.zero, onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => WebViewService(
                                    title: 'นโยบายความเป็นส่วนตัว',
                                    link:
                                        'https://www.termsandconditionsgenerator.com/live.php?token=sC5eDsc8lvxVb18OwwiEib4K80dlIoNe',
                                  )));
                    }),
                    Divider(
                      height: 1,
                    ),
                    menuTile('ข้อมูลเกี่ยวกับแอปพลิเคชันและผู้พัฒนา',
                        icon: Icons.help_rounded,
                        color: Colors.grey,
                        label: 'เกี่ยวกับ',
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(25.0),
                          bottomRight: Radius.circular(25.0),
                        ), onTap: () {
                      showDialog(
                          context: context,
                          builder: (_) {
                            return aboutDialog(context);
                          });
                    }),
                  ],
                )),
            SizedBox(
              height: 15,
            ),
            Center(
              child: user != null
                  ? ElevatedButton(
                      style: ElevatedButton.styleFrom(primary: Colors.white),
                      onPressed: () {
                        signOut(context);
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.exit_to_app,
                            color: Colors.green[400],
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            "ออกจากระบบ",
                            style: TextStyle(
                                fontSize: 17,
                                color: Colors.green[400],
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      ))
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(primary: Colors.white),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()));
                      },
                      child: Text(
                        " เข้าสู่ระบบ ",
                        style: TextStyle(
                            fontSize: 17,
                            color: Colors.green[400],
                            fontWeight: FontWeight.bold),
                      )),
            ),
          ],
        ),
      );
    },
  );
}

Widget menuTile(String detail,
    {@required IconData? icon,
    @required String? label,
    @required Color? color,
    @required VoidCallback? onTap,
    @required BorderRadius? borderRadius}) {
  return StatefulBuilder(
      builder: (BuildContext context, void Function(void Function()) setState) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
          child: Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(17),
                        color: color?.withOpacity(0.8)),
                    height: 40,
                    width: 40,
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 27,
                    )),
                SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      detail != ''
                          ? Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    label!,
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.black),
                                  ),
                                  SizedBox(
                                    height: 2,
                                  ),
                                  Text(
                                    detail,
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.grey),
                                  )
                                ],
                              ),
                            )
                          : Expanded(
                              child: Text(
                                label!,
                                style: TextStyle(
                                    fontSize: 18, color: Colors.black),
                              ),
                            ),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.grey[600],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  });
}
