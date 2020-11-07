import 'package:flutter/material.dart';
import 'package:flutterapp/utils/app_widget.dart';
import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';

import '../main.dart';

// ignore: must_be_immutable
class PDFScreen extends StatelessWidget {
  String pathPDF = "";
  String title = "";

  PDFScreen(this.pathPDF, this.title);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appStore.scaffoldBackground,
      appBar: appBar(context, title: title),
      body: PdfViewer(
        filePath: pathPDF,
      ),
    );
  }
}
