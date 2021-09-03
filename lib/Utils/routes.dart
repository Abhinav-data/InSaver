import 'package:flutter/material.dart';
import 'package:insaver/Screen/Download/gallery.dart';
import 'package:insaver/Screen/Download/videoPlayer.dart';
import 'package:insaver/Screen/Home/home.dart';
import 'package:insaver/Screen/Media/media.dart';
import 'package:insaver/Screen/Media/web.dart';
import 'package:insaver/Screen/More/Policy/privacyPolicy.dart';
import 'package:insaver/Screen/More/Policy/termOfUse.dart';
import 'package:insaver/Screen/User/DP/dp.dart';
import 'package:insaver/Screen/User/UserPost/post.dart';
import 'package:insaver/Screen/User/Hashtags/edithash.dart';
import 'package:insaver/Screen/User/Hashtags/hashtag.dart';
import 'package:insaver/Screen/User/Story/image_video_screen.dart';
import 'package:insaver/Screen/User/Story/story.dart';
import 'package:insaver/Screen/More/credits.dart';
import 'package:insaver/Screen/More/howTo.dart';
import 'package:insaver/Screen/More/otherApps.dart';
import 'package:insaver/Screen/More/themeChange.dart';
import 'package:insaver/Screen/User/UserPost/postgallery.dart';
import 'package:insaver/Screen/Whatsapp/imgDownload.dart';
import 'package:insaver/Screen/Whatsapp/videoDownload.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) {
            return Home();
          },
          transitionDuration: Duration(milliseconds: 500),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(animation),
              child: child,
            );
          },
        );

      case '/home':
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) {
            return Home();
          },
          transitionDuration: Duration(milliseconds: 500),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(animation),
              child: child,
            );
          },
        );

      case '/gallery':
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) {
            return Gallery((args as String));
          },
          transitionDuration: Duration(milliseconds: 500),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(animation),
              child: child,
            );
          },
        );

      case '/web':
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) {
            return Web();
          },
          transitionDuration: Duration(milliseconds: 500),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(animation),
              child: child,
            );
          },
        );

      case '/userdp':
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) {
            return UserDP();
          },
          transitionDuration: Duration(milliseconds: 500),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(animation),
              child: child,
            );
          },
        );

      case '/hashtag':
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) {
            return Hashtag();
          },
          transitionDuration: Duration(milliseconds: 500),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(animation),
              child: child,
            );
          },
        );

      case '/userstory':
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) {
            return UserStory();
          },
          transitionDuration: Duration(milliseconds: 500),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(animation),
              child: child,
            );
          },
        );

      case '/post':
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) {
            return Post((args as String));
          },
          transitionDuration: Duration(milliseconds: 500),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(animation),
              child: child,
            );
          },
        );

      case '/postgallery':
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) {
            return PostGallery((args as String));
          },
          transitionDuration: Duration(milliseconds: 500),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(animation),
              child: child,
            );
          },
        );

      case '/videoPlayer':
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) {
            return ChewieVideoPlayer((args as List<dynamic>));
          },
          transitionDuration: Duration(milliseconds: 500),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(animation),
              child: child,
            );
          },
        );

      case '/videoscreen':
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) {
            return VideoScreen((args as List<MediaInfo>));
          },
          transitionDuration: Duration(milliseconds: 500),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(animation),
              child: child,
            );
          },
        );

      case '/imagescreen':
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) {
            return ImageScreen((args as List<MediaInfo>));
          },
          transitionDuration: Duration(milliseconds: 500),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(animation),
              child: child,
            );
          },
        );

      case '/howtodownload':
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) {
            return HowTo();
          },
          transitionDuration: Duration(milliseconds: 500),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(animation),
              child: child,
            );
          },
        );
      case '/theme':
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) {
            return ThemeChange();
          },
          transitionDuration: Duration(milliseconds: 500),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(animation),
              child: child,
            );
          },
        );

      case '/term':
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) {
            return Terms();
          },
          transitionDuration: Duration(milliseconds: 500),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(animation),
              child: child,
            );
          },
        );

      case '/imgdownload':
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) {
            return ImageDownload((args as List<dynamic>));
          },
          transitionDuration: Duration(milliseconds: 500),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(animation),
              child: child,
            );
          },
        );

      case '/viddownload':
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) {
            return VidDownload((args as List<dynamic>));
          },
          transitionDuration: Duration(milliseconds: 500),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(animation),
              child: child,
            );
          },
        );

      case '/privacy':
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) {
            return Privacy();
          },
          transitionDuration: Duration(milliseconds: 500),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(animation),
              child: child,
            );
          },
        );

      case '/edittag':
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) {
            return EditTags((args as String));
          },
          transitionDuration: Duration(milliseconds: 500),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(animation),
              child: child,
            );
          },
        );

      case '/credits':
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) {
            return Credits();
          },
          transitionDuration: Duration(milliseconds: 500),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(animation),
              child: child,
            );
          },
        );
    }
    return _errorRoute();
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
        ),
        body: Center(
          child: Text('ERROR'),
        ),
      );
    });
  }
}
