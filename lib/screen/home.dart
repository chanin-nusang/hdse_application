import 'package:flutter/material.dart';
import 'package:hdse_application/screen/chat.dart';

class Home extends StatefulWidget {
  const Home({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child: InkWell(
        child: Container(
          width: 100,
          height: 50,
          color: Colors.lightBlue,
          child: Center(child: Text("ระบบแชทบอท")),
        ),
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Chat()));
        },
        // This trailing comma makes auto-formatting nicer for build methods.
      )),
    );
  }
}
