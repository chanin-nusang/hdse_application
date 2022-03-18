import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hdse_application/screen/backdrop_menu/menu.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class UserAccount extends StatefulWidget {
  const UserAccount({Key? key}) : super(key: key);

  @override
  State<UserAccount> createState() => _UserAccountState();
}

class _UserAccountState extends State<UserAccount> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  DateTime? birthday;
  DateTime? selectedDate;
  DocumentSnapshot? snapShot;
  String? phoneNumber;
  String? displayName;
  @override
  void initState() {
    syncUserData();
    user = _auth.currentUser!;
    super.initState();
  }

  @override
  void dispose() {
    selectedDate = null;
    birthday = null;
    super.dispose();
  }

  syncUserData() async {
    var snap = await FirebaseFirestore.instance
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .get();
    if (snap.data()!['name'] != null) {
      setState(() {
        displayName = snap.data()!['name'].toString();
      });
    } else {
      displayName = null;
    }
    if (snap.data()!['birthday'] != null) {
      setState(() {
        birthday = snap.data()!['birthday'].toDate();
        selectedDate = birthday;
      });
    } else {
      birthday = null;
    }
    if (snap.data()!['phoneNumber'] != null) {
      setState(() {
        phoneNumber = snap.data()!['phoneNumber'].toString();
      });
    } else {
      phoneNumber = null;
    }
  }

  _showEditUsersDataDialog(
      BuildContext context, String field, String title, String? data) {
    showDialog(
        context: context,
        builder: (_) {
          TextEditingController textController = TextEditingController();
          textController.text = data ?? '';
          return AlertDialog(
            contentPadding: EdgeInsets.fromLTRB(5.0, 15.0, 5.0, 15.0),
            scrollable: true,
            content: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          color: Colors.white,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: TextField(
                                    controller: textController,
                                    decoration: InputDecoration.collapsed(
                                        hintText: "เพิ่มข้อมูล"),
                                    style: TextStyle(fontSize: 18)),
                              ),
                            ],
                          ),
                        ),
                        Divider(color: Colors.grey),
                        SizedBox(
                          height: 30,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.white)),
                                onPressed: () {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                },
                                child: Text(
                                  "ยกเลิก",
                                  style: TextStyle(
                                      fontSize: 17, color: Colors.red),
                                )),
                            ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.green)),
                                onPressed: () async {
                                  try {
                                    if (field == 'name') {
                                      user!
                                          .updateDisplayName(
                                              textController.text)
                                          .then((value) {
                                        print(
                                            "Name has been changed successfully");
                                        setState(() {
                                          displayName = textController.text;
                                        });
                                      }).catchError((e) {
                                        print(
                                            "There was an error updating profile : $e");
                                      });
                                    }
                                    if (field == 'phoneNumber') {
                                      setState(() {
                                        phoneNumber = textController.text;
                                      });
                                    }

                                    FirebaseFirestore.instance
                                        .collection("users")
                                        .doc(user!.uid)
                                        .update({field: textController.text});
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text("$titleเรียบร้อยแล้ว",
                                          style: GoogleFonts.sarabun(
                                              textStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18))),
                                      backgroundColor: Colors.green,
                                    ));

                                    Navigator.of(context, rootNavigator: true)
                                        .pop();
                                  } catch (e) {
                                    print(e);
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text(
                                          "ไม่สามารถ$titleได้ โปรดลองอีกครั้ง",
                                          style: GoogleFonts.sarabun(
                                              textStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18))),
                                      backgroundColor: Colors.red,
                                    ));
                                  }
                                },
                                child: Text(
                                  "แก้ไข",
                                  style: TextStyle(
                                      fontSize: 17, color: Colors.white),
                                )),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('บัญชีผู้ใช้งาน'),
      ),
      body: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Container(
          padding: EdgeInsets.only(top: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Text(
                  'ชื่อ-นามสกุล',
                  style: TextStyle(fontSize: 15),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                decoration: BoxDecoration(boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 3.0,
                      offset: Offset(0, 2))
                ], color: Colors.white),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      _showEditUsersDataDialog(
                          context, 'name', 'แก้ไขชื่อ', user!.displayName!);
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.only(left: 30, right: 30),
                            alignment: Alignment.centerLeft,
                            height: 60,
                            child: Text(
                              displayName ?? '(ยังไม่มีชื่อ)',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 30),
                          child: Icon(
                            Icons.edit,
                            color: Colors.grey,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Text(
                  'อีเมล',
                  style: TextStyle(fontSize: 15),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                decoration: BoxDecoration(boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 3.0,
                      offset: Offset(0, 2))
                ], color: Colors.white),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(left: 30, right: 30),
                        alignment: Alignment.centerLeft,
                        height: 60,
                        child: Text(
                          user!.email ?? '(ไม่พบอีเมล)',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Text(
                  'วันเกิด',
                  style: TextStyle(fontSize: 15),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                decoration: BoxDecoration(boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 3.0,
                      offset: Offset(0, 2))
                ], color: Colors.white),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageTransition(
                            duration: const Duration(milliseconds: 250),
                            reverseDuration: const Duration(milliseconds: 250),
                            type: PageTransitionType.fade,
                            child: new SelectDateDialog(
                              selectedDate: selectedDate,
                              callback: () => syncUserData(),
                            )),
                      );
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.only(left: 30, right: 30),
                            alignment: Alignment.centerLeft,
                            height: 60,
                            child: Text(
                              birthday != null
                                  ? '${birthday!.day}/${birthday!.month}/${birthday!.year + 543}'
                                  : '(ไม่ได้ระบุวันเกิด)',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 30),
                          child: Icon(
                            Icons.edit,
                            color: Colors.grey,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Text(
                  'โทรศัพท์',
                  style: TextStyle(fontSize: 15),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                decoration: BoxDecoration(boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 3.0,
                      offset: Offset(0, 2))
                ], color: Colors.white),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      _showEditUsersDataDialog(context, 'phoneNumber',
                          'แก้ไขเบอร์โทรศัพท์', phoneNumber);
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.only(left: 30, right: 30),
                            alignment: Alignment.centerLeft,
                            height: 60,
                            child: Text(
                              (phoneNumber != null && phoneNumber! != '')
                                  ? phoneNumber!
                                  : '(ไม่มีเบอร์โทรศัพท์)',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 30),
                          child: Icon(
                            Icons.edit,
                            color: Colors.grey,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class SelectDateDialog extends StatefulWidget {
  const SelectDateDialog({Key? key, this.selectedDate, this.callback})
      : super(key: key);
  final DateTime? selectedDate;
  final VoidCallback? callback;
  @override
  State<SelectDateDialog> createState() => _SelectDateDialogState();
}

class _SelectDateDialogState extends State<SelectDateDialog> {
  DateTime? selectedDate;
  @override
  void initState() {
    selectedDate = widget.selectedDate;
    super.initState();
  }

  @override
  void dispose() {
    selectedDate = null;
    super.dispose();
  }

  selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      locale: const Locale("th", "TH"),
      initialDate:
          selectedDate != null ? selectedDate! : DateTime.now(), // Refer step 1
      firstDate: DateTime(1900),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            GestureDetector(
              child: Container(
                padding: EdgeInsets.only(left: 20, right: 20),
                color: Colors.black.withOpacity(0.8),
              ),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 30, right: 30),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'แก้ไขวันเกิด',
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          color: Colors.white,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                selectDate(context);
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    selectedDate != null
                                        ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year + 543}'
                                        : '(ไม่ได้ระบุวันเกิด)',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  Icon(
                                    Icons.event,
                                    color: Colors.grey,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        Divider(color: Colors.grey),
                        SizedBox(
                          height: 30,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.white)),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  "ยกเลิก",
                                  style: TextStyle(
                                      fontSize: 17, color: Colors.red),
                                )),
                            ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.green)),
                                onPressed: () async {
                                  try {
                                    FirebaseFirestore.instance
                                        .collection("users")
                                        .doc(user!.uid)
                                        .update({
                                      "birthday": selectedDate
                                    }).then((value) {
                                      widget.callback!.call();
                                    });
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text("แก้ไขวันเกิดเรียบร้อยแล้ว",
                                          style: GoogleFonts.sarabun(
                                              textStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18))),
                                      backgroundColor: Colors.green,
                                    ));

                                    Navigator.of(context, rootNavigator: false)
                                        .pop();
                                  } catch (e) {
                                    print(e);
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text(
                                          "ไม่สามารถแก้ไขวันเกิดได้ โปรดลองอีกครั้ง",
                                          style: GoogleFonts.sarabun(
                                              textStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18))),
                                      backgroundColor: Colors.red,
                                    ));
                                  }
                                },
                                child: Text(
                                  "แก้ไข",
                                  style: TextStyle(
                                      fontSize: 17, color: Colors.white),
                                )),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ));
  }
}
