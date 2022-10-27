import 'dart:io';

import 'base_command.dart';

/// FileName delete
///
/// @Author wangjiong
/// @Date 2022/10/18
///
/// @Description: delete command

class DeleteCommand extends BaseCommand {
  factory DeleteCommand() => _instance;

  DeleteCommand._internal();

  static late final DeleteCommand _instance = DeleteCommand._internal();

  // default file path
  static String _DEFAULT_PATH = "pubspec.lock";

  @override
  String get description => "run delete file, the default is pubspec.lock";

  @override
  String get name => "delete";

  @override
  List<String> get aliases => ["d"];

  @override
  Future<void> run([String? commands]) {
    final paths = argResults?.rest;
    if (paths?.isEmpty == true) {
      final path = commands ?? _DEFAULT_PATH;
      print("========$name $path===============");
      _delete(path);
    } else {
      paths?.forEach((path) {
        print("========$name $path===============");
        _delete(path);
      });
    }
    return super.run();
  }

  /// delete file
  Future<void> _delete(String path) async {
    FileSystemEntity? fileEntity;
    if (await FileSystemEntity.isFile(path)) {
      fileEntity = File(path);
    } else if (await FileSystemEntity.isDirectory(path)) {
      fileEntity = Directory(path);
    }

    if (fileEntity?.existsSync() == true) {
      fileEntity?.deleteSync(recursive: true);
    }
  }
}
