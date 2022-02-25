import 'package:flutter/material.dart';
import 'package:hdse_application/services/check_auth.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    checkAuth(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.yellow[100]!, Colors.green[100]!])),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
