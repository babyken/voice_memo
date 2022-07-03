import 'dart:io';
import 'dart:math';
import 'package:path/path.dart' as p;

class AudioRecord {
  late final String path;

  String get name {
    return p.basename(path);
  }

  String get nameWithNoExt {
    return p.basenameWithoutExtension(path);
  }

  File get file {
    return File(path);
  }

  AudioRecord(this.path);

  Future<String> fileSize({int decimals = 1}) async {
    try {
      var file = File(path);
      int bytes = await file.length();
      if (bytes <= 0) return "0 B";
      const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
      var i = (log(bytes) / log(1024)).floor();
      return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) +
          ' ' +
          suffixes[i];
    } catch (err) {
      return '$err';
    }
  }
}
