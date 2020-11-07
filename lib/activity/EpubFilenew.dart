import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutterapp/app_localizations.dart';
import 'package:flutterapp/model/DashboardResponse.dart';
import 'package:flutterapp/model/downloaded_book.dart';
import 'package:flutterapp/utils/Constant.dart';
import 'package:flutterapp/utils/app_widget.dart';
import 'package:flutterapp/utils/database_helper.dart';
import 'package:flutterapp/utils/epub_kitty.dart';
import 'package:flutterapp/utils/utils.dart';
import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';

import '../main.dart';

// ignore: must_be_immutable
class ViewEPubFileNew extends StatefulWidget {
  Downloads downloads;
  static String tag = '/EpubFiles';
  String mBookId, mBookName, mBookImage;
  final TargetPlatform platform;
  bool isPDFFile = false;

  ViewEPubFileNew(this.mBookId, this.mBookName, this.mBookImage, this.downloads,
      this.platform, this.isPDFFile);

  @override
  ViewEPubFileNewState createState() => ViewEPubFileNewState();
}

class ViewEPubFileNewState extends State<ViewEPubFileNew> {
  _TaskInfo _tasks;
  bool isDownloadFile = false;
  bool isDownloadFailFile = false;
  String percentageCompleted = "";
  ReceivePort _port = ReceivePort();
  String fullFilePath = "";

  final dbHelper = DatabaseHelper.instance;
  DownloadedBook mSampleDownloadTask;
  DownloadedBook mBookDownloadTask;

  @override
  void initState() {
    super.initState();
    initialDownload();
  }

  // ignore: missing_return
  Future initialDownload() async {
    _bindBackgroundIsolate();
    FlutterDownloader.registerCallback(downloadCallback);
    requestPermission();
  }

  void requestPermission() async {
    if (await checkPermission(widget)) {
      _prepare();
    } else {
      if (widget.platform == TargetPlatform.android) {
        Navigator.of(context).pop();
      } else {
        _prepare();
      }
    }
  }

  @override
  void dispose() {
    _unbindBackgroundIsolate();
    super.dispose();
  }

  void loadBookFromOffline() async {
    DownloadedBook sampleBook;
    var sampleTask;

    if (sampleTask == null) {
      sampleTask = defaultTask(fullFilePath);
    }

    DownloadedBook(
        bookId: widget.mBookId,
        bookName: widget.mBookName,
        frontCover: widget.mBookImage,
        fileType: "sample");
    if (sampleBook == null) {
      sampleBook = DownloadedBook();
    }
    sampleBook.status = sampleTask.status;
    setState(() {
      mSampleDownloadTask = sampleBook;
    });
  }

  void _bindBackgroundIsolate() async {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');

    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }

    _port.listen((dynamic data) async {
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      if (_tasks != null) {
        setState(() {
          _tasks.status = status;
          _tasks.progress = progress;
          percentageCompleted = (_tasks.progress).toStringAsFixed(2).toString();
          percentageCompleted = percentageCompleted + "% Completed";
        });
        if (_tasks.status == DownloadTaskStatus.complete) {
          String path = await localPath;
          String filePath = path + "/" + getFileName(_tasks.link, false);
          printLogs("_bindBackgroundIsolate: " + filePath);
          filePath = filePath.replaceAll("null/", "");
          /**
           * Store data to db for offline usage
           */
          DownloadedBook _download = DownloadedBook();
          _download.bookId = widget.mBookId;
          _download.bookName = widget.mBookName;
          _download.frontCover = widget.mBookImage;
          _download.fileType = widget.isPDFFile ? "PDF File" : "EPub File";
          _download.filePath = filePath;
          _download.fileName = widget.downloads.name;
          await dbHelper.insert(_download);
          _openDownloadedFile(filePath);

          setState(() {
            isDownloadFile = true;
          });
        } else if (_tasks.status == DownloadTaskStatus.failed) {
          setState(() {
            isDownloadFailFile = true;
          });
        }
      }
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: appStore.scaffoldBackground,
      appBar: appBar(context, title: widget.downloads.name),
      body: Builder(
        builder: (context) => !isDownloadFile
            ? isDownloadFailFile
                ? new Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(top: spacing_standard_new),
                          child: Text(
                            keyString(context, "lbl_download_failed"),
                            style: TextStyle(
                                fontSize: fontSizeLarge,
                                color: appStore.appTextPrimaryColor,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  )
                : new Center(
                    child: (_tasks != null)
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 80,
                                height: 80,
                                child: CircularProgressIndicator(
                                  strokeWidth: 15,
                                  value: _tasks.progress.toDouble(),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: spacing_standard_new),
                                child: Text(
                                  percentageCompleted,
                                  style: TextStyle(
                                      fontSize: fontSizeLarge,
                                      color: appStore.appTextPrimaryColor,
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            ],
                          )
                        : SizedBox(),
                  )
            : !widget.isPDFFile
                ? SizedBox()
                : Container(
                    height: MediaQuery.of(context).size.height * 0.85,
                    child: PdfViewer(
                      filePath: fullFilePath,
                    ),
                  ),
      ),
    );
  }

  void _resumeDownload(_TaskInfo task) async {
    String newTaskId = await FlutterDownloader.resume(taskId: task.taskId);
    task.taskId = newTaskId;
  }

  void _retryDownload(_TaskInfo task) async {
    String newTaskId = await FlutterDownloader.retry(taskId: task.taskId);
    task.taskId = newTaskId;
  }

  // ignore: missing_return
  Future<bool> _openDownloadedFile(String filePath) async {
    setState(() {
      fullFilePath = filePath;
    });

    if (!widget.isPDFFile) {
      if (Platform.isAndroid) {
        EpubKitty.setConfig(
            "book",
            '#${Theme.of(context).primaryColor.value.toRadixString(16)}',
            "vertical",
            true);
        EpubKitty.open(filePath);
        Navigator.of(context).pop();
      } else if (Platform.isIOS) {
        EpubKitty.open(filePath);
        Navigator.of(context).pop();
      }
    }
  }

  String getFileName(String path, bool isSample) {
    var name = path.split("/");
    String fileNameNew = path;
    if (name.length > 0) {
      fileNameNew = name[name.length - 1];
    }
    fileNameNew = fileNameNew.replaceAll("%", "");
    return isSample
        ? widget.mBookId + "_sample_" + fileNameNew
        : widget.mBookId + "_purchased_" + fileNameNew;
  }

  Future<Null> _prepare() async {
    final tasks = await FlutterDownloader.loadTasks();
    _tasks = _TaskInfo(
        name: widget.downloads.name,
        link: widget.downloads.file,
        taskId: widget.downloads.id);
    tasks?.forEach((task) {
      if (_tasks.link == task.url) {
        _tasks.taskId = task.taskId;
        _tasks.status = task.status;
        _tasks.progress = task.progress;
      }
    });
    String path = await localPath;
    var url = _tasks.link;
    var fileName = getFileName(url, false);

    final savedDir = Directory(path);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }

    if (_tasks.status == DownloadTaskStatus.complete) {
      String path = await localPath;
      String filePath = path + "/" + fileName;
      printLogs("_prepare: " + filePath);
      filePath = filePath.replaceAll("null/", "");
      _openDownloadedFile(filePath);
      setState(() {
        isDownloadFile = true;
      });
    } else if (_tasks.status == DownloadTaskStatus.paused) {
      _resumeDownload(_tasks);
    } else if (_tasks.status == DownloadTaskStatus.undefined) {
      //_requestDownload(_tasks);
      _tasks.taskId = await FlutterDownloader.enqueue(
          url: _tasks.link,
          fileName: fileName,
          savedDir: path,
          showNotification: true,
          openFileFromNotification: false);
    } else if (_tasks.status == DownloadTaskStatus.failed) {
      _retryDownload(_tasks);
    }
  }
}

class _TaskInfo {
  final String name;
  final String link;

  String taskId;
  int progress = 0;
  DownloadTaskStatus status = DownloadTaskStatus.undefined;

  _TaskInfo({this.name, this.link, this.taskId});
}
