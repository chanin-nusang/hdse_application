import 'package:flutter/material.dart';
import 'package:hdse_application/screen/chat.dart';
import 'package:hdse_application/screen/home.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(title: 'บริการข้อมูลสุขภาพสำหรับผู้สูงอายุ'),
    );
  }
}
