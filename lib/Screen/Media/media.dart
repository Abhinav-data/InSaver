import 'dart:async';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';
import 'package:appodeal_flutter/appodeal_flutter.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:insaver/Screen/Media/mediaData.dart';
import 'package:insaver/Utils/constants.dart';
import 'package:insaver/Utils/shareService.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Media extends StatefulWidget {
  @override
  _MediaState createState() => _MediaState();
}

class _MediaState extends State<Media> {
  TextEditingController _linkText = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  PermissionStatus? status;
  int denyCnt = 0;
  int progress = 0;
  String filename = '';
  String tag = '';
  List<MediaInfo> media = <MediaInfo>[];
  InstaProfile? _instaProfile;
  InstaStory? _instaStory;
  InstaPost? _instaPost;
  bool _showProgress = false, _isFetching = false;
  bool _showLogin = false;
  Map<String, String> data = {};
  Widget ad = Container();
  Random random = new Random();
  int rnd = 2;

  ReceivePort _port = ReceivePort();

  @override
  void initState() {
    _bindBackgroundIsolate();
    FlutterDownloader.registerCallback(downloadCallBack);
    _linkText.text = '';
    ShareService()
      ..onDataReceived = _handleSharedData
      ..getSharedData().then(_handleSharedData);
    initializeBanner();
    rnd = random.nextInt(5) + 2;
    super.initState();
  }

  void _handleSharedData(String sharedData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('lastShared') != sharedData &&
        sharedData != '' &&
        sharedData.length != 0) {
      if (!checkLink(sharedData)) {
        _linkText.text = '';
        showSnackbar(context, 'Choose Instagram url...');
      } else {
        _linkText.text = sharedData;
        await prefs.setString('lastShared', sharedData);
        WidgetsBinding.instance!.addPostFrameCallback((_) => downloadFunc());
      }
    }
  }

  void _checkCopiedLink() async {}

  @override
  void dispose() {
    _unbindBackgroundIsolate();
    super.dispose();
  }

  static void downloadCallBack(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send!.send([id, status, progress]);
  }

  void _bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) async {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int pr = data[2];
      print('\n\n\n');

      print(pr);
      print(id);
      print('\n\n\n');
      if (media.isNotEmpty) {
        final task = media.firstWhere((task) => task.taskId == id);
        setState(() {
          task.status = status;
          task.progress = progress;
        });
        if (task.status.value == 3 || status.value == 3) {
          print('Completed.......................');
          String time = DateTime.now().toString();
          await saveToDB(
            _linkText.text,
            task.filename,
            task.tag,
            task.profile,
            task.username,
            task.savedDir,
            time,
          );
        }
      }
      setState(() {
        progress = pr;
      });
      print(progress.toString() + '______________________________________');
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  showInterstitialAd() async {
    if (await Appodeal.canShow(AdType.INTERSTITIAL) &&
        await Appodeal.isReadyForShow(AdType.INTERSTITIAL))
      await Appodeal.show(AdType.INTERSTITIAL);
  }

  initializeBanner() {
    ad = AppodealBanner();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowGlow();
          return true;
        },
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 150,
                      child: Container(
                        color: Theme.of(context).primaryColor,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              SizedBox(height: 10),
                              textField(),
                              SizedBox(height: 20),
                              Row(
                                children: [
                                  pasteButton(),
                                  SizedBox(width: 16),
                                  downloadButton(context),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: expandedFeatureTile(),
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
            (_showLogin) ? showLoginContainer() : Container(),
            FutureBuilder<bool>(
              future: checkConnectivity(context),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  bool? con = snapshot.data;
                  if (con! && !_showLogin) {
                    return ad;
                  }
                }
                return Container();
              },
            ),
          ],
        ),
      ),
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
                                    fadeInDuration: Duration(milliseconds: 50),
                                    fadeOutDuration: Duration(milliseconds: 50),
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
                              fadeInDuration: Duration(milliseconds: 50),
                              fadeOutDuration: Duration(milliseconds: 50),
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

  Expanded pasteButton() {
    return Expanded(
      child: ElevatedButton(
        onPressed: () async {
          clearEverything();
          hideKeyboard(context);
          try {
            FlutterClipboard.paste().then((value) {
              if (value != '') {
                if (checkLink(value)) {
                  _linkText.text = value;
                  showSnackbar(context, 'Link pasted');
                } else {
                  _linkText.text = '';
                  showSnackbar(context, 'Choose Instagram url...');
                }
              } else {
                _linkText.text = '';
                showSnackbar(context, 'Nothing to paste');
              }
              return;
            });
          } catch (e) {
            _linkText.text = '';
            showSnackbar(context, 'Nothing to paste');
          }
        },
        child: Text(
          'Paste',
          style: TextStyle(
            color: Theme.of(context).accentColor,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          primary: Theme.of(context).buttonColor,
          minimumSize: Size(200, 45),
        ),
      ),
    );
  }

  Expanded downloadButton(context) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () async {
          downloadFunc();
        },
        child: Text(
          'Download',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          primary: color,
          minimumSize: Size(200, 45),
        ),
      ),
    );
  }

  downloadFunc() async {
    hideKeyboard(context);
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    try {
      clearEverything();
      if (await checkConnectivity(context)) {
        String link = _linkText.text;
        if (checkLink(link)) {
          if (checkStory(link))
            getStory(link);
          else
            getPost(link);
        } else {
          showSnackbar(context, 'Invalid url...');
          return;
        }
      } else {
        return;
      }
    } catch (e) {
      return;
    }
  }

  getPost(String link) async {
    if (await requestPermission()) {
      setState(() {
        _isFetching = true;
      });
      link = getCorrectLink(link);
      _instaProfile = await InstaData.postFromUrl('$link');
      if (_instaProfile!.isPrivate) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        if (await checkLoggedIn(prefs)) {
          setState(() {
            _showLogin = true;
            _isFetching = false;
          });
          return;
        } else {
          link = getCorrectLink(link);
          _instaProfile = await InstaData.postFromPrivateUrl(
            '$link',
            prefs.getString('Cookie') ?? '',
          );
          if (_instaProfile!.id != '') {
            downloadPost(_instaProfile!);
          } else {
            showSnackbar(context, 'Invalid url...');
            setState(() {
              _showLogin = false;
              _isFetching = false;
            });
          }
        }
      } else {
        downloadPost(_instaProfile!);
      }
    }
  }

  getStory(String link) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (await checkLoggedIn(prefs)) {
      setState(() {
        _showLogin = true;
        _isFetching = false;
      });
      return;
    }
    if (await requestPermission()) {
      setState(() {
        _isFetching = true;
      });
      link = getCorrectLink(link);
      List<InstaStory?> _storyList = await InstaData.userStoryData(
        '$link',
        prefs.getString('Cookie') ?? '',
      );
      if (_storyList[0]!.downloadUrl != '') {
        downloadStory(_storyList[0]);
      } else {
        showSnackbar(context, 'Invalid url...');
        if (_isFetching) {
          setState(() {
            _isFetching = false;
            _showLogin = false;
          });
        }
        return;
      }
    }
  }

  downloadStory(InstaStory? _instaStory) async {
    media = <MediaInfo>[];
    Map<String, String> _postData = Map<String, String>();
    _postData['download'] = _instaStory!.downloadUrl;
    _postData['thumbnail'] = _instaStory.storyThumbnail;
    _postData['username'] = _instaStory.username;
    _postData['profile'] = _instaStory.profilePic;

    MediaInfo mediaInfo = MediaInfo.fromMap(_postData);
    media.add(mediaInfo);

    if (await checkPermissions()) {
      tag = getRandomString(5);
      setState(() {
        _isFetching = false;
        _showLogin = false;

        _showProgress = true;
      });
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

  downloadPost(InstaProfile _instaProfile) async {
    _instaPost = _instaProfile.postData;
    media = <MediaInfo>[];
    if ((_instaPost!.childPostsCount > 1)) {
      for (var i = 0; i < _instaPost!.childPostsCount; i++) {
        Map<String, String> _postData = Map<String, String>();
        if (_instaPost!.childposts[i].videoUrl.length > 4)
          _postData['download'] = _instaPost!.childposts[i].videoUrl;
        else
          _postData['download'] = _instaPost!.childposts[i].photoLargeUrl;
        _postData['thumbnail'] = _instaPost!.photoSmallUrl;
        _postData['username'] = _instaProfile.username;
        _postData['profile'] = _instaProfile.profilePicUrl;
        MediaInfo mediaInfo = MediaInfo.fromMap(_postData);
        media.add(mediaInfo);
      }
    } else {
      Map<String, String> _postData = Map<String, String>();
      if (_instaPost!.videoUrl.length > 4)
        _postData['download'] = _instaPost!.videoUrl;
      else
        _postData['download'] = _instaPost!.photoLargeUrl;
      _postData['thumbnail'] = _instaPost!.photoSmallUrl;
      _postData['username'] = _instaProfile.username;
      _postData['profile'] = _instaProfile.profilePicUrl;
      MediaInfo mediaInfo = MediaInfo.fromMap(_postData);
      media.add(mediaInfo);
    }
    if (await checkPermissions()) {
      tag = getRandomString(5);
      setState(() {
        _isFetching = false;
        _showLogin = false;
        _showProgress = true;
      });
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

  String getCorrectLink(String link) {
    if (link.contains('?')) {
      link = link.split('?')[0];
    }
    if (!link.contains('/?__a=1')) {
      link = link + '/?__a=1';
    }
    if (link.contains('//?__a=1')) {
      link = link.replaceAll('//?__a=1', '/?__a=1');
    }
    return link;
  }

  Future<bool> checkLoggedIn(prefs) async {
    if ((prefs.getBool('isLogged') ?? false)) {
      return false;
    }
    return true;
  }

  clearEverything() {
    setState(() {
      _showProgress = false;
      _showLogin = false;
      _isFetching = false;
      filename = '';
      tag = '';
      progress = 0;
    });
  }

  TextField textField() {
    return TextField(
      controller: _linkText,
      cursorColor: Color(0xFFfa6b60),
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.deny(RegExp("[ ]")),
      ],
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(12, 6, 12, 6),
        hintText: 'Paste the URL here...',
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFfa6b60), width: 2),
          borderRadius: new BorderRadius.circular(5),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 2),
          borderRadius: new BorderRadius.circular(5),
        ),
      ),
    );
  }

  expandedFeatureTile() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: ExpansionTile(
        backgroundColor: Theme.of(context).primaryColor,
        iconColor: Theme.of(context).accentColor,
        collapsedIconColor: Theme.of(context).accentColor,
        collapsedBackgroundColor: Theme.of(context).primaryColor,
        leading: SvgPicture.asset(
          "assets/svg/confetti.svg",
          width: IconTheme.of(context).size,
        ),
        title: Text(
          'More',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).accentColor,
          ),
        ),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    expandedTile(0),
                    expandedTile(1),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    expandedTile(3),
                    expandedTile(2),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  expandedTile(int index) {
    String svg = getSVG(index);
    String text = getTEXT(index);
    return Container(
      height: 60,
      child: Material(
        child: InkWell(
          splashColor: Colors.transparent,
          onTap: () {
            getAction(index);
          },
          child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: 15),
                SvgPicture.asset(
                  "assets/svg/$svg.svg",
                  width: IconTheme.of(context).size! - 5,
                  color: Theme.of(context).accentColor,
                ),
                SizedBox(width: 20),
                AutoSizeText(
                  '$text',
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
      color: Theme.of(context).primaryColor,
    );
  }

  getSVG(int i) {
    List<String> map = ['user', 'story', 'hashtag', 'grid'];
    return map[i];
  }

  getTEXT(int i) {
    List<String> map = [
      'DP Downloader',
      'Story Downloader',
      'Hashtag Generator',
      'Post Downloader',
    ];
    return map[i];
  }

  getAction(int index) {
    if (index == 0)
      Navigator.pushReplacementNamed(context, '/userdp');
    else if (index == 1)
      Navigator.pushReplacementNamed(context, '/userstory');
    else if (index == 2)
      Navigator.pushReplacementNamed(context, '/hashtag');
    else
      Navigator.pushReplacementNamed(context, '/post', arguments: '');
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
        height: 250,
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
                        setState(() {});
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
        height: 250,
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
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      if (prefs.getBool('isLogged') ?? false) {
                        setState(() {
                          _isFetching = true;
                          _showLogin = false;
                        });
                        if (_linkText.text.contains('/stories/')) {
                          getStory(_linkText.text);
                        } else {
                          getPost(_linkText.text);
                        }
                      } else {
                        if (_isFetching) {
                          setState(() {
                            _isFetching = false;
                            _showLogin = false;
                          });
                        }
                      }
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

class MediaInfo {
  final String download;
  final String thumbnail;
  final String username;
  final String profile;
  final String url;
  String taskId;
  String savedDir;
  String filename;
  String tag;
  int progress;
  int index;
  DownloadTaskStatus status = DownloadTaskStatus.undefined;

  MediaInfo({
    required this.download,
    required this.thumbnail,
    required this.username,
    required this.profile,
    required this.url,
    required this.taskId,
    required this.savedDir,
    required this.filename,
    required this.tag,
    required this.index,
    required this.progress,
    required this.status,
  });

  factory MediaInfo.fromMap(Map<String, String> map) {
    return MediaInfo(
      download: map['download'] ?? '',
      thumbnail: map['thumbnail'] ?? '',
      username: map['username'] ?? '',
      profile: map['profile'] ?? '',
      progress: 0,
      url: '',
      filename: '',
      index: 0,
      savedDir: '',
      status: DownloadTaskStatus.undefined,
      tag: '',
      taskId: '',
    );
  }
}

// 9914714767
