import 'dart:convert';

import 'package:http/http.dart';
import 'package:insaver/Screen/Media/mediaData.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostData {
  static Future<InstaProfile> userIdData(String username) async {
    InstaProfile _profileParsed = InstaProfile.enterEmpty();
    Client _client = Client();
    Response _response;
    var jsonData, finalData;
    Map<String, String> _userData = Map<String, String>();

    try {
      _response = await _client
          .get(Uri.parse('https://www.instagram.com/stories/$username/?__a=1'));

      jsonData = json.decode(_response.body);
      finalData = jsonData['user'];
      _profileParsed.id = finalData['id'];
      _profileParsed.username = finalData['username'];
      _profileParsed.profilePicUrl = finalData['profile_pic_url'];
      return _profileParsed;
    } catch (error) {
      print(error);
      _profileParsed = InstaProfile.enterEmpty();
      return _profileParsed;
    }
  }

  static Future<InstaProfile> userPosts(String username) async {
    InstaProfile _profileParsed = InstaProfile.enterEmpty();

    Client _client = Client();
    List<UserPost> _uPost = <UserPost>[];
    UserPost? post;
    Response _response, _res;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> _userP = Map<String, dynamic>();

    try {
      if (prefs.getBool('isLogged') ?? false) {
        _res = await _client.get(
          Uri.parse('https://www.instagram.com/$username/?__a=1'),
          headers: {
            "Cookie": prefs.getString('Cookie') ?? '',
            "User-Agent":
                "Instagram 9.5.2 (iPhone7,2; iPhone OS 9_3_3; en_US; en-US; scale=2.00; 750x1334) AppleWebKit/420+"
          },
        );
      } else {
        _res = await _client.get(
          Uri.parse('https://www.instagram.com/$username/?__a=1'),
        );
      }

      if (_res.body.toString().contains('{"user":{"id":') ||
          _res.body.toString().contains('seo_category_infos')) {
        var jsonData = json.decode(_res.body);
        if (_res.body.toString().contains('seo_category_infos')) {
          jsonData = jsonData['graphql'];
        }
        String id = jsonData['user']['id'];
        _profileParsed.id = jsonData['user']['id'];
        _profileParsed.username = jsonData['user']['username'];
        _profileParsed.profilePicUrl = jsonData['user']['profile_pic_url'];

        if (prefs.getBool('isLogged') ?? false) {
          _res = await _client.get(
            Uri.parse(
              'https://www.instagram.com/graphql/query/?query_id=17888483320059182&id=$id&first=18',
            ),
            headers: {
              "Cookie": prefs.getString('Cookie') ?? '',
              "User-Agent":
                  "Instagram 9.5.2 (iPhone7,2; iPhone OS 9_3_3; en_US; en-US; scale=2.00; 750x1334) AppleWebKit/420+"
            },
          );
        } else {
          _res = await _client.get(
            Uri.parse(
              'https://www.instagram.com/graphql/query/?query_id=17888483320059182&id=$id&first=18',
            ),
          );
        }
        var jData = json.decode(_res.body);
        jData = jData['data']['user']['edge_owner_to_timeline_media'];
        print(jData['edges'].length);
        if (jData['edges'].length == 0) {
          _profileParsed = InstaProfile.enterEmpty();
          _profileParsed.bio = 'login_required';
          return _profileParsed;
        }

        _profileParsed.postsCount = jData['count'];
        _profileParsed.end = jData['page_info']['end_cursor'];

        for (var i = 0; i < jData['edges'].length; i++) {
          _userP['shortcode'] = jData['edges'][i]['node']['shortcode'];
          _userP['thumbnailSrc'] = jData['edges'][i]['node']['thumbnail_src'];
          _userP['isVideo'] = jData['edges'][i]['node']['is_video'];
          post = UserPost.fromMap(_userP);
          _uPost.add(post);
        }
        _profileParsed.userPost = _uPost;
        _profileParsed.bio = 'got_info';
        return _profileParsed;
      } else {
        _profileParsed = InstaProfile.enterEmpty();
        _profileParsed.bio = 'invalid_username';
        return _profileParsed;
      }
    } catch (error) {
      print(error);
      _profileParsed = InstaProfile.enterEmpty();
      _profileParsed.bio = 'invalid_username';
      return _profileParsed;
    }
  }
}

class UserPost {
  String shortcode = '';
  String thumbnailSrc = '';
  bool isVideo = false;

  UserPost({
    required this.shortcode,
    required this.thumbnailSrc,
    required this.isVideo,
  });

  factory UserPost.fromMap(Map<String, dynamic> map) {
    return UserPost(
      shortcode: map['shortcode'] ?? '',
      thumbnailSrc: map['thumbnailSrc'] ?? '',
      isVideo: map['isVideo'] ?? '',
    );
  }

  factory UserPost.enterEmpty() {
    return UserPost(
      shortcode: '',
      thumbnailSrc: '',
      isVideo: false,
    );
  }
}
