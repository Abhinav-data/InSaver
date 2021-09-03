import 'package:appodeal_flutter/appodeal_flutter.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:insaver/Screen/Home/home.dart';
import 'package:insaver/Screen/Media/mediaData.dart';
import 'package:insaver/Utils/constants.dart';
import 'package:share/share.dart';

class Hashtag extends StatefulWidget {
  @override
  _HashtagState createState() => _HashtagState();
}

class _HashtagState extends State<Hashtag> {
  TextEditingController _hashtagText = TextEditingController();
  List<List<String>> tags = [];
  bool showPopular = true;
  String title = 'Popular hashtags...';

  bool adLoaded = false;

  bool showProgress = false;
  Widget hash = Container();
  Widget ad = Container();


  @override
  void initState() {
    super.initState();
    ad = AppodealBanner();

    hash = popularTags();
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
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        showInterstitialAd();
        Navigator.of(context).pushReplacementNamed('/home');
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Hashtags",
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
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                                    controller: _hashtagText,
                                    cursorColor: Color(0xFFfa6b60),
                                    decoration: InputDecoration(
                                      contentPadding:
                                          EdgeInsets.fromLTRB(12, 6, 12, 6),
                                      hintText: 'Insert word eg. "beard"...',
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
                                    inputFormatters: [
                                      new FilteringTextInputFormatter.allow(
                                        RegExp("[a-zA-Z0-9]"),
                                      ),
                                    ],
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Row(
                                    children: [
                                      generateTags(),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 5, 16, 5),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(0),
                            title: Text(
                              title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: (showProgress)
                                ? CircularProgressIndicator(
                                    color: Theme.of(context).canvasColor,
                                  )
                                : (showPopular)
                                    ? Container(width: 0, height: 0)
                                    : IconButton(
                                        icon: Icon(
                                          Icons.arrow_back,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            hash = popularTags();
                                            showPopular = !showPopular;
                                            title = 'Popular hashtags...';
                                          });
                                        },
                                      ),
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: Duration(milliseconds: 500),
                          child: hash,
                        ),
                        SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
              FutureBuilder<bool>(
                future: checkConnectivity(context),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    bool? con = snapshot.data;
                    if (con!)
                      return Container(
                          child:ad,
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

  generateTags() {
    return Expanded(
      child: ElevatedButton(
        onPressed: () async {
          hideKeyboard(context);
          String hashtag = _hashtagText.text;
          if (checkHashtag(hashtag)) {
            setState(() {
              title = 'Searching for $hashtag...';
              showProgress = true;
            });
            tags = await InstaData.hashtagGenerator(hashtag);
            setState(() {
              title = 'Hashtags for "$hashtag"';
              showProgress = false;
              hash = searchedtags();
              showPopular = !showPopular;
            });
          }
        },
        child: Text(
          'Generate Hashtags',
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

  getIcon(int index, String tags) {
    Icon icon;
    if (index == 0)
      icon = Icon(Icons.edit);
    else if (index == 1)
      icon = Icon(Icons.copy);
    else
      icon = Icon(Icons.share);

    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Container(
        child: Material(
          child: InkWell(
            onTap: () {
              if (index == 0) {
                Navigator.pushNamed(context, '/edittag', arguments: tags);
              } else if (index == 1) {
                Clipboard.setData(ClipboardData(text: tags)).then((value) {
                  showSnackbar(context, 'Tags Copied...');
                });
              } else {
                Share.share('$tags');
              }
            },
            child: SizedBox(
              width: 60,
              height: 60,
              child: icon,
            ),
          ),
          color: Colors.transparent,
        ),
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  bool checkHashtag(String hash) {
    if (hash.length == 0) {
      showSnackbar(context, 'Text must not be empty...');
      return false;
    }
    return true;
  }

  String getText(int index) {
    List<String> tag = [
      'beard',
      'music',
      'happy',
      'beach',
      'workout',
      'car',
      'life',
      'bike',
      'love',
      'study',
      'sleep',
      'yoga'
    ];
    return tag[index];
  }

  buttonTag(String text) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Container(
        child: Material(
          child: InkWell(
            onTap: () async {
              hideKeyboard(context);
              String hashtag = text;
              if (checkHashtag(hashtag)) {
                setState(() {
                  _hashtagText.text = text;
                  title = 'Searching for $hashtag...';
                  showProgress = true;
                });
                tags = await InstaData.hashtagGenerator(hashtag);
                setState(() {
                  title = 'Hashtags for "$hashtag"';
                  showProgress = false;
                  if (showPopular) {
                    hash = searchedtags();
                    showPopular = !showPopular;
                  }
                });
              }
            },
            child: SizedBox(
              width: 300,
              height: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    "assets/svg/$text.svg",
                    width: IconTheme.of(context).size! + 8,
                    color: Theme.of(context).accentColor,
                  ),
                  SizedBox(height: 10),
                  Text(
                    '$text',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
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
    );
  }

  popularTags() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
      child: GridView.builder(
        shrinkWrap: true,
        itemCount: 12,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemBuilder: (BuildContext context, int index) {
          String text = getText(index);
          return buttonTag(text);
        },
      ),
    );
  }

  searchedtags() {
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: tags.length,
      itemBuilder: (context, i) {
        String currTags = tags[i].join(' ').toLowerCase();
        return Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Container(
              color: Theme.of(context).primaryColor,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(
                          ClipboardData(text: currTags),
                        ).then((value) {
                          showSnackbar(context, 'Tags Copied...');
                        });
                      },
                      child: Text(
                        currTags,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.4,
                          letterSpacing: 0.9,
                          wordSpacing: 1.2,
                        ),
                      ),
                    ),
                    Container(
                      height: 80,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          getIcon(0, currTags),
                          getIcon(1, currTags),
                          getIcon(2, currTags),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        if (index % 2 == 0) {
          print(index);
          return FutureBuilder<bool>(
            future: checkConnectivity(context),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                bool? con = snapshot.data;
                if (con!)
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                    child: Container(
                        // child: banner,
                        ),
                  );
              }
              return Container();
            },
          );
        }
        return SizedBox(height: 30);
      },
    );
  }
}
