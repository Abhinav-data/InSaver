import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:insaver/Screen/Download/download.dart';
import 'package:insaver/Screen/Download/downloadData.dart';
import 'package:insaver/Screen/Media/mediaData.dart';
import 'package:insaver/Utils/constants.dart';
import 'package:insaver/Utils/db.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_file/open_file.dart';
import 'package:share/share.dart';

class GridViewList extends StatefulWidget {
  const GridViewList({
    Key? key,
    required DownloadData downloadData,
  })  : _downloadData = downloadData,
        super(key: key);

  final DownloadData _downloadData;

  @override
  _GridViewListState createState() => _GridViewListState();
}

class _GridViewListState extends State<GridViewList> {
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
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      (y.length != 0)
                          ? Padding(
                              padding: const EdgeInsets.all(8),
                              child: GridView.builder(
                                shrinkWrap: true,
                                itemCount: y.length,
                                physics: NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    new SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.8,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                ),
                                itemBuilder: (BuildContext context, int index) {
                                  String fileDir = y[index]['directory'];
                                  bool fileExist = File(fileDir).existsSync();
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: Container(
                                      color: Theme.of(context).primaryColor,
                                      child: Column(
                                        children: [
                                          GridViewTop(y: y, index: index),
                                          GridViewBottom(
                                            y: y,
                                            fileExist: fileExist,
                                            index: index,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          : Container(),
                      SizedBox(height: 150),
                    ],
                  );
                }
                return Container();
              },
            ),
          ),
        ),
      ],
    );
  }
}

class GridViewBottom extends StatelessWidget {
  const GridViewBottom({
    Key? key,
    required this.y,
    required this.fileExist,
    required this.index,
  }) : super(key: key);

  final List<Map<String, dynamic>> y;
  final bool fileExist;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 4,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Container(
            color: Colors.white,
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
                        child: VideoFile(y: y, index: index),
                      )
                    : GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/gallery',
                            arguments: y[index]['tag'],
                          );
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error,
                                    color: Colors.black,
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    'File not found',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
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
                      size: (y[index]['isVideo']) ? 30 : 25,
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
                          fontSize: 20,
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
    );
  }
}

class GridViewTop extends StatefulWidget {
  const GridViewTop({
    Key? key,
    required this.y,
    required this.index,
  }) : super(key: key);

  final List<Map<String, dynamic>> y;
  final int index;

  @override
  _GridViewTopState createState() => _GridViewTopState();
}

class _GridViewTopState extends State<GridViewTop> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Container(
        child: SizedBox(
          width: 1000,
          child: ListTile(
            title: Text(
              widget.y[widget.index]['userName'],
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).accentColor,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              icon: Icon(Icons.more_vert_rounded),
              onPressed: () {
                _settingModalBottomSheet(context, widget.y, widget.index);
              },
            ),
          ),
        ),
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
          color: Theme.of(context).primaryColor,
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
                      } else if (i == 1) {
                        Clipboard.setData(
                                ClipboardData(text: y[index]['postUrl']))
                            .then((value) {
                          showSnackbar(context, 'Link Copied...');
                        });
                      } else if (i == 2) {
                        OpenFile.open(y[index]['directory']);
                      } else if (i == 3) {
                        _sharePost(y[index]['postUrl']);
                      } else {
                        var x = await _showDialogBox(context, y[index]['tag']);
                        if (x == 1) {
                          showSnackbar(context, 'File deleted...');
                        }
                      }
                      Navigator.of(context).pop();
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
