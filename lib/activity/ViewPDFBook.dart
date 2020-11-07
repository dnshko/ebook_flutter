import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutterapp/model/DashboardResponse.dart';
import 'package:flutterapp/utils/AppPermissionHandler.dart';
import 'package:flutterapp/utils/Constant.dart';
import 'package:flutterapp/utils/app_widget.dart';
import 'package:flutterapp/utils/utils.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';
import 'package:permission_handler/permission_handler.dart';

import '../main.dart';

// ignore: must_be_immutable
class ViewPDFBook extends StatefulWidget {
  Downloads downloads;
  final TargetPlatform platform;

  ViewPDFBook(this.downloads, this.platform);

  @override
  _ViewPDFBookState createState() => _ViewPDFBookState();
}

class _ViewPDFBookState extends State<ViewPDFBook> {
  String path;
  bool isLoading = true;
  String bookName = "0";
  String percentageCompleted = "";
  double _progress = 0;

  get downloadProgress => _progress;

  void initState() {
    super.initState();
    requestPermission();
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$bookName');
  }

  downloadFile() async {
    path = (await _localFile).path;
    if (!File(path).existsSync()) {
      printLogs("File Not Exist");
      final request = Request('GET', Uri.parse(widget.downloads.file));
      final StreamedResponse response = await Client().send(request);
      final contentLength = response.contentLength;
      _progress = 0;
      List<int> bytes = [];
      final file = await _localFile;
      response.stream.listen(
        (List<int> newBytes) {
          bytes.addAll(newBytes);
          final downloadedLength = bytes.length;
          _progress = downloadedLength / contentLength;
          percentageCompleted = (_progress * 100).toStringAsFixed(2).toString();
          percentageCompleted = percentageCompleted + "% Completed";
          setState(() {});
        },
        onDone: () async {
          _progress = 0;
          await file.writeAsBytes(bytes);
          if (!mounted) return;
          setState(() {
            isLoading = false;
          });
        },
        onError: (e) {
          printLogs(e);
        },
        cancelOnError: true,
      );
    } else {
      printLogs("File Exist");
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  void requestPermission() async {
    if (widget.platform == TargetPlatform.android) {
      var result =
          await requestPermissionGranted(context, [PermissionGroup.storage]);
      if (result) {
        bookName = getFileNewName(widget.downloads);
        // loadPdf();
        downloadFile();
      } else {
        Navigator.of(context).pop();
      }
    }
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
          if (isLoading)
            Center(
              child: Column(
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      strokeWidth: 15,
                      value: downloadProgress,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: spacing_standard_new),
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
          else
            Container(
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
