import 'dart:io';
import 'package:appodeal_flutter/appodeal_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:insaver/Screen/Download/downloadData.dart';
import 'package:insaver/Utils/constants.dart';
import 'package:insaver/Utils/db.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class Gallery extends StatefulWidget {
  final String tag;
  Gallery(this.tag);
  @override
  _GalleryState createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  String filePath = '';
  Directory? directory;
  Widget ad = Container();

  DownloadData _downloadData = DownloadData();
  int current = 1;
  int total = 1;
  bool adLoaded = false;

  @override
  void initState() {
    super.initState();
    initializeBanner();
  }

  initializeBanner() {
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
        showInterstitialAd();
        return true;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          leading: IconButton(
            splashColor: Colors.transparent,
            onPressed: () async {
              showInterstitialAd();
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: Theme.of(context).accentColor,
            ),
          ),
          title: Text('Gallery'),
          actions: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: dbHelper.countByTag(widget.tag),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      total = snapshot.data!.length;
                      return Text(
                        '$current/$total',
                        style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }
                    return Container();
                  },
                ),
                SizedBox(width: 15),
              ],
            ),
          ],
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Container(
                child: ad,
              ),
              Expanded(
                child: FutureBuilder(
                  future: dbHelper.queryByTag(widget.tag),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var x = snapshot.data;

                      List<Map<String, dynamic>> y =
                          _downloadData.galleryData(x);

                      return Column(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Swiper(
                                containerWidth: size.width,
                                loop: false,
                                itemCount: y.length,
                                itemBuilder: (context, index) {
                                  if (!y[index]['isVideo']) {
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        child: InteractiveViewer(
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Image.file(
                                              File(
                                                y[index]['directory'],
                                              ),
                                              errorBuilder: (_, __, ___) {
                                                return Container();
                                              },
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  } else {
                                    return FutureBuilder<String>(
                                      future: getThumbnailFile(
                                          y[index]['directory']),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          return GestureDetector(
                                            onTap: () {
                                              Navigator.pushNamed(
                                                context,
                                                '/videoPlayer',
                                                arguments: [
                                                  false,
                                                  y[index]['directory']
                                                ],
                                              );
                                            },
                                            child: Stack(
                                              children: [
                                                Positioned.fill(
                                                  child: Align(
                                                    alignment: Alignment.center,
                                                    child: Container(
                                                      width: size.width,
                                                      color: Colors.red,
                                                      child: Image.file(
                                                        File(
                                                          snapshot.data!,
                                                        ),
                                                        errorBuilder:
                                                            (_, __, ___) {
                                                          return Container();
                                                        },
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned.fill(
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
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                        return Container();
                                      },
                                    );
                                  }
                                },
                                onIndexChanged: (int i) {
                                  if (this.mounted) {
                                    setState(() {
                                      current = i + 1;
                                      total = y.length;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String> getThumbnailFile(String videoFile) async {
    directory = await getExternalStorageDirectory();
    final thumbnail = await VideoThumbnail.thumbnailFile(
      video: videoFile,
      thumbnailPath: directory!.path,
      imageFormat: ImageFormat.JPEG,
      quality: 20,
    );
    final file = File(thumbnail!);
    filePath = file.path;
    return filePath;
  }
}

class GalleryIcons extends StatelessWidget {
  const GalleryIcons({
    Key? key,
    required this.size,
    required this.y,
  }) : super(key: key);

  final Size size;
  final y;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Padding(
            padding: const EdgeInsets.all(3),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Container(
                child: Material(
                  child: InkWell(
                    splashColor: Colors.transparent,
                    onTap: () {
                      _launchInInsta(y[0]['postUrl'], context);
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            "assets/svg/insta.svg",
                            width: IconTheme.of(context).size! - 2.5,
                            color: Theme.of(context).accentColor,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Insta View',
                            style: TextStyle(
                              fontSize: 13,
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
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(3),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Container(
                child: Material(
                  child: InkWell(
                    splashColor: Colors.transparent,
                    onTap: () {
                      Clipboard.setData(
                              new ClipboardData(text: y[0]['postUrl']))
                          .then((value) {
                        showSnackbar(context, 'Link Copied...', 3);
                      });
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            "assets/svg/copy.svg",
                            width: IconTheme.of(context).size! - 2.5,
                            color: Theme.of(context).accentColor,
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Copy Link',
                            style: TextStyle(
                              fontSize: 13,
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
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(3),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Container(
                child: Material(
                  child: InkWell(
                    splashColor: Colors.transparent,
                    onTap: () {
                      _sharePost(y[0]['postUrl']);
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            "assets/svg/share.svg",
                            width: IconTheme.of(context).size! - 2.5,
                            color: Theme.of(context).accentColor,
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Share',
                            style: TextStyle(
                              fontSize: 13,
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
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(3),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Container(
                child: Material(
                  child: InkWell(
                    splashColor: Colors.transparent,
                    onTap: () async {
                      var x = await _showDialogBox(context, y[0]['tag']);
                      if (x == 1) {
                        showSnackbar(context, 'File deleted...', 3);
                      }
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.delete_outline_outlined,
                            size: IconTheme.of(context).size! + 2,
                            color: Theme.of(context).accentColor,
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Delete',
                            style: TextStyle(
                              fontSize: 13,
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
            ),
          ),
        ],
      ),
    );
  }

  showSnackbar(context, text, time) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: time),
      ),
    );
  }

  _launchInInsta(String url, context) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      showSnackbar(context, 'Unable to open link', 3);
    }
  }

  _sharePost(String link) {
    String text =
        'Here check this instagram post $link.\n\nI downloaded this post from the app\n$url';
    Share.share(text);
  }

  _showDialogBox(context, String tag) {
    bool value = true;
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Theme.of(context).primaryColor,
            title: Text('Delete?'),
            content: Row(
              children: [
                Checkbox(
                  activeColor: Theme.of(context).accentColor,
                  checkColor: Theme.of(context).primaryColor,
                  value: value,
                  onChanged: (i) {
                    setState(() {
                      value = i!;
                    });
                  },
                ),
                Text('Delete saved file too?'),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Theme.of(context).accentColor),
                ),
                onPressed: () {
                  Navigator.of(context).pop(0);
                },
              ),
              TextButton(
                child: Text(
                  'Delete',
                  style: TextStyle(color: Theme.of(context).accentColor),
                ),
                onPressed: () async {
                  try {
                    if (value) {
                      var x = await dbHelper.queryByTag(tag);
                      for (var i = 0; i < x.length; i++) {
                        final file = File(x[i]['savedDir']);
                        await file.delete();
                      }
                    }
                    await dbHelper.deleteByTag(tag);
                  } catch (e) {
                    await dbHelper.deleteByTag(tag);
                  }
                  Navigator.of(context)..pop()..pop();
                },
              )
            ],
          );
        });
      },
    );
  }
}
