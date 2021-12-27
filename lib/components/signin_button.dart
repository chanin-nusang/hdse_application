import 'package:flutter/material.dart';

Widget buildSigninButton(BuildContext context,
    {@required Widget? iconWidget,
    @required String? text,
    @required Color? textColor,
    @required Color? buttonColor,
    @required VoidCallback? handler}) {
  return InkWell(
      child: Container(
          constraints: BoxConstraints.expand(height: 50),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              iconWidget!,
              SizedBox(
                width: 10,
              ),
              Text(text!,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: textColor)),
            ],
          ),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16), color: buttonColor),
          margin: EdgeInsets.only(top: 12),
          padding: EdgeInsets.all(12)),
      onTap: handler);
}
