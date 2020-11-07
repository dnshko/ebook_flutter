import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutterapp/model/DashboardResponse.dart';

class DownloadedBook {
  int id;
  String bookId;
  String bookName;
  String fileName;
  String frontCover;
  String fileType;
  String filePath;
  DownloadTask mDownloadTask;
  DownloadTaskStatus status = DownloadTaskStatus.undefined;

  DownloadedBook(
      {this.id,
      this.bookId,
      this.bookName,
      this.filePath,
      this.fileName,
      this.frontCover,
      this.fileType});

  factory DownloadedBook.fromJson(Map<String, dynamic> json) {
    return DownloadedBook(
      id: json['id'],
      bookId: json['book_id'],
      bookName: json['book_name'],
      fileName: json['file_Name'],
      filePath: json['file_path'],
      frontCover: json['front_cover'],
      fileType: json['file_type'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['book_id'] = this.bookId;
    data['book_name'] = this.bookName;
    data['file_Name'] = this.fileName;
    data['file_path'] = this.filePath;
    data['front_cover'] = this.frontCover;
    data['file_type'] = this.fileType;
    return data;
  }
}

DownloadTask defaultTask(url) {
  return DownloadTask(status: DownloadTaskStatus.undefined, url: url);
}

DownloadedBook defaultBook(BookInfoDetails mBookDetail, fileType) {
  return DownloadedBook(
      bookId: mBookDetail.id.toString(),
      bookName: mBookDetail.name,
      frontCover: mBookDetail.images[0].src,
      fileType: "pdf");
}
