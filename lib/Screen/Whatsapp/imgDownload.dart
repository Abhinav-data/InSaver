import 'dart:io';
import 'dart:math';
import 'package:appodeal_flutter/appodeal_flutter.dart';
import 'package:flutter/material.dart';
import 'package:insaver/Utils/constants.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImageDownload extends StatefulWidget {
  final List args;
  ImageDownload(this.args);

  @override
  _ImageDownloadState createState() => _ImageDownloadState();
}

class _ImageDownloadState extends State<ImageDownload> {
  String _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();
  Widget ad = Container();

  @override
  void initState() {
    super.initState();
    if (!statusDir.existsSync()) {
      statusDir.createSync(recursive: true);
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
    String image = widget.args[0];
    bool inDownloads = widget.args[1];

    var size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();

              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios),
          ),
          title: Text('Gallery'),
        ),
        body: Column(
          children: [
            Container(
              child: ad,
            ),
            SizedBox(height: 5),
            Expanded(
              child: Stack(
                children: [
                  InteractiveViewer(
                    child: Container(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(image),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 100,
                    child: SizedBox(
                      height: 250,
                      width: 90,
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            (!inDownloads)
                                ? GestureDetector(
                                    onTap: () {
                                      _downloadFile(image);
                                      showInterstitialAd();
                                      showSnackbar(context, 'Image Saved');
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
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(),
                            GestureDetector(
                              onTap: () async {
                                Share.shareFiles([image]);
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _downloadFile(String filePath) async {
    File originalVideoFile = File(filePath);
    String tag = getRandomString(5);
    String filename =
        'WA-${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}${DateTime.now().hour}${DateTime.now().minute}${DateTime.now().second}${DateTime.now().millisecond}$tag.jpg';
    String path = statusDir.path;
    String newFileName = "$path/$filename";

    if (await createDir()) {
      await originalVideoFile.copy(newFileName);
    }
    return newFileName;
  }

  String getRandomString(int length) => String.fromCharCodes(
        Iterable.generate(
          length,
          (_) => _chars.codeUnitAt(
            _rnd.nextInt(_chars.length),
          ),
        ),
      );
}
