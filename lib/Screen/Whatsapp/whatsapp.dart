import 'dart:io';
import 'package:appodeal_flutter/appodeal_flutter.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:marquee/marquee.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:insaver/Screen/Home/home.dart';
import 'package:insaver/Utils/constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class Whatsapp extends StatefulWidget {
  const Whatsapp({Key? key}) : super(key: key);

  @override
  _WhatsappState createState() => _WhatsappState();
}

class _WhatsappState extends State<Whatsapp>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  List<String> filesToDownload = [];
  bool enableCheck = false;
  List<String> imageList = [];
  late Directory directory;
  Map<String, bool> videos = {};
  String tmpThumbnail = '';
  String filePath = '';
  List<String> videoList = [];

  Map<String, bool> images = {};
  Directory thumbDir = Directory('/storage/emulated/0/.statussaver/.thumbs');

  showInterstitialAd() async {
    if (await Appodeal.canShow(AdType.INTERSTITIAL) &&
        await Appodeal.isReadyForShow(AdType.INTERSTITIAL))
      await Appodeal.show(AdType.INTERSTITIAL);
  }

  Widget ad = Container();

  @override
  void initState() {
    super.initState();
    ad = AppodealBanner();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      floatingActionButton: (enableCheck)
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  enableCheck = !enableCheck;
                });
              },
              backgroundColor: color,
              splashColor: Colors.black45,
              child: Icon(
                Icons.close,
                color: Colors.white,
                size: 28,
              ),
            )
          : Container(),
      drawer: InstaDrawer(size: size),
      body: getImages(),
      bottomNavigationBar: SizedBox(
        width: size.width,
        height: 70,
        child: Container(
          color: Theme.of(context).primaryColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: size.width - 30,
                height: 50.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (enableCheck == false) {
                        images = {};
                        for (var i = 0; i < imageList.length; i++) {
                          images[imageList[i]] = false;
                        }

                        setState(() {
                          enableCheck = !enableCheck;
                        });
                        return;
                      } else if (!images.containsValue(true)) {
                        showSnackbar(context, 'No media is selected');
                      } else {
                        images.forEach((key, value) {
                          if (value == true) {
                            _downloadFile(key);
                          }
                        });
                        setState(() {
                          enableCheck = !enableCheck;
                        });
                        showInterstitialAd();
                        showSnackbar(context, 'Selected media downloaded...');
                      }
                    },
                    child: Text(
                      'Download',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(color),
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

  Future<void> _downloadFile(String filePath) async {
    File originalVideoFile = File(filePath);
    String tag = getRandomString(5);
    bool isVid = filePath.contains('mp4');
    String filename =
        'WA-${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}${DateTime.now().hour}${DateTime.now().minute}${DateTime.now().second}${DateTime.now().millisecond}$tag';
    String path = statusDir.path;
    String newFileName = '';
    if (isVid) {
      newFileName = "$path/$filename" + '.mp4';
    } else {
      newFileName = "$path/$filename" + '.jpg';
    }
    if (await createDir()) {
      await originalVideoFile.copy(newFileName);
    }
  }

  getImages() {
    var size = MediaQuery.of(context).size;

    return FutureBuilder<List<bool>>(
      future: Future.wait([
        DeviceApps.isAppInstalled('com.whatsapp'),
        Permission.storage.isGranted,
      ]),
      builder: (context, snap) {
        if (snap.hasData) {
          if (snap.data![0] == false) {
            return Container(
              width: size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    FontAwesome.whatsapp,
                    color: Theme.of(context).accentColor,
                    size: 50,
                  ),
                  SizedBox(height: 15),
                  Text(
                    "Whatsapp not installed",
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          if (snap.data![1] == false) {
            return Container(
              width: size.width,
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
          if (snap.data![0] == true && snap.data![1] == true) {
            if (!Directory("${whatsDir.path}").existsSync()) {
              return Container(
                width: size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error,
                      color: Theme.of(context).accentColor,
                      size: 50,
                    ),
                    SizedBox(height: 15),
                    Text(
                      "Sorry could not find\nwhatsapp directory",
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            } else {
              return NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (overscroll) {
                  overscroll.disallowGlow();
                  return true;
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                  child: Column(
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            SingleChildScrollView(
                              child: Column(
                                children: [
                                  Container(
                                    color: Theme.of(context).primaryColor,
                                    child: SizedBox(
                                      height: kBottomNavigationBarHeight - 20,
                                      child: Marquee(
                                        text:
                                            'WhatsApp downloaded media is present in Downloads>>WAStatusSaver',
                                        blankSpace: 100,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  FutureBuilder<bool>(
                                    future: requestPermission(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        bool permission = snapshot.data!;
                                        if (permission == true) {
                                          imageList = whatsDir
                                              .listSync()
                                              .map((item) => item.path)
                                              .where((item) =>
                                                  item.endsWith(".mp4") ||
                                                  item.endsWith(".jpg"))
                                              .toList(growable: false);
                                          if (imageList.length != 0) {
                                            return GridView.builder(
                                              shrinkWrap: true,
                                              itemCount: imageList.length,
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              gridDelegate:
                                                  new SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 2,
                                                childAspectRatio: 0.8,
                                                mainAxisSpacing: 8,
                                                crossAxisSpacing: 8,
                                              ),
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                String imgPath =
                                                    imageList[index];
                                                if (imgPath.endsWith('.jpg'))
                                                  return getContImg(imgPath);
                                                else
                                                  return getVids(imgPath);
                                              },
                                            );
                                          } else {
                                            return Center(
                                              child: Text(
                                                'No Images Found!',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            );
                                          }
                                        } else {
                                          return Center(
                                            child: Text(
                                              'Permission Denied',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                      return Container();
                                    },
                                  ),
                                  SizedBox(height: 100),
                                ],
                              ),
                            ),
                            Align(alignment: Alignment.bottomCenter, child: ad),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          }
        }
        return Container();
      },
    );
  }

  getVids(String videoFile) {
    return FutureBuilder<String>(
      future: getThumbnailFile(videoFile),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          String? x = snapshot.data;
          if (x!.length >= 1) {
            return Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 3,
                      color: Colors.white,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Theme(
                      data: ThemeData(
                        splashColor: Colors.black.withOpacity(0.4),
                      ),
                      child: Material(
                        elevation: 0,
                        borderRadius: BorderRadius.circular(8),
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
                              if (!enableCheck) {
                                Navigator.pushNamed(
                                  context,
                                  '/viddownload',
                                  arguments: [videoFile, false],
                                );
                              } else {
                                bool? val = images[videoFile];
                                setState(() {
                                  images[videoFile] = !val!;
                                });
                              }
                            },
                            onLongPress: () {
                              images = {};
                              for (var i = 0; i < imageList.length; i++) {
                                images[imageList[i]] = false;
                              }
                              images[videoFile] = true;

                              setState(() {
                                enableCheck = !enableCheck;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                (enableCheck)
                    ? Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                          ),
                          child: Theme(
                            child: Checkbox(
                              checkColor: Colors.white,
                              activeColor: color,
                              value: images[videoFile],
                              onChanged: (val) {
                                setState(() {
                                  images[videoFile] = val!;
                                });
                              },
                            ),
                            data: ThemeData(
                              unselectedWidgetColor: Colors.black,
                            ),
                          ),
                        ),
                      )
                    : Container(),
                GestureDetector(
                  onTap: () {
                    if (!enableCheck) {
                      Navigator.pushNamed(
                        context,
                        '/viddownload',
                        arguments: [videoFile, false],
                      );
                    } else {
                      bool? val = videos[videoFile];
                      setState(() {
                        videos[videoFile] = !val!;
                      });
                    }
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

  getContImg(String imgPath) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              width: 3,
              color: Colors.white,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Theme(
              data: ThemeData(
                splashColor: Colors.black.withOpacity(0.4),
              ),
              child: Material(
                elevation: 0,
                borderRadius: BorderRadius.circular(8),
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
                      if (!enableCheck) {
                        Navigator.pushNamed(
                          context,
                          '/imgdownload',
                          arguments: [imgPath, false],
                        );
                      } else {
                        bool? val = images[imgPath];
                        setState(() {
                          images[imgPath] = !val!;
                        });
                      }
                    },
                    onLongPress: () {
                      images = {};
                      for (var i = 0; i < imageList.length; i++) {
                        images[imageList[i]] = false;
                      }
                      images[imgPath] = true;

                      setState(() {
                        enableCheck = !enableCheck;
                      });
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        (enableCheck)
            ? Positioned(
                top: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: Theme(
                    child: Checkbox(
                      checkColor: Colors.white,
                      activeColor: color,
                      value: images[imgPath],
                      onChanged: (val) {
                        setState(() {
                          images[imgPath] = val!;
                        });
                      },
                    ),
                    data: ThemeData(
                      unselectedWidgetColor: Colors.black,
                    ),
                  ),
                ),
              )
            : Container(),
      ],
    );
  }
}
