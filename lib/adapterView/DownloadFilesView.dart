import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/activity/AudioBookPlayer.dart';
import 'package:flutterapp/activity/EpubFilenew.dart';
import 'package:flutterapp/activity/VideoBookPlayer.dart';
import 'package:flutterapp/model/DashboardResponse.dart';
import 'package:flutterapp/utils/Constant.dart';
import 'package:flutterapp/utils/app_widget.dart';
import 'package:flutterapp/utils/utils.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path_provider/path_provider.dart';

import '../main.dart';

// ignore: must_be_immutable
class DownloadFilesView extends StatefulWidget {
  Downloads downloads;
  String bookImage = "";
  String bookName = "";
  String mBookId = "0";
  bool isOffline = false;

  DownloadFilesView(this.mBookId, this.downloads, this.bookImage, this.bookName,
      {this.isOffline});

  @override
  _DownloadFilesViewState createState() => _DownloadFilesViewState();
}

class _DownloadFilesViewState extends State<DownloadFilesView> {
  String fileUrl = "";
  bool _isPDFFile = false;
  bool _isVideoFile = false;
  bool _isAudioFile = false;
  bool _isEpubFile = false;
  bool _isDefaultFile = false;
  bool _isFileExist = true;
  String bookId = "0";

  @override
  void initState() {
    super.initState();
    fileUrl = widget.downloads.file.toString();
    final filename = fileUrl.substring(fileUrl.lastIndexOf("/") + 1);
    if (filename.contains(".pdf")) {
      _isPDFFile = true;
    } else if (filename.contains(".mp4") ||
        filename.contains(".mov") ||
        filename.contains(".webm")) {
      _isVideoFile = true;
    } else if (filename.contains(".mp3") || filename.contains(".flac")) {
      _isAudioFile = true;
    } else if (filename.contains(".epub")) {
      _isEpubFile = true;
    } else {
      _isDefaultFile = true;
    }
    // checkFileIsExist();
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    String fileName = getFileNewName(widget.downloads);
    return File('$path/$fileName');
  }

  checkFileIsExist() async {
    String path = (await _localFile).path;
    if (!File(path).existsSync()) {
      _isFileExist = false;
    } else {
      _isFileExist = true;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    return GestureDetector(
      child: Container(
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (_isPDFFile)
                        Image.asset(
                          "pdf.png",
                          width: 24,
                        ),
                      if (_isVideoFile)
                        Image.asset(
                          "video.png",
                          width: 24,
                        ),
                      if (_isAudioFile)
                        Image.asset(
                          "music.png",
                          width: 24,
                        ),
                      if (_isEpubFile)
                        Image.asset(
                          "epub.png",
                          width: 24,
                        ),
                      if (_isDefaultFile)
                        Image.asset(
                          "default.png",
                          width: 24,
                        ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        widget.downloads.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: fontSizeNormal,
                          color: appStore.appTextPrimaryColor,
                        ),
                      )
                    ],
                  ),
                ),
                Flexible(
                  child: (!_isFileExist)
                      ? Image.asset(
                          "downloads.png",
                          width: 24,
                        )
                      : SizedBox(),
                  flex: 1,
                )
              ],
            ),
            Container(
              margin: EdgeInsets.only(
                  top: spacing_standard_new, bottom: spacing_standard),
              height: 1,
            )
          ],
        ),
      ),
      onTap: () {
        if (widget.isOffline == true) {
          readFile(context, widget.downloads.file, widget.bookName);
        } else {
          if (_isPDFFile) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ViewEPubFileNew(
                    widget.mBookId,
                    widget.bookName,
                    widget.bookImage,
                    widget.downloads,
                    platform,
                    true),
              ),
            );
          } else if (_isVideoFile) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VideoBookPlayer(widget.downloads),
              ),
            );
          } else if (_isAudioFile) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AudioBookPlayer(
                  url: widget.downloads.file,
                  bookImage: widget.bookImage,
                  bookName: widget.bookName,
                ),
              ),
            );
          } else if (_isEpubFile) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ViewEPubFileNew(
                    widget.mBookId,
                    widget.bookName,
                    widget.bookImage,
                    widget.downloads,
                    platform,
                    false),
              ),
            );
          } else {
            toast("File format not supported.");
          }
        }
      },
    );
  }
}
