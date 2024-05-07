import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  bool isLoaded = false;
  var loadingPercentage = 0;
  late final WebViewController controller;
  final link = dotenv.env['WEB_VIEW_LINK'] ?? 'https://www.agencexyz.com';
  
  @override
  void initState() {
    super.initState();
    controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(const Color(0x00000000))
    ..setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          setState(() {
            loadingPercentage = progress;
          });
          FlutterNativeSplash.remove();
          // Update loading bar.
        },
        onPageStarted: (String url) {
          loadingPercentage = 0;
        },
        onPageFinished: (String url) {
          setState(() {
            loadingPercentage = 100;
            isLoaded = true;
          });
        },
        onWebResourceError: (WebResourceError error) {},
        onNavigationRequest: (NavigationRequest request) {
          return NavigationDecision.navigate;
        },
      ),
    )
    ..loadRequest(Uri.parse(link));
  }

  @override
  Widget build(BuildContext context) {
    return Stack( 
      children: [
        WebViewWidget(controller: controller),
        loadingPercentage < 100
              ? LinearProgressIndicator(
                  color: Colors.red,
                  value: loadingPercentage / 100.0,
                )
              : Container()
      ]
    );
  }
}