import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart';
import 'package:insaver/Screen/User/UserPost/postdata.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InstaData {
  static Future<InstaProfile> userProfileData(String profileUrl) async {
    InstaProfile _profileParsed = InstaProfile.enterEmpty();
    Client _client = Client();
    Response _response;
    var jsonData, finalData;
    Map<String, String> _userData = Map<String, String>();

    try {
      if (!profileUrl.contains('https://www.instagram.com/')) {
        profileUrl = 'https://www.instagram.com/' + profileUrl;
      }
      profileUrl = profileUrl + '/?__a=1';
      _response = await _client.get(Uri.parse('$profileUrl'));

      jsonData = json.decode(_response.body);
      finalData = jsonData['graphql']['user'];
      _userData['profileUrl'] =
          'https://www.instagram.com/' + finalData['username'].toString();
      _userData['profilePicUrl'] = finalData['profile_pic_url'].toString();
      _userData['profilePicUrlHd'] = finalData['profile_pic_url_hd'].toString();
      _userData['username'] = finalData['username'].toString();
      _userData['fullName'] = finalData['full_name'].toString();
      _userData['id'] = finalData['id'].toString();
      _userData['bio'] = finalData['biography'].toString().replaceAll('\n', '');
      _userData['postsCount'] =
          finalData['edge_owner_to_timeline_media']['count'].toString();
      _userData['followingsCount'] =
          finalData['edge_followed_by']['count'].toString();
      _userData['followersCount'] =
          finalData['edge_follow']['count'].toString();
      _userData['isPrivate'] = finalData['is_private'].toString();
      _userData['isVerified'] = finalData['is_verified'].toString();

      _profileParsed = InstaProfile.fromMap(_userData);
      return _profileParsed;
    } catch (error) {
      print(error);
      _profileParsed = InstaProfile.enterEmpty();
      return _profileParsed;
    }
  }

  static Future<InstaProfile> postFromUrl(String postUrl) async {
    InstaProfile _profileParsed = InstaProfile.enterEmpty();
    InstaPost _postParsed = InstaPost.enterEmpty();
    Client _client = Client();
    Response _response;
    var jsonData, finalData;
    Map<String, String> _postData = Map<String, String>();
    List<ChildPost> _childpostData = [];

    try {
      _response = await _client.get(Uri.parse('$postUrl'));
      jsonData = json.decode(_response.body);
    } catch (error) {
      print(error);
      return InstaProfile.enterEmpty();
    }

    print(jsonData);

    if (jsonData != null) {
      if (jsonData == {} || jsonData.length == 0) {
        _profileParsed.id = '1';
        _profileParsed.isPrivate = true;
        return _profileParsed;
      }
      finalData = jsonData['graphql']['shortcode_media'];

      _postData['childPostsCount'] =
          finalData['edge_media_to_caption'].length.toString();

      _postData['postUrl'] = postUrl;

      _postData['photoSmallUrl'] = finalData['display_resources'][0]['src'];
      _postData['photoMediumUrl'] = finalData['display_resources'][1]['src'];
      _postData['photoLargeUrl'] = finalData['display_resources'][2]['src'];

      var date = DateTime.fromMillisecondsSinceEpoch(
          finalData['taken_at_timestamp'] * 1000);
      var formattedDate = DateFormat.yMMMd().format(date);
      _postData['datetime'] = formattedDate.toString();
      _postData['likes'] =
          finalData['edge_media_preview_like']['count'].toString();
      _postData['commentsCount'] =
          finalData['edge_media_to_parent_comment']['count'].toString();
      _postData['videoUrl'] = finalData['video_url'].toString();
      _postData['videoViewsCount'] = finalData['video_view_count'].toString();

      try {
        if (finalData['edge_sidecar_to_children'].length == 1) {
          _postData['childPostsCount'] =
              finalData['edge_sidecar_to_children']['edges'].length.toString();
          for (var item in finalData['edge_sidecar_to_children']['edges']) {
            _childpostData.add(
              ChildPost(
                photoSmallUrl:
                    item['node']['display_resources'][0]['src'].toString(),
                photoMediumUrl:
                    item['node']['display_resources'][1]['src'].toString(),
                photoLargeUrl:
                    item['node']['display_resources'][2]['src'].toString(),
                videoUrl: item['node']['video_url'].toString(),
              ),
            );
          }
        }
      } catch (error) {}
      print(_postData);
      _postParsed = InstaPost.fromMap(_postData);
      _postParsed.childposts = _childpostData;
      _profileParsed.username = finalData['owner']['username'];
      _profileParsed.profilePicUrl = finalData['owner']['profile_pic_url'];
      _profileParsed.id = finalData['owner']['id'];
      _profileParsed.isPrivate = finalData['owner']['is_private'];
      _profileParsed.postData = _postParsed;
      print(_profileParsed.fullName);
      return _profileParsed;
    }
    return InstaProfile.enterEmpty();
  }

  static Future<InstaProfile> postFromPrivateUrl(
      String postUrl, String cookies) async {
    InstaProfile _profileParsed = InstaProfile.enterEmpty();
    InstaPost _postParsed = InstaPost.enterEmpty();
    Client _client = Client();
    Response _response;
    var jsonData, finalData;
    Map<String, String> _postData = Map<String, String>();
    List<ChildPost> _childpostData = [];

    try {
      _response = await _client.get(
        Uri.parse('$postUrl'),
        headers: {
          "Cookie": cookies,
          "User-Agent":
              "Instagram 9.5.2 (iPhone7,2; iPhone OS 9_3_3; en_US; en-US; scale=2.00; 750x1334) AppleWebKit/420+"
        },
      );
      jsonData = json.decode(_response.body);
      finalData = jsonData['graphql']['shortcode_media'];
      _postData['childPostsCount'] =
          finalData['edge_media_to_caption'].length.toString();

      _postData['postUrl'] = postUrl;

      _postData['photoSmallUrl'] = finalData['display_resources'][0]['src'];
      _postData['photoMediumUrl'] = finalData['display_resources'][1]['src'];
      _postData['photoLargeUrl'] = finalData['display_resources'][2]['src'];

      var date = DateTime.fromMillisecondsSinceEpoch(
          finalData['taken_at_timestamp'] * 1000);
      var formattedDate = DateFormat.yMMMd().format(date);
      _postData['datetime'] = formattedDate.toString();
      _postData['likes'] =
          finalData['edge_media_preview_like']['count'].toString();
      _postData['commentsCount'] =
          finalData['edge_media_to_parent_comment']['count'].toString();
      _postData['videoUrl'] = finalData['video_url'].toString();
      _postData['videoViewsCount'] = finalData['video_view_count'].toString();

      try {
        if (finalData['edge_sidecar_to_children'].length == 1) {
          _postData['childPostsCount'] =
              finalData['edge_sidecar_to_children']['edges'].length.toString();
          for (var item in finalData['edge_sidecar_to_children']['edges']) {
            _childpostData.add(
              ChildPost(
                photoSmallUrl:
                    item['node']['display_resources'][0]['src'].toString(),
                photoMediumUrl:
                    item['node']['display_resources'][1]['src'].toString(),
                photoLargeUrl:
                    item['node']['display_resources'][2]['src'].toString(),
                videoUrl: item['node']['video_url'].toString(),
              ),
            );
          }
        }
      } catch (error) {}

      _postParsed = InstaPost.fromMap(_postData);
      _postParsed.childposts = _childpostData;
      _profileParsed.username = finalData['owner']['username'];
      _profileParsed.profilePicUrl = finalData['owner']['profile_pic_url'];
      _profileParsed.id = finalData['owner']['id'];
      _profileParsed.isPrivate = finalData['owner']['is_private'];
      _profileParsed.postData = _postParsed;
      return _profileParsed;
    } catch (error) {
      print(error);
    }

    return InstaProfile.enterEmpty();
  }

  static Future<InstaProfile> postFromPostGallery(String postUrl) async {
    InstaProfile _profileParsed = InstaProfile.enterEmpty();
    InstaPost _postParsed = InstaPost.enterEmpty();
    Client _client = Client();
    Response _response;
    var jsonData, finalData;
    Map<String, String> _postData = Map<String, String>();
    List<ChildPost> _childpostData = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      _response = await _client.get(
        Uri.parse('$postUrl'),
        headers: {
          "Cookie": prefs.getString('Cookie') ?? '',
          "User-Agent":
              "Instagram 9.5.2 (iPhone7,2; iPhone OS 9_3_3; en_US; en-US; scale=2.00; 750x1334) AppleWebKit/420+"
        },
      );
      jsonData = json.decode(_response.body);
      finalData = jsonData['graphql']['shortcode_media'];
      _postData['childPostsCount'] =
          finalData['edge_media_to_caption'].length.toString();

      _postData['postUrl'] = postUrl;

      _postData['photoSmallUrl'] = finalData['display_resources'][0]['src'];
      _postData['photoMediumUrl'] = finalData['display_resources'][1]['src'];
      _postData['photoLargeUrl'] = finalData['display_resources'][2]['src'];

      var date = DateTime.fromMillisecondsSinceEpoch(
          finalData['taken_at_timestamp'] * 1000);
      var formattedDate = DateFormat.yMMMd().format(date);
      _postData['datetime'] = formattedDate.toString();
      _postData['likes'] =
          finalData['edge_media_preview_like']['count'].toString();
      _postData['commentsCount'] =
          finalData['edge_media_to_parent_comment']['count'].toString();
      _postData['videoUrl'] = finalData['video_url'].toString();
      _postData['videoViewsCount'] = finalData['video_view_count'].toString();

      try {
        if (finalData['edge_sidecar_to_children'].length == 1) {
          _postData['childPostsCount'] =
              finalData['edge_sidecar_to_children']['edges'].length.toString();
          for (var item in finalData['edge_sidecar_to_children']['edges']) {
            _childpostData.add(
              ChildPost(
                photoSmallUrl:
                    item['node']['display_resources'][0]['src'].toString(),
                photoMediumUrl:
                    item['node']['display_resources'][1]['src'].toString(),
                photoLargeUrl:
                    item['node']['display_resources'][2]['src'].toString(),
                videoUrl: item['node']['video_url'].toString(),
              ),
            );
          }
        }
      } catch (error) {}

      _postParsed = InstaPost.fromMap(_postData);
      _postParsed.childposts = _childpostData;
      _profileParsed.username = finalData['owner']['username'];
      _profileParsed.profilePicUrl = finalData['owner']['profile_pic_url'];
      _profileParsed.id = finalData['owner']['id'];
      _profileParsed.isPrivate = finalData['owner']['is_private'];
      _profileParsed.postData = _postParsed;
      return _profileParsed;
    } catch (error) {
      print(error);
    }

    return InstaProfile.enterEmpty();
  }

  static Future<List<InstaStory?>> userStoryData(
    String link,
    String cookies,
  ) async {
    Client _client = Client();
    InstaStory _instaStory = InstaStory.enterEmpty();
    Response _response, _res1;
    var jsonData, json1;
    Map<String, String> _storyData = Map<String, String>();
    try {
      _res1 = await _client.get(
        Uri.parse(link),
        headers: {
          "Cookie": cookies,
          "User-Agent":
              "Instagram 9.5.2 (iPhone7,2; iPhone OS 9_3_3; en_US; en-US; scale=2.00; 750x1334) AppleWebKit/420+"
        },
      );
      json1 = json.decode(_res1.body);
      String id = json1['user']['id'];
      _response = await _client.get(
        Uri.parse(
            'https://i.instagram.com/api/v1/feed/reels_media/?reel_ids=$id'),
        headers: {
          "Cookie": cookies,
          "User-Agent":
              "Instagram 9.5.2 (iPhone7,2; iPhone OS 9_3_3; en_US; en-US; scale=2.00; 750x1334) AppleWebKit/420+"
        },
      );
      jsonData = json.decode(_response.body);
      for (var i = 0; i < jsonData['reels']['$id']['items'].length; i++) {
        var j = jsonData['reels']['$id']['items'][i];
        if (link.contains(j['pk'].toString())) {
          _storyData['storyThumbnail'] =
              j['image_versions2']['candidates'][0]['url'];
          if (j['video_versions'] == null) {
            _storyData['downloadUrl'] =
                j['image_versions2']['candidates'][0]['url'];
          } else {
            _storyData['downloadUrl'] = j['video_versions'][0]['url'];
          }
          _storyData['username'] = jsonData['reels']['$id']['user']['username'];
          _storyData['profilePic'] =
              jsonData['reels']['$id']['user']['profile_pic_url'];
          _instaStory = InstaStory.fromMap(_storyData);
          return [_instaStory];
        }
      }
    } catch (e) {
      return [_instaStory];
    }
    return [_instaStory];
  }

  static Future<InstaProfile> userIdData(String username) async {
    InstaProfile _profileParsed = InstaProfile.enterEmpty();
    Client _client = Client();
    Response _response;
    var jsonData, finalData;
    Map<String, String> _userData = Map<String, String>();

    try {
      _response = await _client
          .get(Uri.parse('https://www.instagram.com/$username/?__a=1'));

      jsonData = json.decode(_response.body);
      finalData = jsonData['graphql']['user'];
      _profileParsed.id = finalData['id'];
      _profileParsed.username = finalData['username'];
      _profileParsed.profilePicUrl = finalData['profile_pic_url_hd'];
      return _profileParsed;
    } catch (error) {
      print(error);
      _profileParsed = InstaProfile.enterEmpty();
      return _profileParsed;
    }
  }

  static Future<List<InstaStory>> userStoryReelsData(
      String id, String cookies) async {
    Client _client = Client();
    InstaStory _instaStory = InstaStory.enterEmpty();

    Response _response;
    List<InstaStory> _stories = <InstaStory>[];
    var jsonData;
    Map<String, String> _storyData = Map<String, String>();
    try {
      _response = await _client.get(
        Uri.parse(
            'https://i.instagram.com/api/v1/feed/reels_media/?reel_ids=$id'),
        headers: {
          "Cookie": cookies,
          "User-Agent":
              "Instagram 9.5.2 (iPhone7,2; iPhone OS 9_3_3; en_US; en-US; scale=2.00; 750x1334) AppleWebKit/420+"
        },
      );
      jsonData = json.decode(_response.body);
      for (var i = 0; i < jsonData['reels']['$id']['items'].length; i++) {
        var j = jsonData['reels']['$id']['items'][i];
        _storyData['storyThumbnail'] =
            j['image_versions2']['candidates'][0]['url'];
        if (j['video_versions'] == null) {
          _storyData['downloadUrl'] =
              j['image_versions2']['candidates'][0]['url'];
        } else {
          _storyData['downloadUrl'] = j['video_versions'][0]['url'];
        }
        _storyData['username'] = jsonData['reels']['$id']['user']['username'];
        _storyData['profilePic'] =
            jsonData['reels']['$id']['user']['profile_pic_url'];
        _instaStory = InstaStory.fromMap(_storyData);
        _stories.add(_instaStory);
      }
    } catch (e) {}
    return _stories;
  }

  static Future<List<ReelsStory>> userReelsData(String cookies) async {
    Client _client = Client();
    Response _response;
    var jsonData, _user;
    Map<String, String> _userData = Map<String, String>();
    List<ReelsStory> reelStory = [];

    try {
      _response = await _client.get(
        Uri.parse('https://i.instagram.com/api/v1/feed/reels_tray/'),
        headers: {
          "Cookie": cookies,
          "User-Agent":
              "Instagram 9.5.2 (iPhone7,2; iPhone OS 9_3_3; en_US; en-US; scale=2.00; 750x1334) AppleWebKit/420+"
        },
      );
      jsonData = json.decode(_response.body);

      jsonData = jsonData['tray'];
      for (var i = 0; i < jsonData.length; i++) {
        _user = jsonData[i]['user'];
        _userData['profilePic'] = _user['profile_pic_url'];
        _userData['id'] = jsonData[i]['id'].toString();
        _userData['username'] = _user['username'];
        ReelsStory user = ReelsStory.fromMap(_userData);
        reelStory.add(user);
      }
    } catch (error) {}
    return reelStory;
  }

  static Future<List<List<String>>> hashtagGenerator(String hashtag) async {
    Client _client = Client();
    Response _response;
    List<String> html;
    List<List<String>> tags = [];
    List<String> res = [];
    final _r = new Random();
    try {
      _response = await _client.post(
        Uri.parse(
            'https://www.all-hashtag.com/library/contents/ajax_generator.php'),
        body: {
          'keyword': '$hashtag',
          'filter': 'random',
        },
        headers: {
          'Accept': '*/*',
          'Accept-Encoding': 'gzip, deflate, br',
          'Accept-Language': 'en-US,en;q=0.9',
          'Connection': 'keep-alive',
          'Content-Length': '${22 + hashtag.length}',
          'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
          'Cookie':
              '_ga=GA1.2.1117007844.1621535738; _gid=GA1.2.2074662137.1621535738; _gat=1',
          'Host': 'www.all-hashtag.com',
          'Origin': 'https://www.all-hashtag.com',
          'Referer': 'https://www.all-hashtag.com/hashtag-generator.php',
          'sec-ch-ua':
              '" Not A;Brand";v="99", "Chromium";v="90", "Microsoft Edge";v="90"',
          'sec-ch-ua-mobile': '?0',
          'Sec-Fetch-Dest': 'empty',
          'Sec-Fetch-Mode': 'cors',
          'Sec-Fetch-Site': 'same-origin',
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.212 Safari/537.36 Edg/90.0.818.66',
          'X-Requested-With': 'XMLHttpRequest',
        },
      );
      html = _response.body.toString().split(' ');
      for (var i = 0; i < html.length; i++) {
        String curr = html[i];
        if (curr.startsWith('#') &&
            !curr.contains('<') &&
            !curr.contains('(')) {
          res.add(html[i]);
        }
      }

      if (res.length != 0) {
        for (var i = 0; i < 20; i++) {
          List<String> temp = [];
          int j = 0;
          int total = 15 + _r.nextInt(16);
          while (j <= min(total, res.length)) {
            var element = res[_r.nextInt(res.length)];
            if (!temp.contains(element)) {
              temp.add(element);
              j += 1;
            }
          }
          tags.add(temp);
        }
      }
    } catch (e) {}
    return tags;
  }
}

class InstaStory {
  String storyThumbnail = '';
  String downloadUrl = '';
  String profilePic = '';
  String username = '';
  bool isVideo;

  InstaStory({
    required this.storyThumbnail,
    required this.downloadUrl,
    required this.profilePic,
    required this.username,
    required this.isVideo,
  });

  factory InstaStory.fromMap(Map<String, String> map) {
    return InstaStory(
      storyThumbnail: map['storyThumbnail'] ?? '',
      downloadUrl: map['downloadUrl'] ?? '',
      username: map['username'] ?? '',
      profilePic: map['profilePic'] ?? '',
      isVideo: (map['storyThumbnail'] != map['downloadUrl']),
    );
  }
  factory InstaStory.enterEmpty() {
    return InstaStory(
      storyThumbnail: '',
      downloadUrl: '',
      username: '',
      profilePic: '',
      isVideo: false,
    );
  }
}

class ReelsStory {
  String profilePic = '';
  String username = '';
  String id = '';

  ReelsStory({
    required this.profilePic,
    required this.username,
    required this.id,
  });

  factory ReelsStory.fromMap(Map<String, String> map) {
    return ReelsStory(
      profilePic: map['profilePic'] ?? '',
      id: map['id'] ?? '',
      username: map['username'] ?? '',
    );
  }
}

class InstaProfile {
  String profileUrl = '';
  String profilePicUrl = '';
  String profilePicUrlHd = '';
  String username = '';
  String fullName = '';
  String end = '';
  String id = '';
  String bio = '';
  int postsCount = 0;
  int followingsCount = 0;
  int followersCount = 0;
  bool isPrivate = true;
  bool isVerified = false;
  int storyCount = 0;
  InstaPost postData;
  List<InstaStory> storyData;
  List<UserPost> userPost;

  InstaProfile({
    required this.profileUrl,
    required this.profilePicUrl,
    required this.profilePicUrlHd,
    required this.username,
    required this.fullName,
    required this.id,
    required this.bio,
    required this.end,
    required this.postsCount,
    required this.followingsCount,
    required this.followersCount,
    required this.isPrivate,
    required this.isVerified,
    required this.postData,
    required this.storyData,
    required this.userPost,
  });

  factory InstaProfile.fromMap(Map<String, String> map) {
    return InstaProfile(
      profileUrl: map['profileUrl'] ?? '',
      profilePicUrl: map['profilePicUrl'] ?? '',
      profilePicUrlHd: map['profilePicUrlHd'] ?? '',
      username: map['username'] ?? '',
      fullName: map['fullName'] ?? '',
      id: map['id'] ?? '',
      bio: map['bio'] ?? '',
      end: '',
      postsCount: int.parse(map['postsCount'] ?? '0'),
      followingsCount: int.parse(map['followingsCount'] ?? '0'),
      followersCount: int.parse(map['followersCount'] ?? '0'),
      isPrivate: map['isPrivate'] == 'false' ? false : true,
      isVerified: map['isVerified'] == 'true' ? true : false,
      postData: InstaPost.enterEmpty(),
      userPost: [UserPost.enterEmpty()],
      storyData: [],
    );
  }

  factory InstaProfile.enterEmpty() {
    return InstaProfile(
      profileUrl: '',
      profilePicUrl: '',
      profilePicUrlHd: '',
      username: '',
      fullName: '',
      id: '',
      bio: '',
      end: '',
      postsCount: 0,
      followingsCount: 0,
      followersCount: 0,
      isPrivate: false,
      isVerified: false,
      postData: InstaPost.enterEmpty(),
      userPost: [UserPost.enterEmpty()],
      storyData: [],
    );
  }
}

class InstaPost {
  InstaProfile? instaProfile;
  String postUrl = '';
  String photoSmallUrl = '';
  String photoMediumUrl = '';
  String photoLargeUrl = '';
  String videoUrl = '';
  String description = '';
  String dateTime = '';
  List<ChildPost> childposts = [];
  int childPostsCount = 0;
  int likes = 0;
  int commentsCount = 0;
  String videoViewsCount = '0';

  InstaPost({
    required this.postUrl,
    required this.photoSmallUrl,
    required this.photoMediumUrl,
    required this.photoLargeUrl,
    required this.videoUrl,
    required this.description,
    required this.dateTime,
    required this.childposts,
    required this.childPostsCount,
    required this.likes,
    required this.commentsCount,
    required this.videoViewsCount,
  });

  factory InstaPost.fromMap(Map<String, String> map) {
    return InstaPost(
      postUrl: map['postUrl'] ?? '',
      photoSmallUrl: map['photoSmallUrl'] ?? '',
      photoMediumUrl: map['photoMediumUrl'] ?? '',
      photoLargeUrl: map['photoLargeUrl'] ?? '',
      videoUrl: map['videoUrl'] ?? '',
      description: map['description'] ?? '',
      dateTime: map['dateTime'] ?? '',
      childposts: [],
      childPostsCount: int.parse(map['childPostsCount'] ?? '0'),
      likes: int.parse(map['likes'] ?? '0'),
      commentsCount: int.parse(map['commentsCount'] ?? '0'),
      videoViewsCount: map['videoViewsCount'] ?? '',
    );
  }

  factory InstaPost.enterEmpty() {
    return InstaPost(
      postUrl: '',
      photoSmallUrl: '',
      photoMediumUrl: '',
      photoLargeUrl: '',
      videoUrl: '',
      description: '',
      dateTime: '',
      childposts: [],
      childPostsCount: 0,
      likes: 0,
      commentsCount: 0,
      videoViewsCount: '',
    );
  }
}

class ChildPost {
  String photoSmallUrl = '';
  String photoMediumUrl = '';
  String photoLargeUrl = '';
  String videoUrl = '';
  String videoViewsCount = '';

  ChildPost({
    required this.photoSmallUrl,
    required this.photoMediumUrl,
    required this.photoLargeUrl,
    required this.videoUrl,
  });
}
