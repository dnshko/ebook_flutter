import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutterapp/adapterView/BookList.dart';
import 'package:flutterapp/model/AuthorListResponse.dart';
import 'package:flutterapp/model/DashboardResponse.dart';
import 'package:flutterapp/network/rest_api_call.dart';
import 'package:flutterapp/utils/Constant.dart';
import 'package:flutterapp/utils/app_widget.dart';
import 'package:nb_utils/nb_utils.dart';

import '../app_localizations.dart';
import '../main.dart';
import 'BookDetails.dart';

// ignore: must_be_immutable
class AuthorDetails extends StatefulWidget {
  AuthorListResponse authorDetails;
  String url;
  String fullName;

  AuthorDetails(this.authorDetails, this.url, this.fullName);

  @override
  _AuthorDetailsState createState() => _AuthorDetailsState();
}

class _AuthorDetailsState extends State<AuthorDetails> {
  bool mIsLoading = false;
  var mAuthorBookList;

  @override
  void initState() {
    super.initState();
    getAuthorList();
  }

  Future getAuthorList() async {
    mIsLoading = true;
    await isNetworkAvailable().then((bool) async {
      if (bool) {
        await getAuthorBookListRestApi(widget.authorDetails.id)
            .then((res) async {
          mIsLoading = false;
          Iterable mCategory = res;
          mAuthorBookList = mCategory
              .map((model) => BookInfoDetails.fromJson(model))
              .toList();

          setState(() {});
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
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.only(
            top: 50,
          ),
          child: Stack(
            children: <Widget>[
              Row(
                children: <Widget>[
                  backIcons(context),
                  SizedBox(
                    width: 20,
                  ),
                  new Container(
                    width: authorImageSize-20,
                    height: authorImageSize-20,
                    decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      image: new DecorationImage(
                        fit: BoxFit.fill,
                        image: new NetworkImage(widget.url),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: spacing_standard),
                    height: 50.0,
                    child: Center(
                      child: Text(
                        widget.fullName,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: fontSize25,
                          color: appStore.appTextPrimaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.only(top: 70),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    (mAuthorBookList != null)
                        ? Padding(
                            padding: const EdgeInsets.only(
                                left: 0,
                                right: 0),
                            child: new GridView.builder(
                                itemCount: mAuthorBookList.length,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    new SliverGridDelegateWithFixedCrossAxisCount(
                                      childAspectRatio: getChildAspectRatio(),
                                      crossAxisCount: getCrossAxisCount(),
                                ),
                                itemBuilder: (BuildContext context, int index) {
                                  return GestureDetector(
                                    child: BookItem(mAuthorBookList[index]),
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BookDetails(
                                          mAuthorBookList[index].id.toString(),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                          )
                        : appLoaderWidget.center().visible(mIsLoading),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
