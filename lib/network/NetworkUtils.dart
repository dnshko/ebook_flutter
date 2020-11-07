import 'dart:convert';
import 'dart:io';

import 'package:flutterapp/utils/Constant.dart';
import 'package:flutterapp/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class APICall {
  String url = 'https://iqonic.design/wp-themes/proshop-book/wp-json/';
  String consumerSecret = 'cs_d8906e96e5ca786786b0deff6bb2986905f66437';
  String consumerKey = 'ck_a9f66d00a1e59d6158c9bd2432ab646e0191de65';
  bool isHttps;

  APICall() {
    if (this.url.startsWith("https")) {
      this.isHttps = true;
    } else {
      this.isHttps = false;
    }
  }

  _getOAuthURL(String requestMethod, String endpoint) {
    var url = this.url + endpoint;
    var containsQueryParams = url.contains("?");
    if (this.isHttps == true) {
      return url +
          (containsQueryParams == true
              ? "&consumer_key=" +
                  this.consumerKey +
                  "&consumer_secret=" +
                  this.consumerSecret
              : "?consumer_key=" +
                  this.consumerKey +
                  "&consumer_secret=" +
                  this.consumerSecret);
    }
  }

  Future<http.Response> postMethod(String endPoint, Map data,
      {requireToken = false}) async {
    var url = this._getOAuthURL("POST", endPoint);

    printLogs(url);
    printLogs("Reuqest");
    printLogs(jsonEncode(data));

    var headers = {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
      HttpHeaders.cacheControlHeader: 'no-cache'
    };

    if (requireToken) {
      SharedPreferences pref = await getSharedPref();
      var header = {
        "token": "${pref.getString(TOKEN)}",
        "id": "${pref.getInt(USER_ID)}"
      };
      headers.addAll(header);
    }
    var client = new http.Client();
    var response =
        await client.post(url, body: jsonEncode(data), headers: headers);
    return response;
  }

  Future<http.Response> getMethod(String endpoint,
      {requireToken = false}) async {
    var url = this._getOAuthURL("GET", endpoint);
    printLogs(url);

    var headers = {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
      HttpHeaders.cacheControlHeader: 'no-cache',
      HttpHeaders.authorizationHeader: consumerKey
    };

    if (requireToken) {
      SharedPreferences pref = await getSharedPref();
      var header = {
        "token": "${pref.getString(TOKEN)}",
        "id": "${pref.getInt(USER_ID)}"
      };
      headers.addAll(header);
    }

    final response = await http.get(url, headers: headers);
    // printLogs("Response");
    //printLogs(jsonDecode(response.body));
    return response;
  }
}
