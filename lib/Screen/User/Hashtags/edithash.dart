import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:insaver/Screen/Home/home.dart';
import 'package:insaver/Utils/constants.dart';
import 'package:share/share.dart';

class EditTags extends StatefulWidget {
  final String tags;
  EditTags(this.tags);
  @override
  _EditTagsState createState() => _EditTagsState();
}

class _EditTagsState extends State<EditTags> {
  TextEditingController _hashtagText = TextEditingController();
  String text = '';

  @override
  void initState() {
    super.initState();
    text = getTextWithout(widget.tags);
    _hashtagText.text = text;
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Edit Hashtags",
            style: TextStyle(
              color: Theme.of(context).accentColor,
              fontSize: 28,
              fontFamily: 'Satisfy',
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            splashColor: Colors.transparent,
            onPressed: () {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.arrow_back_ios),
          ),
          actions: [
            IconButton(
              splashColor: Colors.transparent,
              onPressed: () async {
                bool isInstalled =
                    await DeviceApps.isAppInstalled('com.instagram.android');
                if (isInstalled) {
                  await DeviceApps.openApp('com.instagram.android');
                }
              },
              icon: SvgPicture.asset(
                "assets/svg/instagram.svg",
                width: IconTheme.of(context).size,
                color: Theme.of(context).accentColor,
              ),
            ),
          ],
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
          iconTheme: Theme.of(context).iconTheme,
        ),
        drawer: InstaDrawer(size: size),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: NotificationListener<OverscrollIndicatorNotification>(
                  onNotification: (overscroll) {
                    overscroll.disallowGlow();
                    return true;
                  },
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Edit:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              TextField(
                                controller: _hashtagText,
                                cursorColor: Color(0xFFfa6b60),
                                maxLines: 10,
                                decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.fromLTRB(12, 6, 12, 6),
                                  hintText: 'Insert word eg. "beard"...',
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0xFFfa6b60),
                                      width: 2,
                                    ),
                                    borderRadius: new BorderRadius.circular(5),
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.grey,
                                      width: 2,
                                    ),
                                    borderRadius: new BorderRadius.circular(5),
                                  ),
                                ),
                                inputFormatters: [
                                  new FilteringTextInputFormatter.allow(
                                    RegExp("[a-zA-Z0-9 ]"),
                                  ),
                                ],
                                style: TextStyle(
                                  fontSize: 16,
                                  height: 1.4,
                                  letterSpacing: 0.9,
                                  wordSpacing: 3,
                                ),
                                onChanged: (tag) {
                                  setState(() {
                                    text = tag;
                                  });
                                },
                              ),
                              SizedBox(height: 20),
                              Text(
                                'Result:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: Container(
                                  color: Theme.of(context).primaryColor,
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        16, 16, 16, 16),
                                    child: Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Clipboard.setData(
                                              ClipboardData(text: widget.tags),
                                            ).then((value) {
                                              showSnackbar(
                                                  context, 'Tags Copied...');
                                            });
                                          },
                                          child: Text(
                                            getHash(text),
                                            style: TextStyle(
                                              fontSize: 16,
                                              height: 1.4,
                                              letterSpacing: 0.9,
                                              wordSpacing: 1.2,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              copyButton(getHash(text)),
                              SizedBox(width: 16),
                              shareButton(getHash(text)),
                            ],
                          ),
                          SizedBox(height: 20),
                          Text(
                            '*Hashtags are automatically added infront of the word',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Expanded copyButton(String tags) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () async {
          hideKeyboard(context);

          Clipboard.setData(ClipboardData(text: tags)).then((value) {
            showSnackbar(context, 'Tags Copied...');
          });
        },
        child: Text(
          'COPY',
          style: TextStyle(
            color: Theme.of(context).accentColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          primary: Theme.of(context).primaryColor,
          minimumSize: Size(200, 45),
        ),
      ),
    );
  }

  Expanded shareButton(String tags) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          hideKeyboard(context);

          Share.share('$tags');
        },
        child: Text(
          'SHARE',
          style: TextStyle(
            color: Theme.of(context).accentColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          primary: Theme.of(context).primaryColor,
          minimumSize: Size(200, 45),
        ),
      ),
    );
  }

  getIcon(int index, String tags) {
    Icon icon;
    if (index == 0)
      icon = Icon(Icons.edit);
    else if (index == 1)
      icon = Icon(Icons.copy);
    else
      icon = Icon(Icons.share);

    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Container(
        child: Material(
          child: InkWell(
            onTap: () {
              hideKeyboard(context);
              if (index == 0) {
                Navigator.pushNamed(context, '/edittag', arguments: tags);
              } else if (index == 1) {
                Clipboard.setData(ClipboardData(text: tags)).then((value) {
                  showSnackbar(context, 'Tags Copied...');
                });
              } else {
                Share.share('$tags');
              }
            },
            child: SizedBox(
              width: 60,
              height: 60,
              child: icon,
            ),
          ),
          color: Colors.transparent,
        ),
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  String getTextWithout(String tag) {
    List<String> a = tag.split(' ');
    for (var i = 0; i < a.length; i++) {
      if (a[i].startsWith('#')) {
        a[i] = a[i].split('#')[1];
      }
    }
    return a.join(' ');
  }

  String getHash(String tag) {
    List<String> a = tag.split(' ');
    for (var i = 0; i < a.length; i++) {
      if (a[i].length != 0) {
        a[i] = '#' + a[i];
      }
    }
    return a.join(' ');
  }
}
