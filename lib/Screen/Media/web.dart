import 'dart:io';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Web extends StatefulWidget {
  @override
  _WebState createState() => _WebState();
}

class _WebState extends State<Web> {
  final String _url = 'https://www.instagram.com/accounts/login/';
  final String cookieValue = 'some-cookie-value';
  final String domain = 'youtube.com';
  final String cookieName = 'some_cookie_name';
  late InAppWebViewController _webViewController;
  CookieManager _cookieManager = CookieManager.instance();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: size.width,
          height: size.height,
          child: InAppWebView(
            initialUrlRequest: URLRequest(
              url: Uri.parse(_url),
            ),
            onWebViewCreated: (InAppWebViewController controller) {
              _webViewController = controller;
            },
            onLoadStop: (InAppWebViewController controller, Uri? url) async {
              print(url);
              List<String> c = [];
              if (url.toString() == 'https://www.instagram.com/') {
                List<Cookie> cookies =
                    await _cookieManager.getCookies(url: (url as Uri));

                cookies.forEach((cookie) {
                  if (cookie.name == 'ds_user_id')
                    c.add(cookie.name + '=' + cookie.value);

                  if (cookie.name == 'sessionid')
                    c.add(cookie.name + '=' + cookie.value);
                });
                if (c.length == 2 && c[0] != '' && c[1] != '') {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  String cookie = c.join('; ');
                  if (cookie != '' && cookie.length != 0) {
                    bool success = await prefs.setString('Cookie', cookie);
                    bool logged = await prefs.setBool('isLogged', success);
                    if (url.toString() == 'https://www.instagram.com/' &&
                        success &&
                        logged &&
                        c.join('; ').length != 0) {
                      if (Navigator.canPop(context)) {
                        Navigator.of(context).pop(logged);
                      }
                    }
                  }
                }
              }
            },
          ),
        ),
      ),
    );
  }
}
