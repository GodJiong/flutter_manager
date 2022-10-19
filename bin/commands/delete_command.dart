import 'dart:io';

import 'base_command.dart';

/// FileName delete
///
/// @Author wangjiong
/// @Date 2022/10/18
///
/// @Description: delete命令

class DeleteCommand extends BaseCommand {
  factory DeleteCommand() => _instance;

  DeleteCommand._internal();

  static late final DeleteCommand _instance = DeleteCommand._internal();

  // 文件路径
  final String path = "pubspec.lock";

  @override
  String get description => "run delete $path";

  @override
  String get name => "delete";

  @override
  List<String> get aliases => ["d"];

  @override
  Future<void> run([String? commands]) {
    print("=======执行删除pubspec.lock命令===============");
    return delete(commands ?? path);
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
