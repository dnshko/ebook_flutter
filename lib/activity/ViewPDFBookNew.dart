import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutterapp/app_localizations.dart';
import 'package:flutterapp/model/DashboardResponse.dart';
import 'package:flutterapp/utils/AppPermissionHandler.dart';
import 'package:flutterapp/utils/Constant.dart';
import 'package:flutterapp/utils/app_widget.dart';
import 'package:flutterapp/utils/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';
import 'package:permission_handler/permission_handler.dart';

import '../main.dart';

// ignore: must_be_immutable
class ViewPDFBookNew extends StatefulWidget {
  Downloads downloads;
  final TargetPlatform platform;

  ViewPDFBookNew(this.downloads, this.platform);

  @override
  _ViewPDFBookNewState createState() => _ViewPDFBookNewState();
}

class _ViewPDFBookNewState extends State<ViewPDFBookNew> {
  String path;
  String bookName = "0";
  String percentageCompleted = "";
  ReceivePort _port = ReceivePort();
  _TaskInfo _tasks;
  bool isDownloadFile = false;
  bool isDownloadFailFile = false;
  String _localPath;

  @override
  void initState() {
    super.initState();
    initialDownload();
  }

  // ignore: missing_return
  Future initialDownload() {
    _bindBackgroundIsolate();
    FlutterDownloader.registerCallback(downloadCallback);
    requestPermission();
  }

  void _bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) {
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      final task = _tasks;
      if (task != null) {
        setState(() {
          task.status = status;
          task.progress = progress;
          percentageCompleted = (task.progress).toStringAsFixed(2).toString();
          percentageCompleted = percentageCompleted + "% Completed";
        });
        if (task.status == DownloadTaskStatus.complete) {
          _openDownloadedFile(_tasks);
          setState(() {
            isDownloadFile = true;
          });
        } else if (task.status == DownloadTaskStatus.failed) {
          setState(() {
            isDownloadFailFile = true;
          });
        }
      }
    });
  }

  // ignore: missing_return
  Future<bool> _openDownloadedFile(_TaskInfo task) {
    printLogs(task.link);
    printLogs(task.name);
    path = _localPath + "/" + getFileName(task.link);
    setState(() {
      path = _localPath + "/" + getFileName(task.link);
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  String getFileName(String path) {
    var name = path.split("/");
    String fileNameNew = path;
    if (name.length > 0) {
      fileNameNew = name[name.length - 1];
    }
    fileNameNew = fileNameNew.replaceAll("%", "");
    return fileNameNew;
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
  }

  void requestPermission() async {
    if (widget.platform == TargetPlatform.android) {
      var result =
          await requestPermissionGranted(context, [PermissionGroup.storage]);
      if (!result) {
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

  Future<String> _findLocalPath() async {
    printLogs(widget.platform.toString());
    final directory = widget.platform == TargetPlatform.android
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<Null> _prepare() async {
    final tasks = await FlutterDownloader.loadTasks();
    _tasks =
        _TaskInfo(name: widget.downloads.name, link: widget.downloads.file);
    tasks?.forEach((task) {
      if (_tasks.link == task.url) {
        _tasks.taskId = task.taskId;
        _tasks.status = task.status;
        _tasks.progress = task.progress;
      }
    });
    _localPath = (await _findLocalPath()) + Platform.pathSeparator + 'Download';
    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }

    if (_tasks.status == DownloadTaskStatus.complete) {
      _openDownloadedFile(_tasks);
      setState(() {
        isDownloadFile = true;
      });
    } else if (_tasks.status == DownloadTaskStatus.paused) {
      _resumeDownload(_tasks);
    } else if (_tasks.status == DownloadTaskStatus.undefined) {
      _requestDownload(_tasks);
    }
  }

  void _requestDownload(_TaskInfo task) async {
    task.taskId = await FlutterDownloader.enqueue(
        url: task.link,
        fileName: getFileName(task.link),
        savedDir: _localPath,
        showNotification: true,
        openFileFromNotification: false);
  }

  void _resumeDownload(_TaskInfo task) async {
    String newTaskId = await FlutterDownloader.resume(taskId: task.taskId);
    task.taskId = newTaskId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appStore.scaffoldBackground,
      appBar: appBar(context, title:widget.downloads.name),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          !isDownloadFile
              ? isDownloadFailFile
                  ? new Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                top: spacing_standard_new),
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
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: CircularProgressIndicator(
                              strokeWidth: 15,
                              value: (_tasks != null)
                                  ? _tasks.progress.toDouble()
                                  : 0,
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
                      ),
                    )
              : Container(
                  height: MediaQuery.of(context).size.height * 0.85,
                  child: PdfViewer(
                    filePath: path,
                  ),
                )
        ],
      ),
    );
  }
}

class _TaskInfo {
  final String name;
  final String link;

  String taskId;
  int progress = 0;
  DownloadTaskStatus status = DownloadTaskStatus.undefined;

  _TaskInfo({this.name, this.link});
}
