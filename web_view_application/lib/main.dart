import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:mon_application/screens/web_view_screen.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  MainApp({super.key});
  final bgColor = dotenv.env['APP_BG_COLOR'] ?? '#FFFFFF';
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(scaffoldBackgroundColor: HexColor(bgColor)),
      home: const WebViewApplication(),
    );
  }
}

class WebViewApplication extends StatefulWidget {
  const WebViewApplication({super.key});

  @override
  State<WebViewApplication> createState() => _WebViewApplicationState();
}

class _WebViewApplicationState extends State<WebViewApplication> {
  bool isWebViewLoaded = false;
  
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(child: WebViewScreen()) ,
    );
  }
}
