import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ChewieVideoPlayer extends StatefulWidget {
  final List video;
  ChewieVideoPlayer(this.video);
  @override
  _ChewieVideoPlayerState createState() => _ChewieVideoPlayerState();
}

class _ChewieVideoPlayerState extends State<ChewieVideoPlayer> {
  late VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    super.initState();
    if (widget.video[0] == false) {
      _videoPlayerController = VideoPlayerController.file(
        File(widget.video[1]),
      )..initialize().then(
          (_) {
            setState(() {});
            _videoPlayerController.play();
            _videoPlayerController.setLooping(true);
          },
        );
    } else {
      _videoPlayerController = VideoPlayerController.network(
        widget.video[1],
      )..initialize().then(
          (_) {
            setState(() {});
            _videoPlayerController.play();
            _videoPlayerController.setLooping(true);
          },
        );
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
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
            Navigator.of(context).pop();
          },
        ),
        title: Text('Video Player'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Container(
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
    );
  }
}
