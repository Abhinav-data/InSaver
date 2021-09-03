import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:insaver/Screen/Media/media.dart';
import 'package:video_player/video_player.dart';

class ImageScreen extends StatefulWidget {
  final List<MediaInfo> args;
  ImageScreen(this.args);

  @override
  _ImageScreenState createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  int progress = 0;
  String tag = '';
  String filename = '';
  ReceivePort _port = ReceivePort();
  List<MediaInfo> media = <MediaInfo>[];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget build(BuildContext context) {
    media = widget.args;
    String image = media[0].download.toString();
    var size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            splashColor: Colors.transparent,
            onPressed: () {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios),
          ),
          elevation: 0,
          title: Text('Gallery'),
        ),
        body: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  InteractiveViewer(
                    child: Container(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CachedNetworkImage(
                            imageUrl: image,
                            imageBuilder: (context, imageProvider) {
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.contain,
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
                          // child: ClipRRect(
                          //   borderRadius: BorderRadius.circular(8),
                          //   child: Image.network(
                          //     image,
                          //     fit: BoxFit.contain,
                          //   ),
                          // ),
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
}

class VideoScreen extends StatefulWidget {
  final List<MediaInfo> args;
  VideoScreen(this.args);
  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  String _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();
  Directory dir = Directory('/storage/emulated/0/Download/InSaver');
  int progress = 0;
  String tag = '';
  String filename = '';
  List<MediaInfo> media = <MediaInfo>[];
  late VideoPlayerController _videoPlayerController;
  ReceivePort _port = ReceivePort();

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.network(
      widget.args[0].download,
    )..initialize().then(
        (_) {
          setState(() {});
          _videoPlayerController.play();
          _videoPlayerController.setLooping(true);
        },
      );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    media = widget.args;
    return WillPopScope(
      onWillPop: () async {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        return true;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            splashColor: Colors.transparent,
            icon: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).accentColor,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();

              Navigator.of(context).pop();
            },
          ),
          title: Text('Video Player'),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: Column(
          children: [
            Expanded(
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Center(
                  child: _videoPlayerController.value.isInitialized
                      ? AspectRatio(
                          aspectRatio: _videoPlayerController.value.aspectRatio,
                          child: VideoPlayer(_videoPlayerController),
                        )
                      : new CircularProgressIndicator(
                          color: Theme.of(context).canvasColor,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
