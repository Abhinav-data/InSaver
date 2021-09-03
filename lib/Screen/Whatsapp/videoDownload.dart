import 'dart:io';
import 'dart:math';
import 'package:appodeal_flutter/appodeal_flutter.dart';
import 'package:insaver/Utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class VidDownload extends StatefulWidget {
  final List args;
  VidDownload(this.args);
  @override
  _VidDownloadState createState() => _VidDownloadState();
}

class _VidDownloadState extends State<VidDownload> {
  Widget ad = Container();

  String _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();
  Directory dir = Directory('/storage/emulated/0/Download/WAStatusSaver');
  late VideoPlayerController _videoPlayerController;
  String tmpThumbnail = '';
  bool isFile = false;
  bool inDownloads = false;
  int progress = 0;
  late PermissionStatus status;

  @override
  void initState() {
    super.initState();
    if (!statusDir.existsSync()) {
      statusDir.createSync(recursive: true);
    }
    _videoPlayerController = VideoPlayerController.file(
      File(widget.args[0]),
    )..initialize().then(
        (_) {
          setState(() {});
          _videoPlayerController.play();
          _videoPlayerController.setLooping(true);
        },
      );
    initializeBanner();
  }

  initializeBanner() {
    ad = AppodealBanner();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  showInterstitialAd() async {
    if (await Appodeal.canShow(AdType.INTERSTITIAL) &&
        await Appodeal.isReadyForShow(AdType.INTERSTITIAL))
      await Appodeal.show(AdType.INTERSTITIAL);
  }

  @override
  Widget build(BuildContext context) {
    inDownloads = widget.args[1];
    var size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).accentColor,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();

              Navigator.of(context).pop();
            },
          ),
          title: Text('Gallery'),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Container(
                  child: ad,
                ),
                SizedBox(height: 5),
                Expanded(
                  child: Center(
                    child: _videoPlayerController.value.isInitialized
                        ? Stack(
                            children: [
                              AspectRatio(
                                aspectRatio:
                                    _videoPlayerController.value.aspectRatio,
                                child: VideoPlayer(_videoPlayerController),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 100,
                                child: SizedBox(
                                  height: 250,
                                  width: 90,
                                  child: Container(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        (!inDownloads)
                                            ? GestureDetector(
                                                onTap: () {
                                                  _downloadFile(widget.args[0]);
                                                  showSnackbar(
                                                    context,
                                                    'Video Saved',
                                                  );
                                                  showInterstitialAd();
                                                },
                                                child: Column(
                                                  children: [
                                                    Icon(
                                                      Icons.download_rounded,
                                                      size: 50,
                                                    ),
                                                    Text(
                                                      'Download',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ))
                                            : Container(),
                                        GestureDetector(
                                          onTap: () async {
                                            Share.shareFiles([widget.args[0]]);
                                          },
                                          child: Column(
                                            children: [
                                              Icon(
                                                Icons.share_rounded,
                                                size: 40,
                                              ),
                                              Text(
                                                'Share',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : CircularProgressIndicator(
                            color: Theme.of(context).canvasColor,
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadFile(String filePath) async {
    File originalVideoFile = File(filePath);
    String tag = getRandomString(5);

    String filename =
        'WA-${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}${DateTime.now().hour}${DateTime.now().minute}${DateTime.now().second}${DateTime.now().millisecond}$tag.mp4';
    String path = dir.path;
    String newFileName = "$path/$filename";

    if (await createDir()) {
      await originalVideoFile.copy(newFileName);
    }
  }
}
