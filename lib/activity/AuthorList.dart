import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutterapp/adapterView/AuthorListItem.dart';
import 'package:flutterapp/app_localizations.dart';
import 'package:flutterapp/model/AuthorListResponse.dart';
import 'package:flutterapp/network/rest_api_call.dart';
import 'package:flutterapp/utils/app_widget.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import 'AuthorDetails.dart';

class AuthorList extends StatefulWidget {
  @override
  _AuthorListState createState() => _AuthorListState();
}

class _AuthorListState extends State<AuthorList> {
  bool mIsLoading = false;
  var mAuthorList = List<AuthorListResponse>();

  @override
  void initState() {
    super.initState();
    getAuthorList();
  }

  Future getAuthorList() async {
    mIsLoading = true;
    await isNetworkAvailable().then((bool) async {
      if (bool) {
        await getAuthorListRestApi().then((res) async {
          mIsLoading = false;
          Iterable mCategory = res;
          mAuthorList.clear();
          mAuthorList = mCategory
              .map((model) => AuthorListResponse.fromJson(model))
              .toList();
          // mAuthorList.sort((a, b) => a.name.compareTo(b.name));
          setState(() {});
        });
      } else {
        toast(keyString(context, "msg_no_internet"));
        if (!mounted) return;
      }
    });
  }

  String getAuthorName(authorListResponse) {
    return authorListResponse.firstName + " " + authorListResponse.lastName;
  }

  @override
  Widget build(BuildContext context) {
    Widget mainView = SingleChildScrollView(
      primary: false,
      child: Container(
        padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            20.height,
            SearchEditText(
              hintText: keyString(context, "lbl_search_by_author_name"),
            ).visible(mAuthorList.isNotEmpty),
            Container(
              margin: EdgeInsets.only(top: 20),
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                physics: BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return new GestureDetector(
                    child: AuthorListItem(mAuthorList[index]),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AuthorDetails(
                          mAuthorList[index],
                          mAuthorList[index].gravatar,
                          getAuthorName(mAuthorList[index]),
                        ),
                      ),
                    ),
                  );
                },
                itemCount: mAuthorList.length,
                shrinkWrap: true,
              ),
            ).visible(mAuthorList.isNotEmpty),
          ],
        ),
      ),
    );
    return Scaffold(
      backgroundColor: appStore.scaffoldBackground,
      appBar: appBar(context, title: keyString(context, "lbl_author")),
      body: RefreshIndicator(
        onRefresh: () {
          return getAuthorList();
        },
        child: Stack(alignment: Alignment.center, children: [
          mainView,
          appLoaderWidget.center().visible(mIsLoading),
        ]),
      ),
    );
  }
}
