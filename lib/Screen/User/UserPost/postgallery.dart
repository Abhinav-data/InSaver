import 'dart:isolate';
import 'dart:ui';
import 'package:appodeal_flutter/appodeal_flutter.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:insaver/Screen/Media/media.dart';
import 'package:insaver/Screen/Media/mediaData.dart';
import 'package:insaver/Utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostGallery extends StatefulWidget {
  final String code;
  PostGallery(this.code);
  @override
  _PostGalleryState createState() => _PostGalleryState();
}

class _PostGalleryState extends State<PostGallery> {
  InstaProfile? _instaProfile;
  ReceivePort _port = ReceivePort();
  List<MediaInfo> media = <MediaInfo>[];

  int progress = 0;
  String tag = '';
  String filename = '';
  bool adLoaded = false;
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
    print('dispose');
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
      if (media.length != 0) {
        for (var i = 0; i < media.length; i++) {
          if (media[i].taskId != '' && media[i].taskId == id) {
            print(pr.toString() + '____________________________________');
            if (status.value == 3) {
              print('Completed && Saving.......................');
              String time = DateTime.now().toString();
              await saveToDB(
                'https://www.instagram.com/tv/${widget.code}',
                media[i].filename,
                media[i].tag,
                media[i].profile,
                media[i].username,
                media[i].savedDir,
                time,
              );
              showSnackbar(context, 'Media Downloaded...');
              SharedPreferences prefs = await SharedPreferences.getInstance();
            }
          }
        }
      }
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    String link = 'https://www.instagram.com/tv/${widget.code}/?__a=1';

    return WillPopScope(
      onWillPop: () async {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();

        return true;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          title: Text(
            "Gallery",
            style: TextStyle(
              color: Theme.of(context).accentColor,
              fontSize: 22,
            ),
          ),
          leading: IconButton(
            onPressed: () async {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.arrow_back_ios),
          ),
          actions: [],
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
          iconTheme: Theme.of(context).iconTheme,
        ),
        body: SafeArea(
          child: Column(
            children: [
              FAProgressBar(
                progressColor: Color(0xFFf85343),
                maxValue: 100,
                currentValue: progress,
                size: 8,
              ),
              SizedBox(
                width: size.width,
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: ad,
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: FutureBuilder<InstaProfile>(
                    future: InstaData.postFromPostGallery(link),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        _instaProfile = snapshot.data;
                        List<MediaInfo> list = galleryData(_instaProfile!);
                        return Swiper(
                          itemCount: list.length,
                          containerWidth: size.width,
                          loop: false,
                          pagination: SwiperPagination(
                              margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                              builder: SwiperCustomPagination(builder:
                                  (BuildContext context,
                                      SwiperPluginConfig config) {
                                return ConstrainedBox(
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        "${config.activeIndex + 1}/${config.itemCount}",
                                        style: TextStyle(
                                          fontSize: 25.0,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).accentColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  constraints:
                                      new BoxConstraints.expand(height: 50.0),
                                );
                              })),
                          control: new SwiperControl(
                            color: Theme.of(context).accentColor,
                            disableColor:
                                Theme.of(context).accentColor.withOpacity(0.5),
                          ),
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                if (list[index].download.contains('mp4')) {
                                  Navigator.pushNamed(
                                    context,
                                    '/videoPlayer',
                                    arguments: [true, list[index].download],
                                  );
                                }
                              },
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      child: InteractiveViewer(
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.network(
                                            list[index].thumbnail,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  (list[index].download.contains('mp4'))
                                      ? Positioned.fill(
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Container(
                                              width: 100,
                                              height: 100,
                                              decoration: BoxDecoration(
                                                color: Colors.black54,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.play_arrow,
                                                color: Colors.white,
                                                size: 65,
                                              ),
                                            ),
                                          ),
                                        )
                                      : Container(),
                                ],
                              ),
                            );
                          },
                        );
                      }
                      return Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).canvasColor,
                        ),
                      );
                    },
                  ),
                ),
              ),
              FutureBuilder<bool>(
                future: checkConnectivity(context),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    bool? con = snapshot.data;
                    if (con!)
                      return SizedBox(
                        height: 80,
                        child: Container(
                          color: Theme.of(context).primaryColor,
                          child: download(),
                        ),
                      );
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

  download() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 20),
      child: ElevatedButton(
        onPressed: () async {
          if (media.length != 0) {
            if (await checkPermissions()) {
              tag = getRandomString(5);
              showInterstitialAd();
              for (var i = 0; i < media.length; i++) {
                bool isVideo = media[i].download.contains('mp4');
                filename = getFileName(tag, i, isVideo);
                final savePath = path.join(instaDir.path, filename);
                media[i].filename = filename;
                media[i].tag = tag;
                media[i].index = i;
                media[i].savedDir = savePath;
                media[i].taskId = (await FlutterDownloader.enqueue(
                  url: media[i].download,
                  fileName: filename,
                  savedDir: instaDir.path,
                  showNotification: (i == 0),
                  openFileFromNotification: (i == 0),
                ))!;
              }
            }
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
          primary: color,
          minimumSize: Size(2000, 45),
        ),
      ),
    );
  }

  List<MediaInfo> galleryData(InstaProfile profile) {
    media = <MediaInfo>[];
    if (profile.postData.childPostsCount == 1) {
      bool isVid = profile.postData.videoUrl.contains('mp4');
      Map<String, String> _postData = Map<String, String>();
      _postData['download'] =
          (isVid) ? profile.postData.videoUrl : profile.postData.photoLargeUrl;
      _postData['thumbnail'] = profile.postData.photoLargeUrl;
      _postData['username'] = _instaProfile!.username;
      _postData['profile'] = _instaProfile!.profilePicUrl;
      MediaInfo mediaInfo = MediaInfo.fromMap(_postData);
      media.add(mediaInfo);
    } else {
      for (var i = 0; i < profile.postData.childPostsCount; i++) {
        bool isVid = profile.postData.childposts[i].videoUrl.contains('mp4');
        Map<String, String> _postData = Map<String, String>();
        _postData['thumbnail'] = profile.postData.childposts[i].photoLargeUrl;
        _postData['download'] = (isVid)
            ? profile.postData.childposts[i].videoUrl
            : profile.postData.childposts[i].photoLargeUrl;
        _postData['username'] = _instaProfile!.username;
        _postData['profile'] = _instaProfile!.profilePicUrl;
        MediaInfo mediaInfo = MediaInfo.fromMap(_postData);
        media.add(mediaInfo);
      }
    }
    return media;
  }
}

// BC62D2674080
