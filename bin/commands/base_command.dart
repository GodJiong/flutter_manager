import 'dart:io';

import 'package:args/command_runner.dart';

/// FileName command
///
/// @Author wangjiong
/// @Date 2022/10/18
///
/// @Description: command基类
abstract class BaseCommand extends Command {
  /// 执行sh脚本
  @override
  Future<void> run([String? commands]) async {
    print("========run $commands==========");

    if (commands == null || commands.isEmpty) {
      return;
    }

    final tmp =
        File("${Directory.systemTemp.path}/${DateTime.now().millisecondsSinceEpoch}.sh");

    tmp.writeAsStringSync(commands);

    final process = await Process.start("sh", [tmp.path]);

    stdout.addStream(process.stdout);
    stderr.addStream(process.stderr);

    await process.exitCode;

    process.kill();
    tmp.deleteSync();
  }
}
