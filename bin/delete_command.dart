import 'dart:io';

import 'command.dart';

/// FileName delete
///
/// @Author wangjiong
/// @Date 2022/10/18
///
/// @Description: delete命令

class DeleteCommand extends Command {
  factory DeleteCommand() => _instance;

  DeleteCommand._internal();

  static late final DeleteCommand _instance = DeleteCommand._internal();

  // 命令
  final String command = "pubspec.lock";

  @override
  Future<void> run([String? commands]) {
    print("=======执行删除pubspec.lock命令===============");
    return delete(commands ?? command);
  }

  /// 删除文件
  Future<void> delete(String path) async {
    final file = File(path);
    if (!file.existsSync()) {
      return;
    }
    file.deleteSync(recursive: true);
  }
}
