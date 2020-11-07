import 'package:connectivity/connectivity.dart';
import 'package:fancy_bottom_navigation_image/fancy_bottom_navigation_image.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/app_localizations.dart';
import 'package:flutterapp/main.dart';
import 'package:flutterapp/utils/Colors.dart';
import 'package:flutterapp/view/BookStoreView.dart';
import 'package:flutterapp/view/MyLibraryView.dart';
import 'package:flutterapp/view/ProfileView.dart';
import 'package:flutterapp/view/SearchView.dart';

import 'Libaryscreen.dart';

class DashboardActivity extends StatefulWidget {
  @override
  _DashboardActivityState createState() => _DashboardActivityState();
}

class _DashboardActivityState extends State<DashboardActivity> {
  var currentPage = 0;
  bool isWasConnectionLoss = false;

  @override
  void initState() {
    super.initState();
    checkInternetConnection();
  }

  checkInternetConnection() async {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        isWasConnectionLoss = true;
      } else {
        isWasConnectionLoss = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: getView(currentPage),
        ),
      ),
      bottomNavigationBar: FancyBottomNavigationImage(
        circleColor: circleColor,
        activeIconColor: accentColor,
        textColor: textColor,
        inactiveIconColor: inactiveIconColor,
        barBackgroundColor: appStore.appBarColor,
        //barBackgroundColor: ,
        tabs: [
          TabData(
              imageData: "home-run.png",
              title: keyString(context, "title_bookStore")),
          TabData(
              imageData: "librarysolid.png",
              title: keyString(context, "title_myLibrary")),
          TabData(
              imageData: "search.png",
              title: keyString(context, "title_search")),
          TabData(
              imageData: "user.png", title: keyString(context, "title_account"))
        ],
        onTabChangedListener: (position) {
          setState(() {
            currentPage = position;
          });
        },
      ),

      /*bottomNavigationBar: BottomNavigationBar(items: [
          BottomNavigationBarItem(icon: Icon(Icons.search), title: Text('fff')),
          BottomNavigationBarItem(icon: Icon(Icons.search), title: Text('fff'))

        ], backgroundColor: appStore.appBarColor,),*/
    );
  }

  getView(int page) {
    switch (page) {
      case 0:
        return BookStoreView();
      case 1:
        if (isWasConnectionLoss) {
          return OfflineScreen();
        } else {
          return MyLibraryView();
        }
        break;
      case 2:
        return SearchView();
      case 3:
        return ProfileView();
      default:
        return BookStoreView();
    }
  }
}
