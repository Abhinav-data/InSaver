import 'package:flutter/services.dart';

class ShareService {
  late void Function(String) onDataReceived;

  ShareService() {
    SystemChannels.lifecycle.setMessageHandler((msg) async {
      print(msg);
      if (msg?.contains("resumed") ?? false) {
        getSharedData().then((String data) {
          if (data.isEmpty) {
            return;
          }

          onDataReceived.call(data);
        });
      }
      return;
    });
  }

  Future<String> getSharedData() async {
    return await MethodChannel('com.tnorbury.flutterSharingTutorial')
            .invokeMethod("getSharedData") ??
        "";
  }
}
