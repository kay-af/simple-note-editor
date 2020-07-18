import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:note_editor/menu.dart';
import 'package:note_editor/splash.dart';
import 'package:note_editor/writer.dart';
import 'package:page_transition/page_transition.dart';

void main() {
  runApp(EditorApp());
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp
  ]);
}

class EditorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Note editor",
      initialRoute: "/splash",
      theme: ThemeData(
        primaryColor: Colors.white,
        appBarTheme: AppBarTheme(elevation: 4.0),
        fontFamily: "Montserrat",
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.redAccent,
          elevation: 1,
          disabledElevation: 1,
          highlightElevation: 2.0,
          focusElevation: 1.0,
        ),
        snackBarTheme: SnackBarThemeData(
            backgroundColor: Colors.white,
            contentTextStyle: TextStyle(color: Colors.black)),
        splashColor: Colors.black12,
        highlightColor: Colors.black12,
        dialogBackgroundColor: Colors.grey[50],
        tabBarTheme: TabBarTheme(
          indicator: BoxDecoration(
            color: Colors.redAccent,
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.black,
        ),
        scaffoldBackgroundColor: Colors.grey[200],
      ),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case "/splash":
            return PageTransition(
              child: SplashScreen(),
              type: PageTransitionType.fade,
              settings: settings,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut
            );
          case "/menu":
            return PageTransition(
              child: MenuPage(),
              type: PageTransitionType.rightToLeftWithFade,
              settings: settings,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut
            );
          case "/writer":
            return PageTransition(
              child: WriterPage(),
              type: PageTransitionType.rightToLeftWithFade,
              settings: settings,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut
            );
          default:
            return null;
        }
      },
    );
  }
}
