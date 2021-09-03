class DownloadData {
  List<Map<String, dynamic>> dataFromDB(var x) {
    List<Map<String, dynamic>> y = <Map<String, dynamic>>[];
    for (var i = 0; i < x.length; i++) {
      String tag = x[i]['tag'];
      String fileName = x[i]['fileName'].split('.')[0];
      String ext = x[i]['fileName'].split('.')[1];
      String id = fileName[fileName.length - 1];
      String profilePhoto = x[i]['profile'];
      String postUrl = x[i]['url'];
      bool isVideo = (ext == 'mp4');
      bool containPosts = false;
      int childPosts = 1;
      String userName = x[i]['username'];
      String directory = x[i]['savedDir'];

      if (id == '0') {
        for (var j = 0; j < x.length; j++) {
          String filex = x[j]['fileName'].split('.')[0];
          String idx = filex[filex.length - 1];
          if (tag == x[j]['tag'] && idx != '0') {
            containPosts = true;
            childPosts += 1;
          }
        }
        y.add({
          'tag': tag,
          'fileName': fileName,
          'ext': ext,
          'id': id,
          'profilePhoto': profilePhoto,
          'postUrl': postUrl,
          'isVideo': isVideo,
          'containPosts': containPosts,
          'childPosts': childPosts,
          'userName': userName,
          'directory': directory,
        });
      }
    }
    return y;
  }

  List<Map<String, dynamic>> galleryData(var x) {
    List<Map<String, dynamic>> y = <Map<String, dynamic>>[];
    for (var i = 0; i < x.length; i++) {
      String tag = x[i]['tag'];
      String fileName = x[i]['fileName'].split('.')[0];
      String ext = x[i]['fileName'].split('.')[1];
      String id = fileName[fileName.length - 1];
      String profilePhoto = x[i]['profile'];
      String postUrl = x[i]['url'];
      bool isVideo = (ext == 'mp4');
      bool containPosts = false;
      int childPosts = 1;
      String userName = x[i]['username'];
      String directory = x[i]['savedDir'];
      y.add({
        'tag': tag,
        'fileName': fileName,
        'ext': ext,
        'id': id,
        'profilePhoto': profilePhoto,
        'postUrl': postUrl,
        'isVideo': isVideo,
        'containPosts': containPosts,
        'childPosts': childPosts,
        'userName': userName,
        'directory': directory,
      });
    }
    return y;
  }
}
