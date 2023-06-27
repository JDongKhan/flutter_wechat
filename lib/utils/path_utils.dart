import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// @author jd
class PathUtils {
  //用户不可见
  static Future<Directory?> getAppDocumentsDirectory() async {
    if (kIsWeb) {
      return null;
    }
    if (Platform.isIOS || Platform.isAndroid) {
      return getApplicationDocumentsDirectory();
    }
    return Directory('no support  get directory ');
  }

  //用户不可见
  static Future<Directory?> getAppTemporaryDirectory() async {
    if (kIsWeb) {
      return null;
    }
    if (Platform.isIOS || Platform.isAndroid) {
      return getTemporaryDirectory();
    }
    return Directory('no support  get directory');
  }

  //用户可见
  static Future<Directory?> getAppCacheDirectory() async {
    if (kIsWeb) {
      return null;
    }
    if (Platform.isAndroid) {
      return getExternalStorageDirectory();
    }
    if (Platform.isIOS) {
      return getTemporaryDirectory();
    }
    return Directory('no support  get directory');
  }
}
