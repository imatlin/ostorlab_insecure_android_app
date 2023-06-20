import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'package:ostorlab_insecure_flutter_app/bug_rule.dart';

class PathTraversal extends BugRule {
  @override
  String get description => 'call to getLastPathSegment with Uri parameter';

  @override
  Future<void> run(String input) async {
    final provider = Provider();
    final builder = Uri.https('ostorlab.co', '');
    var tainted_path = '..%2F..%2F..%2Fpath%2Fsecret%2Ftoken.txt';
    if (input.isNotEmpty) {
      tainted_path = input;
    }
    final uri = builder.replace(path: tainted_path);

    final directory = await getExternalStorageDirectory();
    final targetPath = path.join(directory!.path, uri.pathSegments.last);
    final file = File(targetPath);

    await provider.openFile(file);
  }
}

class Provider {
  Future<RandomAccessFile> openFile(File file) async {
    return await file.open(mode: FileMode.read);
  }
}
