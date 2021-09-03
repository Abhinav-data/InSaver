import 'dart:io';
import 'dart:math';
import 'package:appodeal_flutter/appodeal_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:insaver/Utils/db.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

Directory instaDir = Directory('/storage/emulated/0/Download/InSaver');
Directory statusDir = Directory('/storage/emulated/0/Download/WAStatusSaver');
Directory whatsDir = Directory(
    '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses');

String url =
    'https://play.google.com/store/apps/details?id=com.studio6.instagram.media.post.reel.igtv.story.downloader';

Color color = Color(0xFFf85343);
String _chars =
    'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

showSnackbar(context, text) {
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
    ),
  );
}

Future<bool> createDir() async {
  if (statusDir.existsSync() && instaDir.existsSync()) {
    return true;
  }

  if (!statusDir.existsSync()) {
    statusDir.createSync(recursive: true);
  }
  if (!instaDir.existsSync()) {
    instaDir.createSync(recursive: true);
  }
  if (statusDir.existsSync() && instaDir.existsSync()) {
    return true;
  }
  return false;
}

hideKeyboard(context) {
  FocusScopeNode currentFocus = FocusScope.of(context);
  if (!currentFocus.hasPrimaryFocus) {
    currentFocus.unfocus();
  }
}

fetchLoading(bool fetch, context) {
  if (fetch) {
    return Column(
      children: [
        SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
          child: SizedBox(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Theme.of(context).primaryColor,
              ),
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: ListTile(
                  title: Text('Fetching results...'),
                  trailing: CircularProgressIndicator(
                    color: Theme.of(context).canvasColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  } else {
    return Container();
  }
}

Future<bool> checkConnectivity(context) async {
  var connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult == ConnectivityResult.none) {
    return false;
  }
  return true;
}

bool checkLink(String link) {
  List<String> keys = ['/p/', '/reel/', '/tv/', 'stories/'];
  for (var i = 0; i < keys.length; i++) {
    if (link.contains(keys[i]) && link.contains('instagram.com')) {
      return true;
    }
  }
  return false;
}

bool checkStory(String link) {
  if (link.contains('/stories/') && link.contains('instagram.com')) {
    return true;
  }
  return false;
}

Random _rnd = Random();

String getRandomString(int length) => String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => _chars.codeUnitAt(
          _rnd.nextInt(_chars.length),
        ),
      ),
    );

String getFileName(String tag, int index, bool isVideo) {
  return 'IG-${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}${DateTime.now().hour}${DateTime.now().minute}${DateTime.now().second}${DateTime.now().millisecond}$tag$index${isVideo ? '.mp4' : '.jpg'}';
}

Future<void> saveToDB(
  String url,
  String fileName,
  String tag,
  String profile,
  String username,
  String savedDir,
  String time,
) async {
  Map<String, dynamic> row = {
    DB.url: url,
    DB.fileName: fileName,
    DB.tag: tag,
    DB.profile: profile,
    DB.username: username,
    DB.savedDir: savedDir,
    DB.time: time,
  };
  final id = await dbHelper.insert(row);
  print(id);
}

Future<bool> requestPermission() async {
  final status = Permission.storage;
  if (await status.isGranted) {
    return await createDir();
  } else {
    var result = await status.request();
    if (result == PermissionStatus.granted) {
      return await createDir();
    }
  }
  return false;
}

Future<bool> checkPermissions() async {
  if (await requestPermission()) {
    return await createDir();
  }
  return false;
}

launchInInsta(String url, context) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    showSnackbar(context, 'Unable to open link');
  }
}

addToError({
  required String funcName,
  required String url,
  required String error,
}) async {
  String now = DateTime.now().toString();
  await FirebaseFirestore.instance.collection('Errors').doc('$funcName').set(
    {
      'url': url,
      'error': error,
      'stamp': now,
    },
    SetOptions(merge: true),
  );
}

void initializeAppodeal() async {
  Appodeal.setAppKeys(
    androidAppKey: androidId,
  );

  await Appodeal.initialize(
    hasConsent: false,
    adTypes: [
      AdType.BANNER,
      AdType.INTERSTITIAL,
      AdType.REWARD,
      AdType.NON_SKIPPABLE
    ],
    testMode: false,
    verbose: false,
  );
}

// Admob Ad Ids
// String bannerID = 'ca-app-pub-1637245364039964/2238033689';
// String interstitialID = 'ca-app-pub-1637245364039964/7788623702';
// String appOpenID = 'ca-app-pub-1637245364039964/2536297028';
// String appID = 'ca-app-pub-1637245364039964~4363194647';

//Facebook Ads
// String bannerID = '788362555163220_788366065162869';
// String interstititalID = '788362555163220_788363955163080';

//Appodeal Id
String androidId = '66d1563d1e6232df4082d419b0d53f995b61510da4f5ee0a';

//Applovin
// String banner = '2db402e0d3e3b727';
// String interstitial = '';
