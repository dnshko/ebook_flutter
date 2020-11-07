import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/activity/WalkThrough.dart';
import 'package:flutterapp/utils/Constant.dart';
import 'package:flutterapp/utils/utils.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:splash_screen_view/SplashScreenView.dart';

import '../main.dart';
import 'DashboardActivity.dart';
import 'SignInScreen.dart';

class SplashScreen extends StatefulWidget {
  static String tag = '/SplashScreen';

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with AfterLayoutMixin<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => Scaffold(
          backgroundColor: appStore.scaffoldBackground,
          body:
              /*Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                "main_logo.png",
                width: 200,
              )
            ],
          ),
        ),*/
              SplashScreenView(
            home: SizedBox(),
            duration: 5000,
            imageSize: 200,
            imageSrc: "main_logo.png",
            text: "Bookkart",
            textType: TextType.ColorizeAnimationText,
            textStyle: TextStyle(fontSize: 50.0, fontWeight: FontWeight.bold),
            colors: [
              Color(0xff4268cd),
              Color(0xfff49b4d),
              Color(0xff4268cd),
              Color(0xfff49b4d),
              Color(0xff4268cd),
              Color(0xfff49b4d),
            ],
            backgroundColor: Colors.white,
          )),
    );
  }

  @override
  void afterFirstLayout(BuildContext context) => checkFirstSeen();

  Future checkFirstSeen() async {
    appConfiguration(context);
    bool isFirstTime = await getBool(IS_FIRST_TIME, defaultValue: true);
    if (isFirstTime) {
      await Future.delayed(Duration(seconds: 3));
      AppWalkThrough().launch(context, isNewTask: true);
    } else {
      bool isLoginIn = await getBool(IS_LOGGED_IN);
      if (isLoginIn) {
        await Future.delayed(Duration(seconds: 3));
        DashboardActivity().launch(context, isNewTask: true);
      } else {
        await Future.delayed(Duration(seconds: 3));
        SignInScreen().launch(context, isNewTask: true);
      }
    }
  }
}
