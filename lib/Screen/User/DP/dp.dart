import 'dart:isolate';
import 'package:appodeal_flutter/appodeal_flutter.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'dart:ui';
import 'package:device_apps/device_apps.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:insaver/Screen/Home/home.dart';
import 'package:insaver/Screen/Media/media.dart';
import 'package:insaver/Screen/Media/mediaData.dart';
import 'package:insaver/Utils/constants.dart';

class UserDP extends StatefulWidget {
  @override
  _UserDPState createState() => _UserDPState();
}

class _UserDPState extends State<UserDP> {
  TextEditingController _userText = TextEditingController();
  InstaProfile? _instaProfile;
  bool _showProgress = false, _isFetching = false;
  List<MediaInfo> media = <MediaInfo>[];
  int progress = 0;
  String filename = '';
  String tag = '';
  ReceivePort _port = ReceivePort();
  Widget ad = Container();

  @override
  void initState() {
    _bindBackgroundIsolate();
    FlutterDownloader.registerCallback(downloadCallBack);
    ad = AppodealBanner();

    super.initState();
  }
  showInterstitialAd() async {
   if (await Appodeal.canShow(AdType.INTERSTITIAL) &&
        await Appodeal.isReadyForShow(AdType.INTERSTITIAL))
      await Appodeal.show(AdType.INTERSTITIAL);
  }

  @override
  void dispose() {
    _unbindBackgroundIsolate();
    super.dispose();
  }

  static void downloadCallBack(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_sendDP_port');
    send!.send([id, status, progress]);
  }

  void _bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_sendDP_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) async {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int pr = data[2];
      if (media.isNotEmpty) {
        final task = media.firstWhere((task) => task.taskId == id);
        if (this.mounted) {
          setState(() {
            task.status = status;
            task.progress = progress;
          });
        }

        print(progress.toString() + '....................');
        if (task.status.value == 3 || status.value == 3) {
          print('Completed.......................');
          String time = DateTime.now().toString();
          await saveToDB(
            'https://www.instagram.com/${task.username}',
            task.filename,
            task.tag,
            task.profile,
            task.username,
            task.savedDir,
            time,
          );
        }
      }
      if (this.mounted) {
        setState(() {
          progress = pr;
        });
      }

      print(progress.toString() + '______________________________________');
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_sendDP_port');
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
            "DP Saver",
            style: TextStyle(
              color: Theme.of(context).accentColor,
              fontSize: 28,
              fontFamily: 'Satisfy',
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
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
        body: SafeArea(
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
                      fetchLoading(_isFetching, context),
                      fetchProgress(_showProgress, context),
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
              ad,
            ],
          ),
        ),
      ),
    );
  }

  downloadButton() {
    return Expanded(
      child: ElevatedButton(
        onPressed: () async {
          hideKeyboard(context);
          try {
            clearEverything();
            if (await checkConnectivity(context)) {
              String user = _userText.text;

              getUser(user);
            } else {
              showSnackbar(context, 'Check your internet connection...');
              return;
            }
          } catch (e) {
            print(e);
            showSnackbar(context, e);
            return;
          }
        },
        child: Text(
          'Download',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          primary: Color(0xFFf85343),
          minimumSize: Size(200, 45),
        ),
      ),
    );
  }

  getUser(String user) async {
    if (await requestPermission()) {
      if (this.mounted) {
        setState(() {
          _isFetching = true;
        });
      }

      _instaProfile = await InstaData.userIdData('$user');
      if (_instaProfile!.profilePicUrl != '') {
        downloadPost(_instaProfile!);
      } else {
        if (this.mounted) {
          setState(() {
            _isFetching = false;
          });
        }
        print(_instaProfile!.id);
        showSnackbar(context, 'Invalid username...');
      }
    }
  }

  downloadPost(InstaProfile _instaProfile) async {
    media = <MediaInfo>[];

    Map<String, String> _postData = Map<String, String>();
    _postData['download'] = _instaProfile.profilePicUrl;
    _postData['thumbnail'] = _instaProfile.profilePicUrl;
    _postData['username'] = _instaProfile.username;
    _postData['profile'] = _instaProfile.profilePicUrl;
    MediaInfo mediaInfo = MediaInfo.fromMap(_postData);
    media.add(mediaInfo);

    if (await checkPermissions()) {
      tag = getRandomString(5);
      if (this.mounted) {
        setState(() {
          _isFetching = false;
          _showProgress = true;
        });
      }
      showInterstitialAd();

      for (var i = 0; i < media.length; i++) {
        MediaInfo mediaInfo = media[i];
        bool isVideo = media[i].download.contains('mp4');
        filename = getFileName(tag, i, isVideo);
        final savePath = path.join(instaDir.path, filename);
        mediaInfo.filename = filename;
        mediaInfo.tag = tag;
        mediaInfo.index = i;
        mediaInfo.savedDir = savePath;
        mediaInfo.taskId = (await FlutterDownloader.enqueue(
          url: mediaInfo.download,
          fileName: filename,
          savedDir: instaDir.path,
          showNotification: (i == 0),
          openFileFromNotification: (i == 0),
        ))!;
      }
    }
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
              SizedBox(height: 10),
              SizedBox(
                width: 200,
                height: 45,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/web').then((value) async {
                      setState(() {});
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
              SizedBox(height: kBottomNavigationBarHeight),
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

  fetchProgress(bool show, BuildContext context) {
    var size = MediaQuery.of(context).size;
    if (show) {
      MediaInfo mediaInfo = media[0];
      return Column(
        children: [
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Theme.of(context).primaryColor,
              ),
              child: Column(
                children: [
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  child: CachedNetworkImage(
                                    imageUrl: mediaInfo.profile,
                                    imageBuilder: (context, imageProvider) {
                                      return Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
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
                                    fadeOutDuration:
                                        Duration(milliseconds: 100),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  mediaInfo.username,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 100,
                            height: 100,
                            child: CachedNetworkImage(
                              imageUrl: mediaInfo.thumbnail,
                              imageBuilder: (context, imageProvider) {
                                return Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color: Colors.grey[200]!,
                                      width: 2,
                                    ),
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
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$progress%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        FAProgressBar(
                          progressColor: Color(0xFFf85343),
                          maxValue: 100,
                          currentValue: progress,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Theme.of(context).primaryColor,
              ),
              child: Material(
                child: InkWell(
                  splashColor: Colors.transparent,
                  onTap: () {
                    Navigator.pushReplacementNamed(
                      context,
                      '/post',
                      arguments: mediaInfo.username,
                    );
                  },
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(width: 15),
                        SvgPicture.asset(
                          "assets/svg/grid.svg",
                          width: IconTheme.of(context).size! - 5,
                          color: Theme.of(context).accentColor,
                        ),
                        SizedBox(width: 20),
                        AutoSizeText(
                          'More posts from ${mediaInfo.username}',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).accentColor,
                          ),
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ),
                color: Colors.transparent,
              ),
            ),
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  clearEverything() {
    if (this.mounted) {
      setState(() {
        _showProgress = false;
        _isFetching = false;
        progress = 0;
      });
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
}
