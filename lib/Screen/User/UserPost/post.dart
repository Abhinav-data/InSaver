import 'dart:isolate';
import 'dart:ui';
import 'package:appodeal_flutter/appodeal_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:insaver/Screen/Home/home.dart';
import 'package:insaver/Screen/Media/media.dart';
import 'package:insaver/Screen/Media/mediaData.dart';
import 'package:insaver/Screen/User/UserPost/postdata.dart';
import 'package:insaver/Utils/constants.dart';

class Post extends StatefulWidget {
  final String name;
  Post(this.name);
  @override
  _PostState createState() => _PostState();
}

class _PostState extends State<Post> {
  TextEditingController _userText = TextEditingController();
  InstaProfile? _instaProfile;
  InstaProfile? _iProfile;
  bool _isFetching = false, _showPost = false, _showLogin = false;
  Map<String, bool> values = {};
  ReceivePort _port = ReceivePort();
  List<MediaInfo> media = <MediaInfo>[];
  int progress = 0;
  String tag = '';
  String filename = '';
  Widget ad = Container();

  bool adLoaded = false;

  @override
  void initState() {
    super.initState();

    if (widget.name != '') {
      _userText.text = widget.name;
      WidgetsBinding.instance!
          .addPostFrameCallback((_) => getPosts(widget.name));
    }
    ad = AppodealBanner();
  }

  showInterstitialAd() async {
    if (await Appodeal.canShow(AdType.INTERSTITIAL) &&
        await Appodeal.isReadyForShow(AdType.INTERSTITIAL))
      await Appodeal.show(AdType.INTERSTITIAL);
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        Navigator.of(context).pushReplacementNamed('/home');
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Post Saver",
            style: TextStyle(
              color: Theme.of(context).accentColor,
              fontSize: 28,
              fontFamily: 'Satisfy',
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            onPressed: () async {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              showInterstitialAd();
              Navigator.of(context).pushReplacementNamed('/home');
            },
            icon: Icon(Icons.arrow_back_ios),
          ),
          actions: [
            IconButton(
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
        body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowGlow();
            return true;
          },
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 150,
                          width: size.width,
                          child: Container(
                            color: Theme.of(context).primaryColor,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  SizedBox(height: 10),
                                  TextField(
                                    controller: _userText,
                                    cursorColor: Color(0xFFfa6b60),
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.deny(
                                          RegExp("[ ]")),
                                    ],
                                    decoration: InputDecoration(
                                      contentPadding:
                                          EdgeInsets.fromLTRB(12, 6, 12, 6),
                                      hintText: 'Username here...',
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0xFFfa6b60),
                                          width: 2,
                                        ),
                                        borderRadius:
                                            new BorderRadius.circular(5),
                                      ),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.grey,
                                          width: 2,
                                        ),
                                        borderRadius:
                                            new BorderRadius.circular(5),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Row(
                                    children: [
                                      downloadButton(),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        (!_showPost)
                            ? fetchLoading(_isFetching, context)
                            : Container(),
                        fetchPosts(_showPost),
                      ],
                    ),
                  ),
                ),
                FutureBuilder<bool>(
                  future: checkConnectivity(context),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      bool? con = snapshot.data;
                      if (!con!) {
                        return showNotConnected();
                      }
                    }
                    return Container();
                  },
                ),
                (_showLogin) ? showLoginContainer() : Container(),
                FutureBuilder<bool>(
                  future: checkConnectivity(context),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      bool? con = snapshot.data;
                      if (con! && !_showLogin)
                        return Container(
                          child: ad,
                        );
                    }
                    return Container();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  fetchPosts(bool show) {
    if (show) {
      return Column(
        children: [
          SizedBox(height: 15),
          ListTile(
            leading: Container(
              width: 60,
              height: 60,
              child: CachedNetworkImage(
                imageUrl: _instaProfile!.profilePicUrl,
                imageBuilder: (context, imageProvider) {
                  return Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
                progressIndicatorBuilder: (context, url, downloadProgress) {
                  return Container();
                },
                errorWidget: (context, url, error) {
                  return Icon(Icons.error);
                },
                fadeInDuration: Duration(milliseconds: 100),
                fadeOutDuration: Duration(milliseconds: 100),
              ),
            ),
            title: Text(
              _instaProfile!.username,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: (_isFetching)
                ? CircularProgressIndicator(
                    color: Theme.of(context).canvasColor,
                  )
                : Container(
                    width: 50,
                    height: 50,
                  ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(4),
            child: GridView.builder(
              shrinkWrap: true,
              itemCount: _instaProfile!.userPost.length,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemBuilder: (BuildContext context, int index) {
                UserPost tempUser = _instaProfile!.userPost[index];
                return Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/postgallery',
                          arguments: tempUser.shortcode,
                        );
                      },
                      child: Container(
                        child: CachedNetworkImage(
                          imageUrl: tempUser.thumbnailSrc,
                          imageBuilder: (context, imageProvider) {
                            return Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) {
                            return Container();
                          },
                          errorWidget: (context, url, error) {
                            return Icon(Icons.error);
                          },
                          fadeInDuration: Duration(milliseconds: 100),
                          fadeOutDuration: Duration(milliseconds: 100),
                        ),
                      ),
                    ),
                    Container(
                      height: 20,
                      width: 200,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            spreadRadius: 30,
                          )
                        ],
                      ),
                    ),
                    (tempUser.isVideo)
                        ? Container(
                            child: Icon(Icons.videocam),
                          )
                        : Container(),
                  ],
                );
              },
            ),
          ),
          SizedBox(height: 150),
        ],
      );
    }
    return Container();
  }

  downloadButton() {
    return Expanded(
      child: ElevatedButton(
        onPressed: () async {
          getPosts(_userText.text);
        },
        child: Text(
          'Get Posts',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          primary: color,
          minimumSize: Size(200, 45),
        ),
      ),
    );
  }

  getPosts(String name) async {
    hideKeyboard(context);
    try {
      if (await checkConnectivity(context)) {
        setState(() {
          _isFetching = true;
          _showLogin = false;
        });
        _instaProfile = await PostData.userPosts(name);
        print(_instaProfile!.bio);
        if (_instaProfile!.bio == 'got_info') {
          getCheckBoxes(_instaProfile!.userPost);
          setState(() {
            _isFetching = false;
            _showPost = true;
            _showLogin = false;
          });
        } else if (_instaProfile!.bio == 'login_required') {
          setState(() {
            _isFetching = false;
            _showPost = false;
            _showLogin = true;
          });
        } else {
          setState(() {
            _isFetching = false;
            _showPost = false;
            _showLogin = false;

            showSnackbar(context, 'Invalid username...');
          });
        }
      }
      return;
    } catch (e) {
      print(e);
      showSnackbar(context, e);
      return;
    }
  }

  getCheckBoxes(List<UserPost> list) {
    for (var i = 0; i < list.length; i++) {
      values[list[i].shortcode] = false;
    }
  }

  showNotConnected() {
    return ClipRRect(
      borderRadius: BorderRadius.horizontal(
        left: Radius.circular(10),
        right: Radius.circular(10),
      ),
      child: Container(
        color: Theme.of(context).primaryColor,
        width: 800,
        height: 250 + kBottomNavigationBarHeight,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  SizedBox(height: 20),
                  Icon(
                    Icons.wifi_off_rounded,
                    size: 100,
                  ),
                  Text(
                    'Connect to internet',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: 200,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: () async {
                        bool c = await checkConnectivity(context);
                        if (c) {
                          setState(() {});
                        }
                      },
                      child: Text(
                        'Refresh',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xFFf85343),
                        minimumSize: Size(200, 45),
                      ),
                    ),
                  ),
                  SizedBox(height: kBottomNavigationBarHeight),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  showLoginContainer() {
    return ClipRRect(
      borderRadius: BorderRadius.horizontal(
        left: Radius.circular(10),
        right: Radius.circular(10),
      ),
      child: Container(
        color: Theme.of(context).primaryColor,
        height: 250 + kBottomNavigationBarHeight,
        width: 800,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.account_circle,
                size: 100,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Login to Instagram required.   ',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _showWhyDialogBox(context);
                    },
                    child: Text(
                      'WHY?',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: color,
                        letterSpacing: 1,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 200,
                height: 45,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/web').then((value) async {
                      getPosts(_userText.text);
                    });
                  },
                  child: Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFFf85343),
                    minimumSize: Size(200, 45),
                  ),
                ),
              ),
              SizedBox(height: kBottomNavigationBarHeight - 10),
            ],
          ),
        ),
      ),
    );
  }

  _showWhyDialogBox(context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Theme.of(context).primaryColor,
            title: Text('Why Login?'),
            content: Text(
              'Due to Instagram requirements, you have to login to download stories or posts from private account.\n\nEvery instagram media saver app requires instagram login to download stories/private posts.\n\nWe do not store passwords',
              style: TextStyle(),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'OK',
                  style: TextStyle(color: Theme.of(context).accentColor),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
      },
    );
  }
}
