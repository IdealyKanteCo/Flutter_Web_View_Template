import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:mon_application/screens/contact_app_screen.dart';
import 'package:mon_application/screens/web_view_screen.dart';

import 'widgets/main_drawer.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  final _routes = {
    '/': (context) => const WebViewScreen(),
    '/contact': (context) => const ContactScreen(),
  };


  MainApp({super.key});
  final bgColor = '#FFFFFF';
  final appBarColor = dotenv.env['APP_BG_COLOR'] ?? '#FFFFFF';
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(scaffoldBackgroundColor: HexColor(bgColor)),
      routes: {
        ..._routes.map((routeName, routeBuilder) {
          return MapEntry(routeName, (context) => Scaffold(
                drawer: const MainDrawer(),
                appBar: AppBar(
                  title: const Text('Teski Shop'),
                  backgroundColor: HexColor(appBarColor),
                ),
                body: SafeArea(
                  child: routeBuilder(context),
                ),
              ));
        }),
      },
    );
  }
}
