import 'package:flutter/material.dart';
import 'package:note_editor/menu.dart';
import 'package:note_editor/writer.dart';

void main() {
  runApp(EditorApp());
}

class EditorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Note editor",
      initialRoute: "/menu",
      theme: ThemeData(
        primaryColor: Colors.white,
        appBarTheme: AppBarTheme(
          elevation: 4.0
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.redAccent,
          elevation: 1,
          disabledElevation: 1,
          highlightElevation: 2.0,
          focusElevation: 1.0,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Colors.white,
          contentTextStyle: TextStyle(color: Colors.black)
        ),
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
      routes: {
        MenuPage.ROUTE: (context) => MenuPage(),
        WriterPage.ROUTE: (context) => WriterPage()
      },
    );
  }
}