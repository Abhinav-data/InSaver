import 'dart:async';
import 'dart:io';
import 'package:appodeal_flutter/appodeal_flutter.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:insaver/Screen/Download/downloadData.dart';
import 'package:insaver/Screen/Download/gridView.dart';
import 'package:insaver/Utils/constants.dart';
import 'package:insaver/Utils/db.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class Download extends StatefulWidget {
  @override
  _DownloadState createState() => _DownloadState();
}

class _DownloadState extends State<Download> {
  DownloadData _downloadData = DownloadData();
  Widget _animatedWidget = Container();
  bool isGrid = true;
  Timer? timer;
  List<String> mediaList = <String>[];
  late Directory directory;
  String filePath = '';
  List<Map<String, dynamic>> dbData = [];
  Widget ad = Container();

  @override
  void initState() {
    super.initState();
    getDbData();
    initializeBanner();
  }

  initializeBanner() {
    ad = AppodealBanner();
  }

  getDbData() async {
    dbData = await dbHelper.query();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: 50,
          backgroundColor: Theme.of(context).primaryColor,
          iconTheme: Theme.of(context).iconTheme,
          bottom: TabBar(
            indicatorColor: color,
            onTap: (index) {},
            tabs: [
              Tab(text: 'Instagram'),
              Tab(text: 'Whatsapp'),
            ],
            labelStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowGlow();
            return true;
          },
          child: Stack(
            children: [
              TabBarView(
                children: [
                  getInsta(context),
                  getWhatsapp(context),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: ad,
              ),
            ],
          ),
        ),
      ),
    );
  }

  getInsta(context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: (dbData.length == 0)
                ? SizedBox(
                    height: 300,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Container(
                              color: Theme.of(context).primaryColor,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  'Instagram downloaded media is present in Downloads>>InSaver',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          child: Column(
                            children: [
                              Icon(
                                Icons.folder_rounded,
                                size: 50,
                              ),
                              SizedBox(height: 10),
                              Text('No saved media found...'),
                            ],
                          ),
                        ),
                        Container(),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Container(
                            color: Theme.of(context).primaryColor,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'Instagram downloaded media is present in Downloads>>InstaStory',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                      getList(context),
                      SizedBox(height: 50),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  getList(context) {
    var size = MediaQuery.of(context).size;
    DownloadData _down = DownloadData();
    List<Map<String, dynamic>> list = _down.dataFromDB(dbData);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: ListView.separated(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: list.length,
        itemBuilder: (context, index) {
          String fileDir = list[index]['directory'];
          bool fileExist = File(fileDir).existsSync();
          return ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: SizedBox(
              height: size.width,
              child: Column(
                children: [
                  SizedBox(
                    height: 60,
                    child: Container(
                      color: Theme.of(context).primaryColor,
                      child: ListTile(
                        title: Text(
                          list[index]['userName'],
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).accentColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.more_vert_rounded),
                          onPressed: () {
                            _settingModalBottomSheet(context, list, index);
                          },
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: Theme.of(context).primaryColor,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                            child: Container(
                              color: Colors.white,
                              child: GestureDetector(
                                onTap: () {
                                  if (fileExist) {
                                    Navigator.pushNamed(
                                      context,
                                      '/gallery',
                                      arguments: list[index]['tag'],
                                    );
                                  } else {
                                    showSnackbar(
                                        context, 'File does not exist...');
                                  }
                                },
                                child: ((list[index]['isVideo']))
                                    ? VideoFile(y: list, index: index)
                                    : (fileExist)
                                        ? Image.file(
                                            File(list[index]['directory']),
                                            fit: BoxFit.cover,
                                          )
                                        : Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.error,
                                                color: Colors.black,
                                                size: 30,
                                              ),
                                              SizedBox(height: 5),
                                              Text(
                                                'File not found',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ],
                                          ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 20,
                            right: 20,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black38,
                                    blurRadius: 30,
                                    spreadRadius: 10,
                                  )
                                ],
                              ),
                              child: Icon(
                                (list[index]['containPosts'])
                                    ? Icons.folder
                                    : (list[index]['isVideo'])
                                        ? Icons.play_arrow
                                        : Icons.image,
                                size: (list[index]['isVideo']) ? 30 : 30,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (context, index) {
          return SizedBox(height: 16);
        },
      ),
    );
  }

  _settingModalBottomSheet(
    context,
    List<Map<String, dynamic>> y,
    int index,
  ) {
    var size = MediaQuery.of(context).size;
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          height: 350,
          child: ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            itemCount: 5,
            itemBuilder: (context, i) {
              String text = getText(i);
              String svg = getSVG(i);
              return Container(
                child: Material(
                  child: InkWell(
                    onTap: () async {
                      if (i == 0) {
                        _launchInInsta(y[index]['postUrl'], context);
                        Navigator.pop(context);
                      } else if (i == 1) {
                        Clipboard.setData(
                                ClipboardData(text: y[index]['postUrl']))
                            .then((value) {
                          showSnackbar(context, 'Link Copied...');
                          Navigator.of(context).pop();
                        });
                      } else if (i == 2) {
                        OpenFile.open(y[index]['directory']);
                        Navigator.of(context).pop();
                      } else if (i == 3) {
                        _sharePost(y[index]['postUrl']);
                        Navigator.of(context).pop();
                      } else {
                        var x = await _showDialogBox(context, y[index]['tag']);
                        if (x == 1) {
                          showSnackbar(context, 'File deleted...');
                          getDbData();
                        }
                        Navigator.of(context).pop();
                      }
                    },
                    child: Container(
                      width: size.width,
                      height: 70,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(width: 25),
                          SvgPicture.asset(
                            "assets/svg/$svg.svg",
                            width: IconTheme.of(context).size! - 2,
                            color: Theme.of(context).accentColor,
                          ),
                          SizedBox(width: 35),
                          Text(
                            '$text',
                            style: TextStyle(
                              fontSize: 16,
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
                color: Theme.of(context).scaffoldBackgroundColor,
              );
            },
          ),
        );
      },
      elevation: 60,
    );
  }

  String getText(int index) {
    if (index == 0) {
      return 'Instagram View';
    } else if (index == 1) {
      return 'Copy Link';
    } else if (index == 2) {
      return 'File Manager';
    } else if (index == 3) {
      return 'Share';
    }
    return 'Delete';
  }

  String getSVG(int index) {
    if (index == 0) {
      return 'instagram';
    } else if (index == 1) {
      return 'copy';
    } else if (index == 2) {
      return 'file';
    } else if (index == 3) {
      return 'share';
    }
    return 'bin';
  }

  _launchInInsta(String url, context) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      showSnackbar(context, 'Unable to open link');
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
                  Navigator.of(context).pop(1);
                },
              )
            ],
          );
        });
      },
    );
  }

  getWhatsapp(context) {
    var size = MediaQuery.of(context).size;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Container(
                      color: Theme.of(context).primaryColor,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'WhatsApp downloaded media is present in Downloads>>WAStatusSaver',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
                FutureBuilder<bool>(
                  future: Permission.storage.isGranted,
                  builder: (context, snap) {
                    if (snap.data == true) {
                      if (!statusDir.existsSync())
                        statusDir.createSync(recursive: true);

                      mediaList = statusDir
                          .listSync()
                          .map((item) => item.path)
                          .where((item) =>
                              item.endsWith(".jpg") || item.endsWith(".mp4"))
                          .toList(growable: false);

                      mediaList = mediaList.reversed.toList();
                      if (mediaList.isEmpty) {
                        return Container(
                          height: 300,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.folder_rounded,
                                size: 50,
                              ),
                              SizedBox(height: 10),
                              Text('No saved media found...'),
                            ],
                          ),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.separated(
                          itemCount: mediaList.length,
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            String imgPath = mediaList[index];
                            print(imgPath);
                            if (imgPath.endsWith('.jpg'))
                              return getImage(imgPath);
                            else
                              return getVids(imgPath);
                          },
                          separatorBuilder: (context, index) {
                            return SizedBox(height: 12);
                          },
                        ),
                      );
                    } else {
                      return Container(
                        height: 300,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Allow storage permission\nto view whatsapp media downloads',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () async {
                                if (await requestPermission()) {
                                  setState(() {});
                                }
                              },
                              child: Text(
                                'Allow',
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
                          ],
                        ),
                      );
                    }
                  },
                ),
                SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ],
    );
  }

  getImage(String imgPath) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Column(
        children: [
          Container(
            height: 300,
            decoration: BoxDecoration(
              border: Border.all(
                width: 10,
                color: Theme.of(context).primaryColor,
              ),
              // borderRadius: BorderRadius.circular(8),
            ),
            child: Theme(
              data: ThemeData(
                splashColor: Colors.black.withOpacity(0.4),
              ),
              child: Material(
                elevation: 0,
                clipBehavior: Clip.hardEdge,
                color: Colors.transparent,
                shadowColor: Colors.transparent,
                child: Ink.image(
                  image: FileImage(
                    File(imgPath),
                  ),
                  fit: BoxFit.cover,
                  child: InkWell(
                    highlightColor: Colors.transparent,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/imgdownload',
                        arguments: [imgPath, true],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          Container(
            height: 50,
            color: Theme.of(context).primaryColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(),
                Row(
                  children: [
                    IconButton(
                      icon: SvgPicture.asset(
                        "assets/svg/file.svg",
                        width: IconTheme.of(context).size,
                        color: Theme.of(context).accentColor,
                      ),
                      onPressed: () {
                        OpenFile.open(imgPath);
                      },
                      splashRadius: 1,
                    ),
                    SizedBox(width: 15),
                    IconButton(
                      icon: SvgPicture.asset(
                        "assets/svg/share.svg",
                        width: IconTheme.of(context).size,
                        color: Theme.of(context).accentColor,
                      ),
                      onPressed: () {
                        Share.shareFiles([imgPath]);
                      },
                      splashRadius: 1,
                    ),
                    SizedBox(width: 15),
                    IconButton(
                      icon: SvgPicture.asset(
                        "assets/svg/bin.svg",
                        width: IconTheme.of(context).size,
                        color: Theme.of(context).accentColor,
                      ),
                      onPressed: () async {
                        var x = await _showDialogBoxWhatsapp(context, imgPath);
                        if (x == 1) {
                          showSnackbar(context, 'File deleted...');
                          setState(() {});
                        }
                      },
                      splashRadius: 1,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getVids(String videoFile) {
    print('vids');
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
            height: 300,
            child: FutureBuilder<String>(
              future: getThumbnailFile(videoFile),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  String? x = snapshot.data;
                  print(x);
                  if (x != null && x.length >= 1) {
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 8,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          child: Theme(
                            data: ThemeData(
                              splashColor: Colors.black.withOpacity(0.4),
                            ),
                            child: Material(
                              elevation: 0,
                              clipBehavior: Clip.hardEdge,
                              color: Colors.transparent,
                              shadowColor: Colors.transparent,
                              child: Ink.image(
                                image: FileImage(
                                  File(x),
                                ),
                                fit: BoxFit.cover,
                                child: InkWell(
                                  highlightColor: Colors.transparent,
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/viddownload',
                                      arguments: [videoFile, true],
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/viddownload',
                              arguments: [videoFile, true],
                            );
                          },
                          child: Align(
                            alignment: Alignment.center,
                            child: Container(
                              width: 65,
                              height: 65,
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.play_arrow,
                                size: 34,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error,
                          color: Colors.black,
                          size: 30,
                        ),
                        SizedBox(height: 5),
                        Text(
                          'File not found',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    );
                  }
                }
                return Container();
              },
            ),
          ),
          Container(
            height: 50,
            color: Theme.of(context).primaryColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(),
                Row(
                  children: [
                    IconButton(
                      icon: SvgPicture.asset(
                        "assets/svg/file.svg",
                        width: IconTheme.of(context).size,
                        color: Theme.of(context).accentColor,
                      ),
                      onPressed: () {
                        OpenFile.open(videoFile);
                      },
                      splashRadius: 1,
                    ),
                    SizedBox(width: 15),
                    IconButton(
                      icon: SvgPicture.asset(
                        "assets/svg/share.svg",
                        width: IconTheme.of(context).size,
                        color: Theme.of(context).accentColor,
                      ),
                      onPressed: () {
                        Share.shareFiles([videoFile]);
                      },
                      splashRadius: 1,
                    ),
                    SizedBox(width: 15),
                    IconButton(
                      icon: SvgPicture.asset(
                        "assets/svg/bin.svg",
                        width: IconTheme.of(context).size,
                        color: Theme.of(context).accentColor,
                      ),
                      onPressed: () async {
                        var x =
                            await _showDialogBoxWhatsapp(context, videoFile);
                        if (x == 1) {
                          showSnackbar(context, 'File deleted...');
                          setState(() {});
                        }
                      },
                      splashRadius: 1,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _showDialogBoxWhatsapp(context, String imgPath) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Theme.of(context).primaryColor,
            title: Text('Saved file will be deleted!'),
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
                  final file = File(imgPath);
                  await file.delete();
                  Navigator.of(context).pop(1);
                },
              )
            ],
          );
        });
      },
    );
  }

  Future<String> getThumbnailFile(String videoFile) async {
    String fileDir = videoFile;
    bool fileExist = File(fileDir).existsSync();
    if (fileExist) {
      directory = (await getExternalStorageDirectory())!;
      final thumbnail = await VideoThumbnail.thumbnailFile(
        video: videoFile,
        thumbnailPath: directory.path,
        imageFormat: ImageFormat.JPEG,
        quality: 20,
      );
      final file = File(thumbnail!);
      filePath = file.path;
      return filePath;
    } else {
      return '';
    }
  }
}

class ListViewList extends StatefulWidget {
  const ListViewList({
    Key? key,
    required DownloadData downloadData,
  })  : _downloadData = downloadData,
        super(key: key);

  final DownloadData _downloadData;

  @override
  _ListViewListState createState() => _ListViewListState();
}

class _ListViewListState extends State<ListViewList> {
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 5), (Timer t) {
      if (this.mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: FutureBuilder(
              future: dbHelper.query(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var x = snapshot.data;
                  List<Map<String, dynamic>> y =
                      widget._downloadData.dataFromDB(x);
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: y.length,
                          itemBuilder: (context, index) {
                            return DownloadedItem(
                                size: size, y: y, index: index);
                          },
                          separatorBuilder: (context, index) {
                            return SizedBox(height: 15);
                          },
                        ),
                      ),
                      SizedBox(height: 150),
                    ],
                  );
                } else {
                  return Container();
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}

class DownloadedItem extends StatelessWidget {
  const DownloadedItem({
    Key? key,
    required this.size,
    required this.y,
    required this.index,
  }) : super(key: key);

  final Size size;
  final y;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          DownloadedImage(size: size, y: y, index: index),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              color: Theme.of(context).primaryColor,
              child: ListTile(
                title: Text(
                  y[index]['userName'],
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: GestureDetector(
                  onTap: () {
                    _settingModalBottomSheet(context, y, index);
                  },
                  child: Icon(
                    Icons.more_vert_rounded,
                    size: 28,
                    color: Theme.of(context).accentColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _settingModalBottomSheet(
    context,
    List<Map<String, dynamic>> y,
    int index,
  ) {
    var size = MediaQuery.of(context).size;
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          height: 350,
          child: ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            itemCount: 5,
            itemBuilder: (context, i) {
              String text = getText(i);
              String svg = getSVG(i);
              return Container(
                child: Material(
                  child: InkWell(
                    onTap: () async {
                      if (i == 0) {
                        _launchInInsta(y[index]['postUrl'], context);
                        Navigator.pop(context);
                      } else if (i == 1) {
                        Clipboard.setData(
                                ClipboardData(text: y[index]['postUrl']))
                            .then((value) {
                          showSnackbar(context, 'Link Copied...');
                          Navigator.of(context).pop();
                        });
                      } else if (i == 2) {
                        OpenFile.open(y[index]['directory']);
                        Navigator.of(context).pop();
                      } else if (i == 3) {
                        _sharePost(y[index]['postUrl']);
                        Navigator.of(context).pop();
                      } else {
                        var x = await _showDialogBox(context, y[index]['tag']);
                        if (x == 1) {
                          showSnackbar(context, 'File deleted...');
                        }
                        Navigator.of(context).pop();
                      }
                    },
                    child: Container(
                      width: size.width,
                      height: 70,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(width: 25),
                          SvgPicture.asset(
                            "assets/svg/$svg.svg",
                            width: IconTheme.of(context).size! - 2,
                            color: Theme.of(context).accentColor,
                          ),
                          SizedBox(width: 35),
                          Text(
                            '$text',
                            style: TextStyle(
                              fontSize: 16,
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
                color: Theme.of(context).scaffoldBackgroundColor,
              );
            },
          ),
        );
      },
      elevation: 60,
    );
  }

  String getText(int index) {
    if (index == 0) {
      return 'Instagram View';
    } else if (index == 1) {
      return 'Copy Link';
    } else if (index == 2) {
      return 'File Manager';
    } else if (index == 3) {
      return 'Share';
    }
    return 'Delete';
  }

  String getSVG(int index) {
    if (index == 0) {
      return 'instagram';
    } else if (index == 1) {
      return 'copy';
    } else if (index == 2) {
      return 'file';
    } else if (index == 3) {
      return 'share';
    }
    return 'bin';
  }

  _launchInInsta(String url, context) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      showSnackbar(context, 'Unable to open link');
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
                  Navigator.of(context).pop(1);
                },
              )
            ],
          );
        });
      },
    );
  }
}

class DownloadedImage extends StatelessWidget {
  const DownloadedImage({
    Key? key,
    required this.size,
    required this.y,
    required this.index,
  }) : super(key: key);

  final Size size;
  final y;
  final int index;
  @override
  Widget build(BuildContext context) {
    String fileDir = y[index]['directory'];
    bool fileExist = File(fileDir).existsSync();
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: SizedBox(
              width: size.width,
              height: size.width - 60,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      (y[index]['isVideo'])
                          ? GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/gallery',
                                  arguments: y[index]['tag'],
                                );
                              },
                              child: VideoFile(y: y, index: index))
                          : GestureDetector(
                              onTap: () {
                                if (fileExist) {
                                  Navigator.pushNamed(
                                    context,
                                    '/gallery',
                                    arguments: y[index]['tag'],
                                  );
                                }
                              },
                              child: (fileExist)
                                  ? Image.file(
                                      File(y[index]['directory']),
                                      errorBuilder: (_, __, ___) {
                                        return Container();
                                      },
                                      fit: BoxFit.cover,
                                    )
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.error,
                                          color: Colors.black,
                                          size: 30,
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          'File not found',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black38,
                                blurRadius: 100,
                                spreadRadius: 50,
                              )
                            ],
                          ),
                          child: Icon(
                            (y[index]['containPosts'])
                                ? Icons.folder
                                : (y[index]['isVideo'])
                                    ? Icons.play_arrow
                                    : Icons.image,
                            size: (y[index]['isVideo']) ? 45 : 30,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (y[index]['containPosts'])
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black38,
                                  blurRadius: 100,
                                  spreadRadius: 50,
                                )
                              ],
                            ),
                            child: Text(
                              '1/' + y[index]['childPosts'].toString(),
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      else
                        Container(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class VideoFile extends StatefulWidget {
  const VideoFile({
    Key? key,
    required this.y,
    required this.index,
  }) : super(key: key);

  final y;
  final int index;

  @override
  _VideoFileState createState() => _VideoFileState();
}

class _VideoFileState extends State<VideoFile> {
  String filePath = '';
  Directory? directory;

  @override
  void initState() {
    super.initState();
    getThumbnailFile();
  }

  Future<String> getThumbnailFile() async {
    String fileDir = widget.y[widget.index]['directory'];
    bool fileExist = File(fileDir).existsSync();
    if (fileExist) {
      directory = await getExternalStorageDirectory();
      final thumbnail = await VideoThumbnail.thumbnailFile(
        video: widget.y[widget.index]['directory'],
        thumbnailPath: directory!.path,
        imageFormat: ImageFormat.JPEG,
        quality: 20,
      );
      final file = File(thumbnail!);
      filePath = file.path;
      return filePath;
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: getThumbnailFile(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          String? x = snapshot.data;
          if (x!.length >= 1) {
            return Image.file(
              File(x),
              errorBuilder: (_, __, ___) {
                return Container();
              },
              fit: BoxFit.cover,
            );
          } else {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.error,
                  color: Colors.black,
                  size: 30,
                ),
                SizedBox(height: 5),
                Text(
                  'File not found',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            );
          }
        }
        return Container();
      },
    );
  }
}

class ExpandedIcons extends StatelessWidget {
  const ExpandedIcons({
    Key? key,
    required this.size,
    required this.y,
    required this.index,
  }) : super(key: key);

  final Size size;
  final y;
  final int index;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          color: Theme.of(context).primaryColor,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Container(
                        child: Material(
                          child: InkWell(
                            splashColor: Colors.transparent,
                            onTap: () {
                              _launchInInsta(y[index]['postUrl'], context);
                            },
                            child: SizedBox(
                              width: 300,
                              height: 300,
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: SvgPicture.asset(
                                  "assets/svg/insta.svg",
                                  width: IconTheme.of(context).size,
                                  color: Theme.of(context).accentColor,
                                ),
                              ),
                            ),
                          ),
                          color: Colors.transparent,
                        ),
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Container(
                        child: Material(
                          child: InkWell(
                            splashColor: Colors.transparent,
                            onTap: () {
                              Clipboard.setData(
                                      ClipboardData(text: y[index]['postUrl']))
                                  .then((value) {
                                showSnackbar(context, 'Link Copied...', 3);
                              });
                            },
                            child: SizedBox(
                              width: 300,
                              height: 300,
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: SvgPicture.asset(
                                  "assets/svg/copy.svg",
                                  width: IconTheme.of(context).size,
                                  color: Theme.of(context).accentColor,
                                ),
                              ),
                            ),
                          ),
                          color: Colors.transparent,
                        ),
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Container(
                        child: Material(
                          child: InkWell(
                            splashColor: Colors.transparent,
                            onTap: () {
                              OpenFile.open(y[index]['directory']);
                            },
                            child: SizedBox(
                              width: 300,
                              height: 300,
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: SvgPicture.asset(
                                  "assets/svg/file.svg",
                                  width: IconTheme.of(context).size,
                                  color: Theme.of(context).accentColor,
                                ),
                              ),
                            ),
                          ),
                          color: Colors.transparent,
                        ),
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Container(
                        child: Material(
                          child: InkWell(
                            splashColor: Colors.transparent,
                            onTap: () {
                              _sharePost(y[index]['postUrl']);
                            },
                            child: SizedBox(
                              width: 300,
                              height: 300,
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: SvgPicture.asset(
                                  "assets/svg/share.svg",
                                  width: IconTheme.of(context).size,
                                  color: Theme.of(context).accentColor,
                                ),
                              ),
                            ),
                          ),
                          color: Colors.transparent,
                        ),
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Container(
                        child: Material(
                          child: InkWell(
                            splashColor: Colors.transparent,
                            onTap: () async {
                              var x = await _showDialogBox(
                                  context, y[index]['tag']);
                              if (x == 1) {
                                showSnackbar(context, 'File deleted...', 3);
                              }
                            },
                            child: SizedBox(
                              width: 300,
                              height: 300,
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: SvgPicture.asset(
                                  "assets/svg/bin.svg",
                                  width: IconTheme.of(context).size,
                                  color: Theme.of(context).accentColor,
                                ),
                              ),
                            ),
                          ),
                          color: Colors.transparent,
                        ),
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
                  Navigator.of(context).pop(1);
                },
              )
            ],
          );
        });
      },
    );
  }
}
