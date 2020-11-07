import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/app_localizations.dart';
import 'package:flutterapp/network/rest_api_call.dart';
import 'package:flutterapp/utils/Colors.dart';
import 'package:flutterapp/utils/Constant.dart';
import 'package:flutterapp/utils/app_widget.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  var usernameCont = TextEditingController();
  var fullname = TextEditingController();
  var passwordCont = TextEditingController();
  var confirmPasswordCont = TextEditingController();
  bool isLoading = false;

  Future registerUser(request) async {
    await isNetworkAvailable().then((bool) async {
      if (bool) {
        isLoading = true;
        await getRegisterUserRestApi(request).then((res) {
          isLoading = false;
          toast(keyString(context, "lbl_registration_completed"));
          Navigator.pop(context);
          setState(() {});
        }).catchError((error) {
          setState(() {
            isLoading = false;
          });
        });
      } else {
        toast(keyString(context, "msg_no_internet"));
        if (!mounted) return;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appStore.scaffoldBackground,
      appBar: appBar(context, showTitle: false),
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
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: Container(
                        child: Column(
                          children: [
                            EditText(
                              hintText:
                                  keyString(context, "hint_enter_full_name"),
                              isPassword: false,
                              mController: fullname,
                            ),
                            SizedBox(height: 14),
                            EditText(
                              hintText: keyString(context, "hint_enter_email"),
                              isPassword: false,
                              mController: usernameCont,
                            ),
                            SizedBox(height: 14),
                            EditText(
                              hintText:
                                  keyString(context, "hint_enter_password"),
                              isPassword: true,
                              mController: passwordCont,
                              isSecure: true,
                            ),
                            SizedBox(height: 14),
                            EditText(
                              hintText:
                                  keyString(context, "hint_re_enter_password"),
                              isPassword: true,
                              mController: confirmPasswordCont,
                              isSecure: true,
                            ),
                            SizedBox(height: 14.0),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 14),
                    AppButton(
                      value: keyString(context, "lbl_sign_up"),
                      onPressed: () {
                        hideKeyboard(context);
                        var request = {
                          "first_name": "${fullname.text}",
                          "last_name": "${fullname.text}",
                          "username": "${usernameCont.text}",
                          "email": "${usernameCont.text}",
                          "password": "${passwordCont.text}"
                        };
                        if (!mounted) return;
                        setState(() {
                          if (fullname.text.isEmpty)
                            toast(keyString(context, "lbl_full_name") +
                                " " +
                                keyString(context, "lbl_field_required"));
                          else if (usernameCont.text.isEmpty)
                            toast(keyString(context, "lbl_email_id") +
                                " " +
                                keyString(context, "lbl_field_required"));
                          else if (passwordCont.text.isEmpty)
                            toast(keyString(context, "lbl_password") +
                                " " +
                                keyString(context, "lbl_field_required"));
                          else if (confirmPasswordCont.text.isEmpty)
                            toast(keyString(context, "lbl_re_enter_pwd") +
                                " " +
                                keyString(context, "lbl_field_required"));
                          else if (confirmPasswordCont.text !=
                              passwordCont.text)
                            toast(keyString(context, "lbl_pwd_not_match"));
                          else {
                            isLoading = true;
                            registerUser(request);
                          }
                        });
                      },
                    ).paddingOnly(left: 20, right: 20),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(keyString(context, "lbl_already_have_an_account"),
                            style: primaryTextStyle(
                                size: 18, color: appStore.appTextPrimaryColor)),
                        Container(
                          margin: EdgeInsets.only(left: 4),
                          child: GestureDetector(
                              child: Text(keyString(context, "lbl_sign_in"),
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: primaryColor,
                                  )),
                              onTap: () {
                                Navigator.pop(context);
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
