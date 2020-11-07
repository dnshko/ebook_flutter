import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/activity/AboutUs.dart';
import 'package:flutterapp/activity/AuthorList.dart';
import 'package:flutterapp/activity/CategoriesList.dart';
import 'package:flutterapp/activity/ChangePasswordScreen.dart';
import 'package:flutterapp/activity/EditProfileScreen.dart';
import 'package:flutterapp/activity/MyBookMarkScreen.dart';
import 'package:flutterapp/activity/WebViewScreen.dart';
import 'package:flutterapp/app_localizations.dart';
import 'package:flutterapp/utils/Constant.dart';
import 'package:flutterapp/utils/utils.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class ProfileView extends StatefulWidget {
  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool isLoginIn = false;
  String firstName = "";
  String userImage = "";
  String mProfileImage = "";
  SharedPreferences pref;

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  getUserDetails() async {
    isLoginIn = await getBool(IS_LOGGED_IN);
    firstName = await getString(FIRST_NAME);
    printLogs("First name" + firstName);
    mProfileImage = await getString(PROFILE_IMAGE);
    String mAvatar = await getString(AVATAR);
    printLogs("ProfileImage" + mProfileImage);
    printLogs("Avatar" + mAvatar);
    if (mProfileImage.isNotEmpty) {
      userImage = mProfileImage;
    } else {
      userImage = mAvatar;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double imageSize = 25.0;
    double topPadding = 15.0;

    return Scaffold(
      backgroundColor: appStore.scaffoldBackground,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(top: 50, left: 20, right: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                      backgroundImage: NetworkImage(userImage),
                      radius: context.width() * 0.06),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    firstName,
                    style: TextStyle(
                        fontSize: font_size_36,
                        color: appStore.appTextPrimaryColor,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
              Container(
                padding: EdgeInsets.only(
                  top: 50,
                ),
                child: GestureDetector(
                  onTap: () {
                    EditProfileScreen().launch(context);
                  },
                  child: Row(
                    children: [
                      Image.asset(
                        "edit.png",
                        width: imageSize,
                        height: imageSize,
                        color: appStore.iconColor,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        keyString(context, "lbl_edit_profile"),
                        style: TextStyle(
                          fontSize: fontSize25,
                          color: appStore.appTextPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(
                  top: topPadding,
                ),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AuthorList(),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Image.asset(
                        "user.png",
                        width: imageSize,
                        height: imageSize,
                        color: appStore.iconColor,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        keyString(context, "lbl_author"),
                        style: TextStyle(
                          fontSize: fontSize25,
                          color: appStore.appTextPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(
                  top: topPadding,
                ),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoriesList(),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Image.asset(
                        "menu.png",
                        width: imageSize,
                        height: imageSize,
                        color: appStore.iconColor,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        keyString(context, "lbl_categories"),
                        style: TextStyle(
                          fontSize: fontSize25,
                          color: appStore.appTextPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(
                  top: topPadding,
                ),
                child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyBookMarkScreen(),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Image.asset(
                          "bookmark.png",
                          width: imageSize,
                          height: imageSize,
                          color: appStore.iconColor,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          keyString(context, "lbl_my_bookmark"),
                          style: TextStyle(
                            fontSize: fontSize25,
                            color: appStore.appTextPrimaryColor,
                          ),
                        ),
                      ],
                    )),
              ),
              Container(
                padding: EdgeInsets.only(
                  top: topPadding,
                ),
                child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AboutUs(),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Image.asset(
                          "info.png",
                          width: imageSize,
                          height: imageSize,
                          color: appStore.iconColor,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          keyString(context, "lbl_about"),
                          style: TextStyle(
                            fontSize: fontSize25,
                            color: appStore.appTextPrimaryColor,
                          ),
                        ),
                      ],
                    )),
              ),
              Container(
                padding: EdgeInsets.only(
                  top: topPadding,
                ),
                child: GestureDetector(
                  onTap: () {
                    ChangePasswordScreen().launch(context);
                  },
                  child: Row(
                    children: [
                      Image.asset(
                        "password.png",
                        width: imageSize,
                        height: imageSize,
                        color: appStore.iconColor,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        keyString(context, "lbl_change_pwd"),
                        style: TextStyle(
                          fontSize: fontSize25,
                          color: appStore.appTextPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(
                  top: topPadding,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        appStore.toggleDarkMode();
                      },
                      child: Row(
                        children: [
                          Image.asset(
                            "ic_mode.png",
                            width: imageSize,
                            height: imageSize,
                            color: appStore.iconColor,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            keyString(context, "lbl_mode"),
                            style: TextStyle(
                              fontSize: fontSize25,
                              color: appStore.appTextPrimaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: appStore.isDarkModeOn,
                      onChanged: (s) {
                        appStore.toggleDarkMode(value: s);
                        setState(() {});
                      },
                    ).withHeight(24)
                  ],
                ),
              ),
              GestureDetector(
                child: Container(
                  padding: EdgeInsets.only(
                    top: topPadding,
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        "privacy.png",
                        width: imageSize,
                        height: imageSize,
                        color: appStore.iconColor,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        keyString(context, "lbl_term_privacy"),
                        style: TextStyle(
                          fontSize: fontSize25,
                          color: appStore.appTextPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WebViewScreen(TEARM_PRIVACY,
                          keyString(context, "lbl_term_privacy")),
                    ),
                  );
                },
              ),
              Container(
                padding: EdgeInsets.only(
                  top: topPadding,
                ),
                child: GestureDetector(
                  child: Row(
                    children: [
                      Image.asset(
                        "logout.png",
                        width: imageSize,
                        height: imageSize,
                        color: appStore.iconColor,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        keyString(context, "lbl_logout"),
                        style: TextStyle(
                          fontSize: fontSize25,
                          color: appStore.appTextPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    logout(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
