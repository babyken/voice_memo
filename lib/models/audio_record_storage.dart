import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:testdrive/models/audio_record.dart';

class AudioRecordStorage {
  // ----- Helper ----- //
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> _localFile(filename) async {
    final path = await _localPath;
    return File('$path/$filename');
  }

  bool isAudioType(String filepath) {
    final extension = p.extension(filepath);
    return extension == '.mp4';
  }

  // ----- Public Methods ----- //
  Future<List<AudioRecord>> get fileList async {
    final path = await _localPath;
    List<FileSystemEntity> list = Directory("$path/").listSync();
    List<AudioRecord> result = [];
    for (var entity in list) {
      if (entity is File) {
        if (isAudioType(entity.path)) {
          final ar = AudioRecord(entity.path);
          result.add(ar);
        }
      }
    }
    print('Audio Storage: FileList: $result');

    return result;
  }

  Future<int> removeRecord(AudioRecord rec) async {
    try {
      final removeFile = await _localFile(rec.name);
      await removeFile.delete();
    } catch (e) {
      print('$e');
      return 0;
    }

    return 1;
  }

  Future<File> save(Uint8List data, filename) async {
    final file = await _localFile(filename);

    // Write the file
    return file.writeAsBytes(data);
  }
}
