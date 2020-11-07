import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/app_localizations.dart';
import 'package:flutterapp/model/LoginResponse.dart';
import 'package:flutterapp/network/rest_api_call.dart';
import 'package:flutterapp/utils/Colors.dart';
import 'package:flutterapp/utils/Constant.dart';
import 'package:flutterapp/utils/app_widget.dart';
import 'package:flutterapp/utils/utils.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import 'DashboardActivity.dart';
import 'SignUpScreen.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  var usernameCont = TextEditingController();
  var passwordCont = TextEditingController();
  bool isLoading = false;
  bool isRemember = false;

  Future loginApiCall(request) async {
    await isNetworkAvailable().then((bool) async {
      if (bool) {
        isLoading = true;
        await getLoginUserRestApi(request).then((res) {
          LoginResponse response = LoginResponse.fromJson(res);
          setInt(USER_ID, response.userId);
          setString(FIRST_NAME, response.firstName);
          setString(LAST_NAME, response.lastName);
          setString(USER_EMAIL, response.userEmail);
          setString(USERNAME, response.userNicename);
          setString(TOKEN, response.token);
          setString(AVATAR, response.avatar);
          if (response.profileImage != null) {
            setString(PROFILE_IMAGE, response.profileImage);
          }
          setBool(REMEMBER_PASSWORD, isRemember);

          if (isRemember) {
            setString(EMAIL, usernameCont.text.toString());
            setString(PASSWORD, passwordCont.text.toString());
          } else {
            setString(PASSWORD, "");
            setString(EMAIL, '');
          }
          setString(USER_DISPLAY_NAME, response.userDisplayName);
          setBool(IS_LOGGED_IN, true);
          setState(() {
            isLoading = false;
          });
          DashboardActivity().launch(context, isNewTask: true);
        }).catchError((onError) {
          isLoading = false;
          printLogs(onError.toString());
          toast("Invalid credentials");
          setState(() {});
        });
      } else {
        toast(keyString(context, "msg_no_internet"));
        setState(() {});
        if (!mounted) return;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    var remember = await getBool(REMEMBER_PASSWORD) ?? false;
    if (remember) {
      var password = await getString(PASSWORD);
      var email = await getString(EMAIL);
      setState(() {
        usernameCont.text = email;
        passwordCont.text = password;
      });
    }
    setState(() {
      isRemember = remember;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appStore.scaffoldBackground,
      body: Stack(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.all(spacing_standard_new),
                      child: Column(
                        children: <Widget>[
                          Container(
                            child: Image.asset(
                              "main_logo.png",
                              width: 200,
                            ),
                          ),
                          /*Text(
                            keyString(context, "lbl_books"),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: font_size_36,
                                color: Colors.white),
                          )*/
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: Column(
                        children: [
                          EditText(
                            hintText: keyString(context, "hint_enter_email"),
                            isPassword: false,
                            mController: usernameCont,
                          ),
                          SizedBox(height: 14),
                          EditText(
                            hintText: keyString(context, "hint_enter_password"),
                            isPassword: true,
                            mController: passwordCont,
                            isSecure: true,
                          ),
                          SizedBox(height: 14.0),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        CustomTheme(
                          child: Checkbox(
                            focusColor: primaryColor,
                            activeColor: primaryColor,
                            value: isRemember,
                            onChanged: (bool value) {
                              setState(() {
                                isRemember = value;
                              });
                            },
                          ),
                        ),
                        Text(
                          keyString(context, "lbl_remember_me"),
                          style: secondaryTextStyle(
                              size: 20, color: appStore.textSecondaryColor),
                        )
                      ],
                    ).paddingLeft(spacing_standard),
                    SizedBox(height: 14),
                    AppButton(
                      value: keyString(context, "lbl_sign_in"),
                      onPressed: () {
                        hideKeyboard(context);
                        var request = {
                          "username": "${usernameCont.text}",
                          "password": "${passwordCont.text}"
                        };
                        if (!mounted) return;
                        setState(() {
                          if (usernameCont.text.isEmpty)
                            toast(keyString(context, "lbl_username") +
                                " " +
                                keyString(context, "lbl_field_required"));
                          else if (passwordCont.text.isEmpty)
                            toast(keyString(context, "lbl_password") +
                                " " +
                                keyString(context, "lbl_field_required"));
                          else {
                            isLoading = true;
                            loginApiCall(request);
                          }
                        });
                      },
                    ).paddingOnly(left: 20, right: 20),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      keyString(context, "lbl_forgot_password"),
                      style: secondaryTextStyle(
                          size: 18, color: appStore.textSecondaryColor),
                    ).onTap(() {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => CustomDialog(),
                      );
                    }),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(keyString(context, "lbl_don_t_have_an_account"),
                            style: primaryTextStyle(
                                size: 18, color: appStore.appTextPrimaryColor)),
                        Container(
                          margin: EdgeInsets.only(left: 4),
                          child: GestureDetector(
                              child: Text(keyString(context, "lbl_sign_up"),
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: primaryColor,
                                  )),
                              onTap: () {
                                SignUpScreen().launch(context);
                              }),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          isLoading
              ? Container(
                  child: CircularProgressIndicator(),
                  alignment: Alignment.center,
                )
              : SizedBox(),
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class CustomDialog extends StatelessWidget {
  var email = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    forgotPwdApi() async {
      hideKeyboard(context);
      /* var request = {
        'email': email.text,
      };

      forgetPassword(request).then((res) {
        toast('Successfully Send Email');
        finish(context);
      }).catchError((error) {
        toast(error.toString());
      });*/
    }

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(spacing_control),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: boxDecoration(
            color: Colors.white, radius: 10.0, bgColor: appLayout_background),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // To make the card compact
            children: <Widget>[
              Text(keyString(context, "lbl_forgot_password"),
                      style: boldTextStyle(
                          color: appStore.appTextPrimaryColor, size: 24))
                  .paddingOnly(
                      left: spacing_standard_new.toDouble(),
                      right: spacing_standard_new.toDouble(),
                      top: spacing_standard_new.toDouble()),
              SizedBox(height: spacing_standard_new.toDouble()),
              Column(
                children: [
                  EditText(
                    hintText: keyString(context, "hint_enter_email"),
                    isPassword: false,
                    mController: email,
                  ),
                ],
              ).paddingOnly(
                  left: spacing_standard_new.toDouble(),
                  right: spacing_standard_new.toDouble(),
                  bottom: spacing_standard.toDouble()),
              AppButton(
                value: keyString(context, "lbl_submit"),
                onPressed: () {
                  if (email.text.isEmpty)
                    toast(toast(keyString(context, "lbl_email_id") +
                        " " +
                        keyString(context, "lbl_field_required")));
                  else
                    forgotPwdApi();
                },
              ).paddingAll(spacing_standard_new.toDouble()),
            ],
          ),
        ),
      ),
    );
  }
}
