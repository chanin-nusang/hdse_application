import 'package:flutter/material.dart';

Widget buildSigninButton(BuildContext context, iconWidget,
    {@required bool? isRow,
    @required double? height,
    @required double? width,
    @required String? text,
    @required Color? textColor,
    @required Color? buttonColor,
    @required VoidCallback? handler}) {
  return Container(
      height: height,
      width: width,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
            borderRadius: BorderRadius.all(
              Radius.circular(16.0),
            ),
            onTap: handler,
            child: Container(
              padding: EdgeInsets.all(10),
              child: isRow!
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        iconWidget == null ? SizedBox() : iconWidget,
                        iconWidget == null
                            ? SizedBox()
                            : SizedBox(
                                width: 15,
                              ),
                        Text(text!,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 15, color: textColor)),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        iconWidget,
                        SizedBox(
                          height: 2,
                        ),
                        Text(text!,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 15, color: textColor)),
                      ],
                    ),
            )),
      ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16), color: buttonColor),
      margin: EdgeInsets.only(top: 12),
      padding: EdgeInsets.all(0));
}
