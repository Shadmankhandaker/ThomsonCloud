import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:get/get.dart';
import 'package:thomsoncloud2/main.dart';
import 'package:thomsoncloud2/persistent%20_uil.dart';


import 'dart:io';

import 'package:webview_flutter/webview_flutter.dart';

// ignore: must_be_immutable
class WebViewPage extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  var result;
  WebViewPage({Key? key, this.result}) : super(key: key);

  @override
  WebViewState createState() => WebViewState();
}

class WebViewState extends State<WebViewPage> {
  @override
  void initState() {
    super.initState();
    // Enable virtual display.
    if (Platform.isAndroid) WebView.platform = AndroidWebView();
  }

  late WebViewController contoler;

  @override
  Widget build(BuildContext context) {
    var size = (MediaQuery.of(context).size.width);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 31.0),
        child: WebView(
          javascriptMode: JavascriptMode.unrestricted,
          initialUrl: '${widget.result}',
          onWebViewCreated: (contoler) {
            this.contoler = contoler;
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                      title: const Text('Close'),
                      content: const Text(
                          'Do you wish to connect this device to a different URL?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context, 'Cancel'),
                          child: const Text('No'),
                        ),
                        TextButton(
                          onPressed: () {
                            // Phoenix.rebirth(context);
                            Get.off(MyHome());
                            PersistentUrl.RemoveLocalUrl();
                          },
                          child: const Text('Yes'),
                        ),
                      ],
                    ));
          },
          child: const Icon(
            Icons.qr_code,
            size: 36,
          )),
    );
  }
}
