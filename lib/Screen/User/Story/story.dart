import 'dart:isolate';
import 'package:appodeal_flutter/appodeal_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:path/path.dart' as path;
import 'dart:ui';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:insaver/Screen/Home/home.dart';
import 'package:insaver/Screen/Media/media.dart';
import 'package:insaver/Screen/Media/mediaData.dart';
import 'package:insaver/Utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class UserStory extends StatefulWidget {
  @override
  _UserStoryState createState() => _UserStoryState();
}

class _UserStoryState extends State<UserStory> {
  TextEditingController _userText = TextEditingController();
  int denyCnt = 0;
  int progress = 0;
  String currentId = '';
  String oldId = '';
  String tag = '';
  InstaProfile? _instaProfile;
  InstaStory? _instaStory;
  String filename = '';
  TextEditingController _linkText = TextEditingController();
  List<ReelsStory> reels = [];
  List<MediaInfo> media = <MediaInfo>[];
  ReceivePort _port = ReceivePort();
  bool _showLogin = false, _isFetch = false;
  bool adLoaded = false;
  Widget ad = Container();

  @override
  void initState() {
    super.initState();
    _bindBackgroundIsolate();
    FlutterDownloader.registerCallback(downloadCallBack);
    _linkText.text = '';
    getReelsTray();
    ad = AppodealBanner();

  }

  showInterstitialAd() async {
    if (await Appodeal.canShow(AdType.INTERSTITIAL) &&
        await Appodeal.isReadyForShow(AdType.INTERSTITIAL))
      await Appodeal.show(AdType.INTERSTITIAL);
  }

  static void downloadCallBack(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_story_send_port');
    send!.send([id, status, progress]);
  }

  void _bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_story_send_port');
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

        if (task.status.value == 3 || status.value == 3) {
          print('Completed.......................');
          bool isVideo = task.filename.contains('mp4');
          showSnackbar(
              context, (isVideo) ? 'Video downloaded...' : 'Image downloaded');
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
    IsolateNameServer.removePortNameMapping('downloader_story_send_port');
  }

  @override
  void dispose() {
    print('dispose');
    _unbindBackgroundIsolate();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        showInterstitialAd();
        Navigator.of(context).pushReplacementNamed('/home');
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Story Saver",
            style: TextStyle(
              color: Theme.of(context).accentColor,
              fontSize: 28,
              fontFamily: 'Satisfy',
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            splashColor: Colors.transparent,
            onPressed: () async {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              showInterstitialAd();

              Navigator.of(context).pushReplacementNamed('/home');
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
                                      hintText: 'Paste username...',
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
                                  SizedBox(height: 15),
                                  Row(
                                    children: [
                                      downloadStory(),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        FutureBuilder<dynamic>(
                          future: Future.wait([
                            SharedPreferences.getInstance(),
                            checkConnectivity(context),
                          ]),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              SharedPreferences p = snapshot.data[0];
                              bool con = snapshot.data[1];
                              if ((p.getBool('isLogged') ?? false) && con) {
                                return SizedBox(
                                  height: 100,
                                  child: getStoriesUser(),
                                );
                              }
                            }
                            return Container();
                          },
                        ),
                        FutureBuilder<dynamic>(
                          future: Future.wait([
                            SharedPreferences.getInstance(),
                            checkConnectivity(context),
                          ]),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              SharedPreferences p = snapshot.data[0];
                              bool con = snapshot.data[1];
                              if ((p.getBool('isLogged') ?? false) && con) {
                                return getStories();
                              }
                            }
                            return Container();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              FutureBuilder<dynamic>(
                future: Future.wait([
                  SharedPreferences.getInstance(),
                  checkConnectivity(context),
                ]),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    SharedPreferences p = snapshot.data[0];
                    bool con = snapshot.data[1];
                    if (con && !(p.getBool('isLogged') ?? false)) {
                      return showLoginContainer();
                    }
                  }
                  return Container();
                },
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
            ],
          ),
        ),
      ),
    );
  }

  getStoriesUser() {
    if (reels == [] || reels == null || reels.length == 0) {
      return Container(
        color: Theme.of(context).primaryColor,
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowGlow();
            return true;
          },
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 10,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.fromLTRB(15, 8, 15, 8),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[400]!,
                  highlightColor: Colors.grey[50]!,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    } else {
      return Container(
        color: Theme.of(context).primaryColor,
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowGlow();
            return true;
          },
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: reels.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.fromLTRB(15, 8, 15, 8),
                child: GestureDetector(
                  onTap: () {
                    hideKeyboard(context);
                    if (currentId != reels[index].id) {
                      if (this.mounted) {
                        setState(() {
                          currentId = reels[index].id;
                          _isFetch = true;
                        });
                      }
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        child: CachedNetworkImage(
                          imageUrl: reels[index].profilePic,
                          imageBuilder: (context, imageProvider) {
                            return Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.red, width: 3),
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
                      // SizedBox(
                      //   width: 60,
                      //   height: 60,
                      //   child: Container(
                      //     decoration: BoxDecoration(
                      //       border: Border.all(color: Colors.red, width: 3),
                      //       image: DecorationImage(
                      //         image: NetworkImage(reels[index].profilePic),
                      //         fit: BoxFit.cover,
                      //       ),
                      //       shape: BoxShape.circle,
                      //     ),
                      //   ),
                      // ),
                      SizedBox(height: 5),
                      SizedBox(
                        width: 75,
                        child: Container(
                          child: Center(
                            child: Text(
                              reels[index].username,
                              style: TextStyle(
                                fontSize: 10,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
    }
  }

  getStories() {
    return FutureBuilder<List<MediaInfo>>(
      future: getCurrentUserStory(),
      builder: (context, snapshot) {
        if (snapshot.hasData &&
            snapshot.data!.length != 0 &&
            snapshot.data![0].download != '') {
          List<MediaInfo>? _media = snapshot.data;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
                child: ListTile(
                  leading: Container(
                    width: 60,
                    height: 60,
                    child: CachedNetworkImage(
                      imageUrl: _media![0].profile,
                      imageBuilder: (context, imageProvider) {
                        return Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.red, width: 3),
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
                  // leading: SizedBox(
                  //   width: 60,
                  //   height: 60,
                  //   child: Container(
                  //     decoration: BoxDecoration(
                  //       border: Border.all(color: Colors.red, width: 3),
                  //       image: DecorationImage(
                  //         image: NetworkImage(_media![0].profile),
                  //         fit: BoxFit.cover,
                  //       ),
                  //       shape: BoxShape.circle,
                  //     ),
                  //   ),
                  // ),
                  title: Text(_media[0].username),
                  trailing: (_isFetch)
                      ? CircularProgressIndicator(
                          color: Theme.of(context).canvasColor,
                        )
                      : IconButton(
                          splashColor: Colors.transparent,
                          onPressed: () async {
                            launchInInsta(
                              'https://www.instagram.com/${_media[0].username}',
                              context,
                            );
                          },
                          tooltip: 'Open profile in Instagram',
                          icon: SvgPicture.asset(
                            "assets/svg/instagram.svg",
                            width: IconTheme.of(context).size,
                            color: Theme.of(context).accentColor,
                          ),
                        ),
                ),
              ),
              Divider(thickness: 2),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: (_isFetch) ? 0 : _media.length,
                  gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.6,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            FocusScopeNode currentFocus =
                                FocusScope.of(context);
                            if (!currentFocus.hasPrimaryFocus) {
                              currentFocus.unfocus();
                            }

                            List<MediaInfo> args = [_media[index]];
                            if (_media[index].download.contains('mp4')) {
                              Navigator.pushNamed(
                                context,
                                '/videoscreen',
                                arguments: args,
                              ).then((value) {
                                if (this.mounted) {
                                  setState(() {});
                                }
                              });
                            } else {
                              Navigator.pushNamed(
                                context,
                                '/imagescreen',
                                arguments: args,
                              ).then((value) {
                                if (this.mounted) {
                                  setState(() {});
                                }
                              });
                            }
                          },
                          child: Container(
                            child: CachedNetworkImage(
                              imageUrl: _media[index].thumbnail,
                              imageBuilder: (context, imageProvider) {
                                return Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color: Theme.of(context).primaryColor,
                                      width: 8,
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
                          // child: Container(
                          //   decoration: BoxDecoration(
                          //     border: Border.all(
                          //       color: Theme.of(context).primaryColor,
                          //       width: 8,
                          //     ),
                          //     image: DecorationImage(
                          //       image: NetworkImage(_media[index].thumbnail),
                          //       fit: BoxFit.cover,
                          //     ),
                          //     borderRadius: BorderRadius.circular(5),
                          //   ),
                          // ),
                        ),
                        (_media[index].download.contains('mp4'))
                            ? Align(
                                alignment: Alignment.center,
                                child: GestureDetector(
                                  onTap: () {
                                    FocusScopeNode currentFocus =
                                        FocusScope.of(context);
                                    if (!currentFocus.hasPrimaryFocus) {
                                      currentFocus.unfocus();
                                    }
                                    List<MediaInfo> args = [_media[index]];

                                    if (_media[index]
                                        .download
                                        .contains('mp4')) {
                                      Navigator.pushNamed(
                                        context,
                                        '/videoscreen',
                                        arguments: args,
                                      ).then((value) {
                                        if (this.mounted) {
                                          setState(() {});
                                        }
                                      });
                                    } else {
                                      Navigator.pushNamed(
                                        context,
                                        '/imagescreen',
                                        arguments: args,
                                      ).then((value) {
                                        if (this.mounted) {
                                          setState(() {});
                                        }
                                      });
                                    }
                                  },
                                  child: SizedBox(
                                    width: 60,
                                    height: 60,
                                    child: Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: Colors.black87,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.play_arrow,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(5),
                            ),
                            child: Material(
                              color: Theme.of(context).primaryColor,
                              child: IconButton(
                                splashColor: Colors.transparent,
                                icon: Icon(
                                  Icons.download_sharp,
                                  size: IconTheme.of(context).size,
                                ),
                                onPressed: () {
                                  _downloadMedia([media[index]]);
                                },
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: FAProgressBar(
                            progressColor: Color(0xFFf85343),
                            maxValue: 100,
                            currentValue: media[index].progress,
                            size: 5,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              SizedBox(height: 10),
              ad,
              SizedBox(height: 100),
            ],
          );
        }
        if (snapshot.hasData &&
            snapshot.data!.length != 0 &&
            snapshot.data![0].download == '') {
          List<MediaInfo>? _media = snapshot.data;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
                child: ListTile(
                  leading: Container(
                    width: 60,
                    height: 60,
                    child: CachedNetworkImage(
                      imageUrl: _media![0].profile,
                      imageBuilder: (context, imageProvider) {
                        return Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red, width: 3),
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
                      fadeOutDuration: Duration(milliseconds: 100),
                    ),
                  ),
                  // leading: SizedBox(
                  //   width: 60,
                  //   height: 60,
                  //   child: Container(
                  //     decoration: BoxDecoration(
                  //       border: Border.all(color: Colors.red, width: 3),
                  //       image: DecorationImage(
                  //         image: NetworkImage(_media![0].profile),
                  //         fit: BoxFit.cover,
                  //       ),
                  //       shape: BoxShape.circle,
                  //     ),
                  //   ),
                  // ),
                  title: Text(_media[0].username),
                  trailing: IconButton(
                    splashColor: Colors.transparent,
                    onPressed: () async {
                      launchInInsta(
                        'https://www.instagram.com/${_media[0].username}',
                        context,
                      );
                    },
                    tooltip: 'Open profile in Instagram',
                    icon: SvgPicture.asset(
                      "assets/svg/instagram.svg",
                      width: IconTheme.of(context).size,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                ),
              ),
              Divider(thickness: 2),
            ],
          );
        }
        return Padding(
          padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
          child: SizedBox(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Theme.of(context).primaryColor,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('Fetching stories...'),
                  trailing: CircularProgressIndicator(
                    color: Theme.of(context).canvasColor,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  _downloadMedia(List<MediaInfo> media) async {
    if (await checkPermissions()) {
      tag = getRandomString(5);
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

  Future<List<MediaInfo>> getCurrentUserStory() async {
    if (currentId == '' || reels.length == 0) {
      return [];
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<InstaStory>? _stories = [];
      if (currentId != oldId) {
        _stories = await InstaData.userStoryReelsData(
          currentId,
          prefs.getString('Cookie') ?? '',
        );
      }

      if (currentId != oldId) {
        setState(() {
          oldId = currentId;
          _isFetch = false;
        });
        media = <MediaInfo>[];

        for (var i = 0; i < _stories.length; i++) {
          Map<String, String> _postData = Map<String, String>();
          _postData['download'] = _stories[i].downloadUrl;
          _postData['thumbnail'] = _stories[i].storyThumbnail;
          _postData['username'] = _stories[i].username;
          _postData['profile'] = _stories[i].profilePic;
          MediaInfo mediaInfo = MediaInfo.fromMap(_postData);
          media.add(mediaInfo);
        }
        if (media.length == 0) {
          Map<String, String> _postData = Map<String, String>();
          _postData['download'] = '';
          _postData['thumbnail'] = '';
          _postData['username'] = _instaProfile!.username;
          _postData['profile'] = _instaProfile!.profilePicUrl;
          MediaInfo mediaInfo = MediaInfo.fromMap(_postData);
          media.add(mediaInfo);
        }

        return media;
      } else {
        return media;
      }
    }
  }

  getReelsTray() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool conn = await checkConnectivity(context);
    if ((prefs.getBool('isLogged') ?? false) && conn) {
      reels = await InstaData.userReelsData(prefs.getString('Cookie') ?? '');
      await Future.delayed(Duration(seconds: 2));
      if (this.mounted) {
        setState(() {
          currentId = reels[0].id;
        });
      }
    }
  }

  downloadStory() {
    return Expanded(
      child: ElevatedButton(
        onPressed: () async {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
          String link = _userText.text;
          if (link.trim() == '') {
            showSnackbar(context, 'Enter username...');
            return;
          }
          if (await requestPermission()) {
            String user = _userText.text;
            _instaProfile = await InstaData.userIdData(user);
            if (_instaProfile!.id != '') {
              if (this.mounted) {
                setState(() {
                  currentId = _instaProfile!.id;
                  _isFetch = true;
                });
              }
            } else {
              showSnackbar(context, 'Invalid username...');
            }
          }
        },
        child: Text(
          'Get Stories',
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
                          getReelsTray();
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
                      getReelsTray();
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

  clearEverything() {
    if (this.mounted) {
      setState(() {
        filename = '';
        tag = '';
        progress = 0;
      });
    }
  }
}
