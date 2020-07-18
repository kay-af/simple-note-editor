import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:note_editor/menu.dart';

class SplashScreen extends StatefulWidget {
  static const String ROUTE = "/splash";

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500)).then((val) => playAnim());
  }

  void playAnim() {
    setState(() {
      _opacity = 1;
    });
    Future.delayed(const Duration(seconds: 3)).then((val) {
      setState(() {
        _opacity = 0;
      });
      Future.delayed(const Duration(milliseconds: 500)).then(
          (r) => Navigator.of(context).pushReplacementNamed(MenuPage.ROUTE));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(milliseconds: 500),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 100,
                child: Image.asset(
                  "assets/launcher_icon.png",
                ),
              ),
              SizedBox(height: 60,),
              SpinKitFadingCircle(color: Colors.black,),
            ],
          ),
        ),
      ),
    );
  }
}
