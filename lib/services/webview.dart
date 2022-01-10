import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewService extends StatefulWidget {
  const WebViewService({Key? key, required this.link, required this.title})
      : super(key: key);
  final String link;
  final String title;
  @override
  WebViewServiceState createState() => WebViewServiceState();
}

class WebViewServiceState extends State<WebViewService> {
  @override
  void initState() {
    super.initState();
    // Enable virtual display.
    if (Platform.isAndroid) WebView.platform = AndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: WebView(
        javascriptMode: JavascriptMode.unrestricted,
        initialUrl: widget.link,
      ),
    );
  }
}
