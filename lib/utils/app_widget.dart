import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutterapp/activity/Libaryscreen.dart';
import 'package:flutterapp/activity/PDFScreen.dart';
import 'package:flutterapp/main.dart';
import 'package:flutterapp/model/downloaded_book.dart';
import 'package:flutterapp/utils/Colors.dart';
import 'package:flutterapp/utils/Constant.dart';
import 'package:flutterapp/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_localizations.dart';
import 'epub_kitty.dart';

BoxDecoration boxDecoration(
    {double radius = 2,
    Color color = Colors.transparent,
    Color bgColor = Colors.white,
    var showShadow = false}) {
  return BoxDecoration(
      //gradient: LinearGradient(colors: [bgColor, whiteColor]),
      color: bgColor,
      boxShadow: showShadow
          ? [
              BoxShadow(
                  color: appStore.isDarkModeOn
                      ? appStore.scaffoldBackground
                      : shadow_color,
                  blurRadius: 10,
                  spreadRadius: 2)
            ]
          : [BoxShadow(color: Colors.transparent)],
      border: Border.all(color: color),
      borderRadius: BorderRadius.all(Radius.circular(radius)));
}

// ignore: must_be_immutable
class EditTextBorder extends StatefulWidget {
  var isPassword;
  var isSecure;
  int fontSize;
  var textColor;
  var fontFamily;
  var text;
  var hint;
  var maxLine;
  TextEditingController mController;

  VoidCallback onPressed;

  EditTextBorder(
      {var this.fontSize = textSizeNormal,
      var this.textColor = textPrimaryColor,
      var this.isPassword = true,
      var this.hint = "",
      var this.isSecure = false,
      var this.text = "",
      var this.mController,
      var this.maxLine = 1});

  @override
  State<StatefulWidget> createState() {
    return EditTextBorderState();
  }
}

class EditTextBorderState extends State<EditTextBorder> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.mController,
      obscureText: widget.isPassword,
      cursorColor: primaryColor,
      style: TextStyle(
          fontSize: widget.fontSize.toDouble(),
          color: textPrimaryColor,
          fontFamily: widget.fontFamily),
      decoration: InputDecoration(
        suffixIcon: widget.isSecure
            ? GestureDetector(
                onTap: () {
                  setState(() {
                    widget.isPassword = !widget.isPassword;
                  });
                },
                child: new Icon(widget.isPassword
                    ? Icons.visibility
                    : Icons.visibility_off),
              )
            : null,
        contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
        hintText: widget.hint,
        hintStyle: TextStyle(color: textColorThird, fontSize: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: view_color, width: 0.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: view_color, width: 0.0),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class EditText extends StatefulWidget {
  var isPassword;
  var hintText;
  var isSecure;
  int fontSize;
  var textColor;
  var fontFamily;
  var text;
  var visible;

  var maxLine;
  TextEditingController mController;
  VoidCallback onPressed;

  EditText({
    var this.fontSize = textSizeNormal,
    var this.textColor = textPrimaryColor,
    var this.hintText = '',
    var this.isPassword = true,
    var this.isSecure = false,
    var this.text = "",
    var this.mController,
    var this.maxLine = 1,
    var this.visible = false,
  });

  @override
  State<StatefulWidget> createState() {
    return EditTextState();
  }
}

class EditTextState extends State<EditText> {
  @override
  Widget build(BuildContext context) {
    if (!widget.isSecure) {
      return TextField(
        controller: widget.mController,
        obscureText: widget.isPassword,
        cursorColor: primaryColor,
        maxLines: widget.maxLine,
        readOnly: widget.visible,
        style: TextStyle(
            fontSize: widget.fontSize.toDouble(),
            color: appStore.appTextPrimaryColor,
            fontFamily: widget.fontFamily),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(26, 16, 4, 16),
          hintText: widget.hintText,
          hintStyle: TextStyle(color: appStore.textSecondaryColor),
          fillColor: appStore.editTextBackColor,
          filled: true,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                BorderSide(color: appStore.editTextBackColor, width: 0.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                BorderSide(color: appStore.editTextBackColor, width: 0.0),
          ),
        ),
      );
    } else {
      return TextField(
        controller: widget.mController,
        obscureText: widget.isPassword,
        cursorColor: primaryColor,
        style: TextStyle(
            fontSize: widget.fontSize.toDouble(),
            color: appStore.appTextPrimaryColor,
            fontFamily: widget.fontFamily),
        decoration: InputDecoration(
          suffixIcon: new GestureDetector(
            onTap: () {
              setState(() {
                widget.isPassword = !widget.isPassword;
              });
            },
            child: new Icon(
              widget.isPassword ? Icons.visibility : Icons.visibility_off,
              color: appStore.iconColor,
            ),
          ),
          contentPadding: EdgeInsets.fromLTRB(26, 18, 4, 18),
          hintText: widget.hintText,
          hintStyle: TextStyle(color: appStore.textSecondaryColor),
          filled: true,
          fillColor: appStore.editTextBackColor,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                BorderSide(color: appStore.editTextBackColor, width: 0.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                BorderSide(color: appStore.editTextBackColor, width: 0.0),
          ),
        ),
      );
    }
  }
}

enum ConfirmAction { CANCEL, ACCEPT }

// Book Loader View
Widget bookLoaderWidget = Container(
  width: 100,
  height: 100,
  child: Lottie.asset(BOOK_LOADER),
);

Widget viewMoreDataLoader = Container(
  width: 200,
  height: 20,
  child: Lottie.asset(MORE_DATA_LOADER),
);

Widget appDownloadWidget = Container(
  width: appLoaderWH,
  height: appLoaderWH,
  child: Lottie.asset(FILE_DOWNLOAD_LOADER),
);

Widget appLoaderWidget = Container(
  width: appLoaderWH,
  height: appLoaderWH,
  child: Lottie.asset(APP_LOADER),
);

Widget backIcons(context) {
  return GestureDetector(
    child: Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: appStore.editTextBackColor,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(5),
            topRight: Radius.circular(5),
            bottomLeft: Radius.circular(5),
            bottomRight: Radius.circular(5)),
        boxShadow: [
          BoxShadow(
            color: appStore.isDarkModeOn
                ? appStore.scaffoldBackground
                : shadow_color,
            blurRadius: 5,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Image.asset(
        "back.png",
        width: backIconSize,
        height: backIconSize,
        color: appStore.iconColor,
      ),
    ),
    onTap: () {
      Navigator.of(context).pop();
    },
  );
}

bool getDeviceTypePhone() {
  final data = MediaQueryData.fromWindow(WidgetsBinding.instance.window);
  return data.size.shortestSide < 600 ? true : false;
}

double getChildAspectRatio() {
  if (getDeviceTypePhone()) {
    return 180 / 250;
  } else {
    return 150 / 250;
  }
}

int getCrossAxisCount() {
  if (getDeviceTypePhone()) {
    return 2;
  } else {
    return 4;
  }
}

// ignore: must_be_immutable
class AppButton extends StatefulWidget {
  var value;
  VoidCallback onPressed;

  AppButton({@required this.value, @required this.onPressed});

  @override
  State<StatefulWidget> createState() {
    return AppButtonState();
  }
}

class AppButtonState extends State<AppButton> {
  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      padding: EdgeInsets.fromLTRB(spacing_standard_new.toDouble(), 16,
          spacing_standard_new.toDouble(), 16),
      onPressed: widget.onPressed,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
          child: Text(
        widget.value,
        style: boldTextStyle(
          color: Colors.white,
        ),
      )),
      color: primaryColor,
    );
  }
}

Widget getLoadingProgress(loadingProgress) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Center(
      child: CircularProgressIndicator(
        value: loadingProgress.expectedTotalBytes != null
            ? loadingProgress.cumulativeBytesLoaded /
                loadingProgress.expectedTotalBytes
            : null,
      ),
    ),
  );
}

Widget appBar(BuildContext context,
    {List<Widget> actions,
    bool showBack = true,
    bool showTitle = true,
    String title}) {
  return AppBar(
    automaticallyImplyLeading: false,
    backgroundColor: appStore.appBarColor,
    elevation: 0,
    leading: showBack ? backIcons(context) : null,
    title: showTitle
        ? Html(
            data: title,
            defaultTextStyle: boldTextStyle(
                color: appStore.appTextPrimaryColor,
                size: fontSizeLarge.toInt()),
          )
        : null,
    actions: actions,
  );
}

// ignore: must_be_immutable
class SearchEditText extends StatefulWidget {
  var hintText;
  var text;
  TextEditingController mController;
  VoidCallback onPressed;

  SearchEditText({
    var this.hintText = '',
    var this.text = "",
    var this.mController,
  });

  @override
  State<StatefulWidget> createState() {
    return SearchEditTextState();
  }
}

class SearchEditTextState extends State<SearchEditText> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.mController,
      cursorColor: primaryColor,
      maxLines: 1,
      style: TextStyle(
        fontSize: textSizeNormal.toDouble(),
        color: appStore.appTextPrimaryColor,
      ),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(26, 16, 4, 16),
        hintText: widget.hintText,
        hintStyle: primaryTextStyle(color: appStore.textSecondaryColor),
        fillColor: appStore.editTextBackColor,
        filled: true,
        prefixIcon: Icon(
          Icons.search,
          color: appStore.iconColor,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: appStore.editTextBackColor, width: 0.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: appStore.editTextBackColor, width: 0.0),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class CustomTheme extends StatelessWidget {
  Widget child;

  CustomTheme({this.child});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: appStore.isDarkModeOn
          ? ThemeData.dark().copyWith(
              accentColor: primaryColor,
              backgroundColor: appStore.scaffoldBackground,
            )
          : ThemeData.light(),
      child: child,
    );
  }
}

String reviewConvertDate(date) {
  try {
    return date != null
        ? DateFormat(reviewDateFormat).format(DateTime.parse(date))
        : '';
  } catch (e) {
    printLogs(e);
    return '';
  }
}

Widget noInternet(height, width, BuildContext context) {
  return Stack(
    children: [
      Image.asset(
        'images/proShop/noInternet.jpg',
        height: height,
        width: width,
        fit: BoxFit.cover,
      ),
      Positioned(
        bottom: 50,
        left: 0,
        right: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(keyString(context, 'lbl_no_internet'),
                style: boldTextStyle(size: 24, color: textPrimaryColor)),
            4.height,
            Text(
              keyString(context, 'lbl_network_msg'),
              style: secondaryTextStyle(size: 14, color: textSecondaryColor),
              textAlign: TextAlign.center,
            ).paddingOnly(left: 20, right: 20),
            AppButton(
                value: keyString(context, 'lbl_offline_book'),
                onPressed: () {
                  OfflineScreen().launch(context);
                }).paddingAll(16)
          ],
        ).paddingOnly(top: 30),
      )
    ],
  );
}

// ignore: must_be_immutable
class T4Button extends StatefulWidget {
  static String tag = '/T4Button';
  var textContent;
  VoidCallback onPressed;
  var isStroked = false;
  var height = 50.0;

  T4Button(
      {@required this.textContent,
      @required this.onPressed,
      this.isStroked = false,
      this.height = 45.0});

  @override
  T4ButtonState createState() => T4ButtonState();
}

class T4ButtonState extends State<T4Button> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: Container(
        height: widget.height,
        padding: EdgeInsets.fromLTRB(16, 4, 16, 4),
        alignment: Alignment.center,
        child: Text(
          widget.textContent,
          textAlign: TextAlign.center,
          style: primaryTextStyle(
            color: widget.isStroked ? Color(0XFF4600D9) : Colors.white,
          ),
        ),
        decoration: widget.isStroked
            ? boxDecoration(
                bgColor: Colors.transparent, color: Color(0XFF4600D9))
            : boxDecoration(bgColor: Color(0XFF4600D9), radius: 4),
      ),
    );
  }
}

void redirectUrl(url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    toast('Please check URL');
    throw 'Could not launch $url';
  }
}

String getFileName(String path, String bookId) {
  var name = path.split("/");
  String fileNameNew = path;
  if (name.length > 0) {
    fileNameNew = name[name.length - 1];
  }
  fileNameNew = fileNameNew.replaceAll("%", "");
  return bookId + "pdf" + fileNameNew;
}

Future<String> requestDownload(
    {BuildContext context, DownloadedBook downloadTask}) async {
  String path = await localPath;
  var url = downloadTask.mDownloadTask.url.replaceAll(' ', '%20');
  var fileName = getFileName(url, downloadTask.bookId);
  final savedDir = Directory(path);
  bool hasExisted = await savedDir.exists();
  if (!hasExisted) {
    savedDir.create();
  }
  return await FlutterDownloader.enqueue(
    url: url,
    fileName: fileName,
    savedDir: path,
    showNotification: true,
    openFileFromNotification: false,
  );
}

readFile(context, String filePath, String name, {isCloseApp = true}) async {
  printLogs(filePath);
  if (filePath.contains(".pdf")) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => PDFScreen(filePath, name)));
  } else if (filePath.contains(".epub")) {
    if (Platform.isAndroid) {
      EpubKitty.setConfig(
          "book",
          '#${Theme.of(context).primaryColor.value.toRadixString(16)}',
          "vertical",
          true);
      EpubKitty.open(filePath);
      if (isCloseApp) Navigator.of(context).pop();
    } else if (Platform.isIOS) {
      EpubKitty.open(filePath);
      if (isCloseApp) Navigator.of(context).pop();
    }
  }
}
