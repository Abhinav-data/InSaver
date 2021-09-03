import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:insaver/Screen/Download/download.dart';
import 'package:insaver/Screen/Media/media.dart';
import 'package:insaver/Screen/Whatsapp/whatsapp.dart';
import 'package:insaver/Utils/constants.dart';
import 'package:share/share.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    initializeAppodeal();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final List<Widget> _children = [
      Media(),
      Whatsapp(),
      Download(),
    ];

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        child: _children[currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: _handleIndexChanged,
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        iconSize: 30,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        selectedLabelStyle: TextStyle(color: color),
        unselectedLabelStyle: TextStyle(color: Colors.grey),
        selectedItemColor: color,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesome.whatsapp),
            label: 'Whatsapp',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.download_rounded),
            label: 'Downloads',
          )
        ],
      ),
      appBar: AppBar(
        title: Text(
          (currentIndex == 0)
              ? "InSaver"
              : (currentIndex == 1)
                  ? 'WhatsApp'
                  : 'Downloads',
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
            _scaffoldKey.currentState?.openDrawer();
          },
          icon: SvgPicture.asset(
            "assets/svg/menu.svg",
            width: IconTheme.of(context).size,
            color: Theme.of(context).accentColor,
          ),
        ),
        actions: [
          IconButton(
            splashColor: Colors.transparent,
            onPressed: () async {
              if (currentIndex == 0 || currentIndex == 2) {
                bool isInstalled =
                    await DeviceApps.isAppInstalled('com.instagram.android');
                if (isInstalled) {
                  await DeviceApps.openApp('com.instagram.android');
                }
              } else {
                bool isInstalled =
                    await DeviceApps.isAppInstalled('com.whatsapp');
                if (isInstalled) {
                  await DeviceApps.openApp('com.whatsapp');
                }
              }
            },
            icon: (currentIndex == 1)
                ? Icon(
                    FontAwesome.whatsapp,
                    color: Theme.of(context).accentColor,
                    size: 30,
                  )
                : SvgPicture.asset(
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
    );
  }

  void _handleIndexChanged(int i) {
    if (currentIndex != i) {
      setState(() {
        currentIndex = i;
      });
    }
  }
}

class InstaDrawer extends StatelessWidget {
  const InstaDrawer({
    Key? key,
    required this.size,
  }) : super(key: key);

  final Size size;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Drawer(
      child: Container(
        color: Theme.of(context).primaryColor,
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowGlow();
            return true;
          },
          child: ListView(
            children: [
              SizedBox(
                height: 200,
                width: 1000,
                child: Container(
                  color: Theme.of(context).primaryColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          image: DecorationImage(
                            image: AssetImage(
                              'assets/images/a.png',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      Text(
                        "InSaver",
                        style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 32,
                          fontFamily: 'Satisfy',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 15),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: 6,
                itemBuilder: (context, index) {
                  String text = getText(index);
                  String svg = getSVG(index);
                  return Container(
                    child: Material(
                      child: InkWell(
                        splashColor: Colors.transparent,
                        onTap: () async {
                          getAction(index, context);
                        },
                        child: Container(
                          width: size.width,
                          height: 60,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(width: 40),
                              SvgPicture.asset(
                                "assets/svg/$svg.svg",
                                width: IconTheme.of(context).size! - 2,
                                color: color,
                              ),
                              SizedBox(width: 28),
                              Text(
                                '$text',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).accentColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      color: Colors.transparent,
                    ),
                    color: Theme.of(context).primaryColor,
                  );
                },
              ),
              Container(
                child: Material(
                  child: InkWell(
                    splashColor: Colors.transparent,
                    onTap: () {
                      Navigator.pushNamed(context, '/privacy');
                    },
                    child: Container(
                      width: size.width,
                      height: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(width: 40),
                          Icon(
                            Icons.admin_panel_settings_outlined,
                            color: color,
                          ),
                          SizedBox(width: 28),
                          Text(
                            'Privacy Policy',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).accentColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  color: Colors.transparent,
                ),
                color: Theme.of(context).primaryColor,
              ),
              Container(
                child: Material(
                  child: InkWell(
                    splashColor: Colors.transparent,
                    onTap: () {
                      Navigator.pushNamed(context, '/term');
                    },
                    child: Container(
                      width: size.width,
                      height: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(width: 40),
                          Icon(
                            Icons.border_color_outlined,
                            color: color,
                          ),
                          SizedBox(width: 28),
                          Text(
                            'Terms of use',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).accentColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  color: Colors.transparent,
                ),
                color: Theme.of(context).primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getText(int index) {
    List<String> text = [
      'How to download',
      'Rate us',
      'Dark Mode',
      'Disclaimer',
      'Share',
      'Credits',
    ];
    return text[index];
  }

  String getSVG(int index) {
    List<String> svg = [
      'how',
      'star',
      'moon',
      'disclaimer',
      'share',
      'care',
    ];
    return svg[index];
  }

  _launch(String url) async {
    try {
      await launch(url);
    } catch (e) {}
  }

  _showDisclaimer(context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: Text('Disclaimer'),
              content: Text(
                  'InSaver is an application for Instagram media download. It is not linked or associated with Instagram Application. Kindly download Instagram media with the consent of the respective owner as to not violate any copyrights.'),
              actions: [
                TextButton(
                  child: Text(
                    'Ok',
                    style: TextStyle(color: Theme.of(context).accentColor),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void getAction(int index, context) {
    if (index == 0) {
      Navigator.pushNamed(context, '/howtodownload');
    } else if (index == 1) {
      _launch(url);
    } else if (index == 2) {
      Navigator.pushNamed(context, '/theme');
    } else if (index == 3) {
      _showDisclaimer(context);
    } else if (index == 4) {
      Share.share('Check out this app to download instagram posts\n\n$url');
    } else {
      Navigator.pushNamed(context, '/credits');
    }
  }
}
