import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/adapterView/CategoriesItem.dart';
import 'package:flutterapp/app_localizations.dart';
import 'package:flutterapp/model/CategoriesListResponse.dart';
import 'package:flutterapp/network/rest_api_call.dart';
import 'package:flutterapp/utils/app_widget.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import 'ViewAllBooks.dart';

class CategoriesList extends StatefulWidget {
  @override
  _CategoriesListState createState() => _CategoriesListState();
}

class _CategoriesListState extends State<CategoriesList> {
  bool mIsLoading = false;
  var mCategoriesList = List<CategoriesListResponse>();
  int page = 1;
  int mPerPage = 20;
  bool isLastPage = false;
  var scrollController = new ScrollController();

  @override
  void initState() {
    super.initState();
    getCategoriesList(page);
    scrollController.addListener(() {
      scrollHandler();
    });
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  scrollHandler() {
    if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent &&
        !isLastPage) {
      page++;
      getCategoriesList(page);
    }
  }

  Future getCategoriesList(page) async {
    setState(() {
      mIsLoading = true;
    });

    await isNetworkAvailable().then((bool) async {
      if (bool) {
        await getCatListRestApi(page, mPerPage).then((res) async {
          Iterable mCategory = res;
          mCategoriesList.addAll(mCategory
              .map((model) => CategoriesListResponse.fromJson(model))
              .toList());
          isLastPage = false;
          setState(() {
            mIsLoading = false;
          });
        });
      } else {
        toast(keyString(context, "msg_no_internet"));
        if (!mounted) return;
      }
    }).catchError((error) {
      if (!mounted) return;
      setState(() {
        isLastPage = true;
        mIsLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget mainView = SingleChildScrollView(
      primary: false,
      controller: scrollController,
      child: Container(
        padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            10.height,
            SearchEditText(
              hintText: keyString(context, "lbl_search_by_categories"),
            ).visible(mCategoriesList.isNotEmpty),
            Container(
              margin: EdgeInsets.only(top: 20),
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return new GestureDetector(
                    child: CategoriesItem(mCategoriesList[index]),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewAllBooks(
                          isCategoryBook: true,
                          categoryId: mCategoriesList[index].id.toString(),
                          categoryName: mCategoriesList[index].name,
                        ),
                      ),
                    ),
                  );
                },
                itemCount: mCategoriesList.length,
                shrinkWrap: true,
              ),
            ).visible(mCategoriesList.isNotEmpty),
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: appBar(context, title: keyString(context, "lbl_categories")),
      backgroundColor: appStore.scaffoldBackground,
      body: RefreshIndicator(
        onRefresh: () {
          page = 1;
          mCategoriesList.clear();
          return getCategoriesList(page);
        },
        child: ListView(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height * 0.85,
              child: mainView,
            ).visible(mCategoriesList.isNotEmpty),
            (mCategoriesList.isNotEmpty)
                ? viewMoreDataLoader.visible(mIsLoading)
                : appLoaderWidget.center().visible(mIsLoading),
          ],
        ),
      ),
    );
  }
}
